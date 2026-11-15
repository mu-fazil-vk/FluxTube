import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/core/enums.dart';
import 'package:fluxtube/core/player/global_player_controller.dart';
import 'package:fluxtube/core/operations/math_operations.dart';
import 'package:fluxtube/domain/watch/models/piped/comments/comment.dart';
import 'package:fluxtube/domain/watch/models/newpipe/newpipe_comments_resp.dart';
import 'package:fluxtube/domain/watch/models/newpipe/newpipe_stream.dart';
import 'package:fluxtube/domain/watch/models/newpipe/newpipe_watch_resp.dart';
import 'package:fluxtube/domain/watch/playback/newpipe_playback_resolver.dart';
import 'package:fluxtube/domain/watch/playback/models/playback_configuration.dart';
import 'package:fluxtube/domain/watch/playback/models/stream_quality_info.dart';
import 'package:fluxtube/domain/watch/playback/newpipe_stream_helper.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/infrastructure/newpipe/newpipe_channel.dart';
import 'package:fluxtube/widgets/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:rich_readmore/rich_readmore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:simple_html_css/simple_html_css.dart';

// Generic short item model to work with all services
class ShortItem {
  final String id;
  final String? title;
  final String? thumbnailUrl;
  final String? uploaderName;
  final String? uploaderAvatar;
  final String? uploaderId;
  final int? viewCount;
  final int? duration;
  final bool? uploaderVerified;
  final int? likeCount;

  ShortItem({
    required this.id,
    this.title,
    this.thumbnailUrl,
    this.uploaderName,
    this.uploaderAvatar,
    this.uploaderId,
    this.viewCount,
    this.duration,
    this.uploaderVerified,
    this.likeCount,
  });
}

class ScreenShorts extends StatefulWidget {
  const ScreenShorts({
    super.key,
    required this.shorts,
    required this.initialIndex,
    this.showCloseButton = true,
    this.isActive = true,
    this.onRefresh,
  });

  final List<ShortItem> shorts;
  final int initialIndex;

  /// Pull-to-refresh at the top of the feed, when supplied. `null` (the
  /// pushed-route usage, e.g. from a fixed personalized-feed shorts row)
  /// leaves the feed un-refreshable, since there's nothing meaningful to
  /// re-fetch for a one-off fixed list.
  final Future<void> Function()? onRefresh;

  /// False when embedded as the Shorts tab ([ShortsTabPage]) rather than
  /// pushed as its own route — there, [Navigator.pop] has nothing correct to
  /// return to (this Scaffold sits directly under `MainNavigation`'s single
  /// Navigator, not a route this screen was pushed onto), so the close
  /// button doesn't make sense and is hidden instead of misbehaving.
  final bool showCloseButton;

  /// Whether this is the currently selected tab. When embedded as the
  /// Shorts tab, [MainNavigation] keeps this screen mounted (but offstage)
  /// inside an `IndexedStack` when the user switches to another tab, so
  /// nothing would otherwise stop the current video from continuing to
  /// play — including its audio — in the background. [ShortsTabPage] feeds
  /// this from the shared tab-index notifier so it can be paused/resumed on
  /// tab switches. Always `true` for the pushed-route usage, where leaving
  /// the screen is a real `Navigator.pop` that already disposes it.
  final bool isActive;

  @override
  State<ScreenShorts> createState() => _ScreenShortsState();
}

class _ScreenShortsState extends State<ScreenShorts> {
  late PageController _pageController;
  late List<_ShortVideoController> _controllers;
  int _currentIndex = 0;

  /// Set when [_pauseForInactiveTab] pauses playback because the tab was
  /// switched away from, so [_resumeForActiveTab] only resumes it if we're
  /// the ones who paused it — not if the user had already paused it by
  /// tapping the video before leaving the tab.
  bool _autoPausedForInactiveTab = false;

  @override
  void didUpdateWidget(covariant ScreenShorts oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.shorts, widget.shorts)) {
      _rebuildForNewShortsList();
    }
    if (oldWidget.isActive == widget.isActive) return;
    if (widget.isActive) {
      _resumeForActiveTab();
    } else {
      _pauseForInactiveTab();
    }
  }

  /// A pull-to-refresh swapped in a freshly-fetched `shorts` list (a
  /// different list instance, e.g. from [ShortsTabPage]'s reload) — tear
  /// down the old per-item players and jump back to the top with the new
  /// content, since the old controllers/page position no longer line up
  /// with anything in the new list.
  void _rebuildForNewShortsList() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    _controllers =
        widget.shorts.map((short) => _ShortVideoController()).toList();
    _currentIndex = 0;
    _autoPausedForInactiveTab = false;
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
    if (widget.shorts.isNotEmpty) {
      _loadVideo(0);
    }
  }

  void _pauseForInactiveTab() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (_currentIndex < 0 || _currentIndex >= _controllers.length) return;
    final controller = _controllers[_currentIndex];
    if (controller.isPlaying) {
      _autoPausedForInactiveTab = true;
      controller.pause();
    }
  }

  void _resumeForActiveTab() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    if (!_autoPausedForInactiveTab) return;
    _autoPausedForInactiveTab = false;
    if (_currentIndex < 0 || _currentIndex >= _controllers.length) return;
    _controllers[_currentIndex].play();
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // Initialize controllers for each short
    _controllers =
        widget.shorts.map((short) => _ShortVideoController()).toList();

    // Pause any video playing in the global player before starting shorts
    _pauseGlobalPlayer();

    // Load the initial video
    _loadVideo(_currentIndex);

    // Hide system UI for immersive experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Future<void> _pauseGlobalPlayer() async {
    try {
      final globalPlayer = GlobalPlayerController();
      if (globalPlayer.currentVideoId != null) {
        await globalPlayer.pausePlayback();
      }
      // Clear the media notification - Shorts don't need notification controls
      await globalPlayer.clearMediaNotification();
    } catch (e) {
      debugPrint('[Shorts] Error pausing global player: $e');
    }
  }

  @override
  void dispose() {
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    for (var controller in _controllers) {
      controller.dispose();
    }
    _pageController.dispose();

    // Note: We don't auto-resume the global player here because
    // the user might navigate elsewhere after closing shorts

    super.dispose();
  }

  Future<void> _loadVideo(int index) async {
    if (index < 0 || index >= widget.shorts.length) return;

    final short = widget.shorts[index];
    final controller = _controllers[index];

    // Mark this controller as the one that should play
    controller.setShouldPlay(true);

    if (controller.isInitialized) {
      // Already initialized, just play
      controller.play();
    } else if (!controller.isInitializing) {
      // Not initialized and not currently initializing, start initialization
      controller.addListener(() {
        if (mounted) setState(() {});
      });
      await controller.initialize(short.id, context);
      if (mounted) setState(() {});
    }
    // If isInitializing is true, the setShouldPlay(true) above will ensure
    // it plays when initialization completes

    // Preload adjacent videos
    if (index + 1 < widget.shorts.length && mounted) {
      _preloadVideo(index + 1);
    }
  }

  Future<void> _preloadVideo(int index) async {
    if (index < 0 || index >= widget.shorts.length) return;
    final short = widget.shorts[index];
    final controller = _controllers[index];
    if (!controller.isInitialized) {
      await controller.preload(short.id, context);
    }
  }

  void _onPageChanged(int index) {
    final previousIndex = _currentIndex;

    // Mark previous controller as should not play and pause it
    if (previousIndex >= 0 && previousIndex < _controllers.length) {
      final prevController = _controllers[previousIndex];
      prevController.setShouldPlay(false);
      prevController.pause();
    }

    setState(() {
      _currentIndex = index;
    });

    _loadVideo(index);
  }

  @override
  Widget build(BuildContext context) {
    final locals = S.of(context);

    return Scaffold(
      backgroundColor: kBlackColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Material 3's default scrolledUnderElevation (3) paints a tinted
        // surface behind the title once the body registers as scrolled —
        // which the pull-to-refresh drag now triggers. Keep it fully
        // transparent regardless of scroll state.
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: widget.showCloseButton
            ? IconButton(
                icon: const Icon(CupertinoIcons.xmark, color: kWhiteColor),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: Text(
          locals.shorts,
          style: const TextStyle(
            color: kWhiteColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final pageView = PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      onPageChanged: _onPageChanged,
      itemCount: widget.shorts.length,
      itemBuilder: (context, index) {
        final short = widget.shorts[index];
        final controller = _controllers[index];

        return _ShortVideoPage(
          short: short,
          controller: controller,
          isActive: index == _currentIndex,
          // Embedded as a tab, the floating nav pill covers the bottom edge.
          bottomInset: widget.showCloseButton
              ? 0
              : 60 + AppSpacing.xxl + MediaQuery.paddingOf(context).bottom,
          onComment: () => _handleComment(short),
          onShare: () => _handleShare(short),
          onChannelTap: () => _handleChannelTap(short),
          onQualityTap: () => _showQualitySheet(controller),
        );
      },
    );

    final onRefresh = widget.onRefresh;
    if (onRefresh == null) return pageView;

    // Pulling down past the very first short refetches the feed. A plain
    // vertical PageView clamps at its boundary rather than rubber-banding,
    // but it still emits the overscroll notifications RefreshIndicator
    // listens for, so this works without any extra physics tweaking.
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: kWhiteColor,
      backgroundColor: kBlackColor,
      child: pageView,
    );
  }

  void _handleComment(ShortItem short) {
    _showCommentsSheet(short);
  }

  void _showCommentsSheet(ShortItem short) {
    final theme = Theme.of(context);
    final locals = S.of(context);
    final settingsState = context.read<SettingsBloc>().state;

    // Fetch comments based on service type - use force fetch to always get fresh comments
    if (settingsState.ytService == YouTubeServices.newpipe.name) {
      BlocProvider.of<WatchBloc>(context).add(
        WatchEvent.forceFetchNewPipeComments(id: short.id),
      );
    } else if (settingsState.ytService == YouTubeServices.invidious.name) {
      BlocProvider.of<WatchBloc>(context).add(
        WatchEvent.forceFetchInvidiousComments(id: short.id),
      );
    } else {
      BlocProvider.of<WatchBloc>(context).add(
        WatchEvent.forceFetchCommentData(id: short.id),
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      locals.comments,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(CupertinoIcons.xmark),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Comments list
              Expanded(
                child: BlocBuilder<WatchBloc, WatchState>(
                  builder: (context, watchState) {
                    // Determine the correct status and comments based on service
                    final isLoading =
                        watchState.fetchCommentsStatus == ApiStatus.loading ||
                            watchState.fetchNewPipeCommentsStatus ==
                                ApiStatus.loading ||
                            watchState.fetchInvidiousCommentsStatus ==
                                ApiStatus.loading;

                    if (isLoading) {
                      return Center(child: cIndicator(context));
                    }

                    // Get comments from the appropriate source
                    final pipedComments = watchState.comments.comments;
                    final newPipeComments =
                        watchState.newPipeComments.comments ?? [];
                    final invidiousComments =
                        watchState.invidiousComments.comments ?? [];

                    // Use whichever has data
                    final hasComments = pipedComments.isNotEmpty ||
                        newPipeComments.isNotEmpty ||
                        invidiousComments.isNotEmpty;

                    if (!hasComments) {
                      return Center(
                        child: Text(
                          locals.noCommentsFound,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    }

                    // Build unified comment list
                    return _ShortsCommentsList(
                      scrollController: scrollController,
                      theme: theme,
                      locals: locals,
                      watchState: watchState,
                      videoId: short.id,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQualitySheet(_ShortVideoController controller) {
    if (controller.availableQualities == null ||
        controller.availableQualities!.isEmpty) {
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final qualities = controller.availableQualities!;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(top: 10, bottom: 8),
                  decoration: BoxDecoration(
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Text(
                  S.of(context).videoQuality,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.45,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: qualities.length,
                  itemBuilder: (context, index) {
                    final quality = qualities[index];
                    final isSelected =
                        quality.label == controller.currentQuality;
                    final height = int.tryParse(RegExp(r'(\d{3,4})p')
                                .firstMatch(quality.label)
                                ?.group(1) ??
                            '') ??
                        0;
                    final tag = height >= 2160
                        ? '4K'
                        : height >= 1440
                            ? 'QHD'
                            : height >= 720
                                ? 'HD'
                                : null;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Material(
                        color: isSelected
                            ? scheme.secondaryContainer
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            controller.changeQuality(quality.label);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 13),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    quality.label,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontSize: 15,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? scheme.onSecondaryContainer
                                          : scheme.onSurface,
                                    ),
                                  ),
                                ),
                                if (tag != null)
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: scheme.outline, width: 1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      tag,
                                      style: TextStyle(
                                        color: scheme.onSurfaceVariant,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 12),
                                Icon(
                                  isSelected
                                      ? CupertinoIcons.checkmark_circle_fill
                                      : CupertinoIcons.circle,
                                  size: 20,
                                  color: isSelected
                                      ? scheme.primary
                                      : scheme.outline,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _handleShare(ShortItem short) {
    final url = 'https://www.youtube.com/shorts/${short.id}';
    SharePlus.instance.share(ShareParams(text: url));
  }

  void _handleChannelTap(ShortItem short) {
    final controller = _controllers[_currentIndex];
    final uploaderId = controller.uploaderId ?? short.uploaderId;
    if (uploaderId != null && uploaderId.isNotEmpty) {
      context.goNamed(
        'channel',
        pathParameters: {'channelId': uploaderId},
        queryParameters: {
          'avatarUrl': controller.uploaderAvatar ?? short.uploaderAvatar ?? '',
        },
      );
    }
  }
}

class _ShortVideoPage extends StatelessWidget {
  final ShortItem short;
  final _ShortVideoController controller;
  final bool isActive;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onChannelTap;
  final VoidCallback onQualityTap;
  final double bottomInset;

  const _ShortVideoPage({
    required this.short,
    required this.controller,
    required this.isActive,
    this.bottomInset = 0,
    required this.onComment,
    required this.onShare,
    required this.onChannelTap,
    required this.onQualityTap,
  });

  @override
  Widget build(BuildContext context) {
    final locals = S.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Video or thumbnail
        if (controller.isInitialized && isActive) ...[
          // The native view never takes part in hit-testing; a plain Flutter
          // layer owns the tap so it can't be lost to the platform view.
          IgnorePointer(child: _NativeShortPlayer(controller: controller)),
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: controller.togglePlayPause,
              onLongPressStart: (_) => controller.startHoldSpeed(),
              onLongPressEnd: (_) => controller.endHoldSpeed(),
              onLongPressCancel: controller.endHoldSpeed,
            ),
          ),
          if (controller.isHoldSpeeding)
            const Positioned(
              top: 110,
              left: 0,
              right: 0,
              child: IgnorePointer(child: Center(child: _HoldSpeedPill())),
            ),
        ] else if (short.thumbnailUrl != null)
          ThumbnailImage.small(url: short.thumbnailUrl!)
        else
          Container(color: kBlackColor),

        // Loading indicator - only show when loading AND not initialized
        if (isActive && controller.isLoading && !controller.isInitialized)
          const Center(
            child: CircularProgressIndicator(color: kWhiteColor),
          ),

        // Buffering indicator - only show when buffering during playback
        if (isActive &&
            controller.isInitialized &&
            controller.isBuffering &&
            controller.isPlaying)
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kBlackColor.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  color: kWhiteColor,
                  strokeWidth: 2,
                ),
              ),
            ),
          ),

        // Play/Pause overlay - make the entire center area tappable
        if (controller.isInitialized &&
            !controller.isPlaying &&
            isActive &&
            !controller.isLoading)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => controller.togglePlayPause(),
              behavior: HitTestBehavior.opaque,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: kBlackColor.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.play_fill,
                    color: kWhiteColor,
                    size: 50,
                  ),
                ),
              ),
            ),
          ),

        // Error overlay
        if (controller.hasError && isActive)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  CupertinoIcons.exclamationmark_circle,
                  color: kWhiteColor,
                  size: 48,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Error loading video',
                  style: TextStyle(color: kWhiteColor),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => controller.retry(short.id, context),
                  child: Text(locals.retry),
                ),
              ],
            ),
          ),

        // Bottom gradient
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Container(
              height: 200 + bottomInset,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    kBlackColor.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Progress bar at bottom
        if (controller.isInitialized && isActive)
          Positioned(
            bottom: bottomInset,
            left: 0,
            right: 0,
            child: _VideoProgressBar(controller: controller),
          ),

        // Right side action buttons
        Positioned(
          right: 12,
          bottom: 100 + bottomInset,
          child: Column(
            children: [
              // Like count display
              _ActionButton(
                // Likes and views are read-only stats: there are no
                // accounts to like with, so they aren't buttons.
                icon: CupertinoIcons.hand_thumbsup_fill,
                label: controller.likeCount != null
                    ? (controller.likeCount == -1
                        ? locals.like
                        : formatCount(controller.likeCount.toString()))
                    : (short.likeCount != null
                        ? (short.likeCount == -1
                            ? locals.like
                            : formatCount(short.likeCount.toString()))
                        : ''),
              ),
              const SizedBox(height: 20),
              // View count display
              _ActionButton(
                icon: CupertinoIcons.eye_fill,
                label: controller.viewCount != null
                    ? formatCount(controller.viewCount.toString())
                    : (short.viewCount != null
                        ? formatCount(short.viewCount.toString())
                        : ''),
              ),
              const SizedBox(height: 20),
              // Comment button
              _ActionButton(
                icon: CupertinoIcons.chat_bubble_fill,
                label: '',
                onTap: onComment,
              ),
              const SizedBox(height: 20),
              // Share button
              _ActionButton(
                icon: CupertinoIcons.share,
                label: '',
                onTap: onShare,
              ),
              // Quality lives in the rail with the other secondary actions
              // instead of floating over the video.
              if (controller.isInitialized &&
                  controller.currentQuality != null) ...[
                const SizedBox(height: 20),
                _ActionButton(
                  icon: CupertinoIcons.slider_horizontal_3,
                  label: controller.currentQuality!.split(' ').first,
                  onTap: onQualityTap,
                ),
              ],
            ],
          ),
        ),

        // Bottom info
        Positioned(
          bottom: 30 + bottomInset,
          left: 16,
          right: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Channel info
              GestureDetector(
                onTap: onChannelTap,
                child: Row(
                  children: [
                    // Channel avatar
                    _buildChannelAvatar(
                        controller.uploaderAvatar ?? short.uploaderAvatar),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  controller.uploaderName ??
                                      short.uploaderName ??
                                      locals.noUploaderName,
                                  style: const TextStyle(
                                    color: kWhiteColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (controller.uploaderVerified == true ||
                                  short.uploaderVerified == true) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  CupertinoIcons.checkmark_seal_fill,
                                  color: kWhiteColor,
                                  size: 12,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Title
              Text(
                controller.title ?? short.title ?? '',
                style: const TextStyle(
                  color: kWhiteColor,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChannelAvatar(String? avatarUrl) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return ClipOval(
        child: ThumbnailImage.small(
          url: avatarUrl,
          width: 36,
          height: 36,
          errorWidget: (_, __, ___) => _buildDefaultAvatar(),
        ),
      );
    }
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        CupertinoIcons.person_fill,
        color: kWhiteColor,
        size: 18,
      ),
    );
  }
}

/// Progress bar widget for shorts
class _VideoProgressBar extends StatefulWidget {
  final _ShortVideoController controller;

  const _VideoProgressBar({required this.controller});

  @override
  State<_VideoProgressBar> createState() => _VideoProgressBarState();
}

class _VideoProgressBarState extends State<_VideoProgressBar> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<(int, int)>(
      valueListenable: widget.controller.progress,
      builder: (context, value, _) {
        final progress = value.$2 > 0 ? value.$1 / value.$2 : 0.0;
        return SizedBox(
          height: 3,
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: kWhiteColor.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 3,
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kBlackColor.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: kWhiteColor,
              size: 24,
            ),
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: kWhiteColor,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Comment tile with HTML formatting support
class _CommentTile extends StatelessWidget {
  const _CommentTile({
    this.avatarUrl,
    required this.author,
    required this.time,
    required this.text,
    required this.likeCount,
    required this.theme,
    required this.locals,
    this.replyCount,
    this.onReplyTap,
    this.isHearted = false,
    this.isPinned = false,
    this.isVerified = false,
  });

  final String? avatarUrl;
  final String author;
  final String time;
  final String text;
  final String likeCount;
  final ThemeData theme;
  final bool isHearted;
  final bool isPinned;
  final bool isVerified;
  final S locals;
  final int? replyCount;
  final VoidCallback? onReplyTap;

  @override
  Widget build(BuildContext context) {
    final scheme = theme.colorScheme;
    final metaStyle = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
      fontSize: 12,
    );
    final likes = int.tryParse(likeCount) ?? 0;
    Widget placeholder() => ColoredBox(
          color: scheme.surfaceContainerHighest,
          child: SizedBox.square(
            dimension: 32,
            child: Icon(CupertinoIcons.person_fill,
                size: 16, color: scheme.onSurfaceVariant),
          ),
        );

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipOval(
            child: avatarUrl != null
                ? ThumbnailImage.small(
                    url: avatarUrl!,
                    width: 32,
                    height: 32,
                    errorWidget: (_, __, ___) => placeholder(),
                  )
                : placeholder(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isPinned)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.pin_fill,
                            size: 11, color: scheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(locals.pinned, style: metaStyle),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: metaStyle?.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (isVerified) ...[
                      const SizedBox(width: 3),
                      Icon(CupertinoIcons.checkmark_seal_fill,
                          size: 12, color: scheme.onSurfaceVariant),
                    ],
                    if (time.isNotEmpty)
                      Flexible(
                        child: Text(
                          '  ·  $time',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: metaStyle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                RichReadMoreText(
                  HTML.toTextSpan(
                    context,
                    text
                        .replaceAll('&amp;', '&')
                        .replaceAll('&lt;', '<')
                        .replaceAll('&gt;', '>')
                        .replaceAll('&quot;', '"')
                        .replaceAll('&#39;', "'")
                        .replaceAll('&apos;', "'")
                        .replaceAll('&nbsp;', ' '),
                    defaultTextStyle: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.normal,
                      fontSize: 14,
                      height: 1.4,
                      color: scheme.onSurface,
                    ),
                  ),
                  settings: LineModeSettings(
                    trimLines: 4,
                    trimCollapsedText: ' ${locals.readMoreText}',
                    trimExpandedText: ' ${locals.showLessText}',
                    moreStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurfaceVariant,
                    ),
                    lessStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(CupertinoIcons.hand_thumbsup,
                        size: 15, color: scheme.onSurfaceVariant),
                    if (likes > 0) ...[
                      const SizedBox(width: 5),
                      Text(formatCount(likeCount), style: metaStyle),
                    ],
                    if (isHearted) ...[
                      const SizedBox(width: 16),
                      Tooltip(
                        message: locals.heartedByCreator,
                        child: const Icon(CupertinoIcons.heart_fill,
                            size: 14, color: Color(0xFFFF525E)),
                      ),
                    ],
                  ],
                ),
                if (replyCount != null && replyCount! > 0 && onReplyTap != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: TextButton.icon(
                      onPressed: onReplyTap,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 34),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: scheme.primary,
                        shape: const StadiumBorder(),
                      ),
                      icon: const Icon(CupertinoIcons.chevron_down, size: 14),
                      label: Text(
                        '${formatCount(replyCount.toString())} ${locals.repliesPlural(replyCount!)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortVideoController extends ChangeNotifier {
  MethodChannel? _channel;
  NewPipeWatchResp? _watchResp;
  Map<String, Object?>? _sourceParams;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _isBuffering = false;
  bool _hasError = false;
  bool _shouldPlay = false;
  bool _isInitializing = false;

  /// (positionMs, durationMs) pushed by the native view a few times a second;
  /// kept out of [notifyListeners] so ticks only rebuild the progress bar.
  final ValueNotifier<(int, int)> progress = ValueNotifier((0, 0));

  List<StreamQualityInfo>? _availableQualities;
  String? _currentQuality;

  String? _title;
  String? _uploaderName;
  String? _uploaderAvatar;
  String? _uploaderId;
  bool? _uploaderVerified;
  int? _likeCount;
  int? _viewCount;

  bool get isInitialized => _isInitialized;
  bool get isInitializing => _isInitializing;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  bool get isBuffering => _isBuffering;
  bool get hasError => _hasError;
  Map<String, Object?>? get sourceParams => _sourceParams;

  List<StreamQualityInfo>? get availableQualities => _availableQualities;
  String? get currentQuality => _currentQuality;

  String? get title => _title;
  String? get uploaderName => _uploaderName;
  String? get uploaderAvatar => _uploaderAvatar;
  String? get uploaderId => _uploaderId;
  bool? get uploaderVerified => _uploaderVerified;
  int? get likeCount => _likeCount;
  int? get viewCount => _viewCount;

  Future<void> initialize(String videoId, BuildContext context) async {
    if (_isInitialized || _isInitializing) return;
    _isInitializing = true;
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      if (_watchResp?.id != videoId) await preload(videoId, context);
      final watchResp = _watchResp;
      if (watchResp == null) throw StateError('No stream info for $videoId');

      final config = NewPipePlaybackResolver().resolve(
        watchResp: watchResp,
        preferredQuality: '720p',
        preferHighQuality: false,
      );
      if (!config.isValid) {
        _hasError = true;
        return;
      }
      _applyConfig(config);
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing short video: $e');
      _hasError = true;
    } finally {
      _isInitializing = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  void _applyConfig(PlaybackConfiguration config) {
    _currentQuality = config.qualityLabel;
    _sourceParams = {
      'sourceType': config.sourceType.name,
      'videoUrl': config.videoUrl,
      'audioUrl': config.sourceType == MediaSourceType.merging
          ? (_selectMediumQualityAudio() ?? config.audioUrl)
          : config.audioUrl,
      'manifestUrl': config.manifestUrl,
      'playWhenReady': _shouldPlay,
    };
  }

  /// Called by the native view once it exists.
  void attach(int viewId) {
    _channel = MethodChannel('com.fazilvk.fluxtube/short_exoplayer_$viewId');
    _channel!.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onState':
          final args = Map<String, dynamic>.from(call.arguments as Map);
          // Follow the play intent, not isPlaying: the latter is false while
          // rebuffering, which would flash the paused overlay mid-playback.
          final playing = args['playWhenReady'] as bool? ??
              args['isPlaying'] as bool? ??
              false;
          final buffering = args['isBuffering'] as bool? ?? false;
          progress.value = (
            (args['positionMs'] as num? ?? 0).toInt(),
            (args['durationMs'] as num? ?? 0).toInt(),
          );
          if (playing != _isPlaying || buffering != _isBuffering) {
            _isPlaying = playing;
            _isBuffering = buffering;
            notifyListeners();
          }
          break;
        case 'onError':
          _hasError = true;
          notifyListeners();
          break;
      }
    });
    if (_shouldPlay) _channel!.invokeMethod('play');
  }

  /// Called when the native view goes away (its page scrolled off screen).
  void detach() {
    _channel?.setMethodCallHandler(null);
    _channel = null;
    _isPlaying = false;
    _isBuffering = false;
    _isHoldSpeeding = false;
    progress.value = (0, 0);
  }

  String? _selectMediumQualityAudio() {
    final audioStreams = _watchResp?.audioStreams ?? [];
    if (audioStreams.isEmpty) return null;

    final originalStreams = audioStreams.where((audio) {
      if (audio.url == null || audio.url!.isEmpty) return false;
      return audio.isOriginal;
    }).toList();

    final candidateStreams = originalStreams.isNotEmpty
        ? originalStreams
        : audioStreams.where((audio) {
            if (audio.url == null || audio.url!.isEmpty) return false;
            return !audio.isDescriptive;
          }).toList();

    if (candidateStreams.isEmpty) {
      final anyValid = audioStreams.firstWhere(
        (audio) => audio.url != null && audio.url!.isNotEmpty,
        orElse: () => audioStreams.first,
      );
      return anyValid.url;
    }

    const targetBitrate = 128;
    NewPipeAudioStream? selectedAudio = candidateStreams.first;
    int smallestDiff = 999999;
    for (var audio in candidateStreams) {
      final diff = ((audio.averageBitrate ?? 0) - targetBitrate).abs();
      if (diff < smallestDiff) {
        smallestDiff = diff;
        selectedAudio = audio;
      }
    }
    return selectedAudio?.url;
  }

  String? _extractChannelId(String? uploaderUrl) {
    if (uploaderUrl == null) return null;
    final uri = Uri.tryParse(uploaderUrl);
    if (uri != null && uri.pathSegments.isNotEmpty) {
      final channelIndex = uri.pathSegments.indexOf('channel');
      if (channelIndex != -1 && channelIndex + 1 < uri.pathSegments.length) {
        return uri.pathSegments[channelIndex + 1];
      }
    }
    return null;
  }

  Future<void> preload(String videoId, BuildContext context) async {
    if (_isInitialized || _watchResp?.id == videoId) return;
    try {
      final watchResp = await NewPipeChannel.getStreamInfo(videoId);
      _title = watchResp.title;
      _uploaderName = watchResp.uploaderName;
      _uploaderAvatar = watchResp.uploaderAvatarUrl;
      _uploaderId = _extractChannelId(watchResp.uploaderUrl);
      _uploaderVerified = watchResp.uploaderVerified;
      _likeCount = watchResp.likeCount;
      _viewCount = watchResp.viewCount;
      _watchResp = watchResp;
      _availableQualities =
          NewPipeStreamHelper.getAvailableQualities(watchResp);
    } catch (e) {
      debugPrint('Error preloading short: $e');
    }
  }

  Future<void> changeQuality(String newQuality) async {
    if (_currentQuality == newQuality || _watchResp == null) return;
    final newConfig = NewPipePlaybackResolver().resolve(
      watchResp: _watchResp!,
      preferredQuality: newQuality,
      preferHighQuality: true,
    );
    if (!newConfig.isValid) return;
    final position = progress.value.$1;
    _shouldPlay = _shouldPlay || _isPlaying;
    _applyConfig(newConfig);
    notifyListeners();
    await _channel?.invokeMethod('load', _sourceParams);
    if (position > 0) {
      await _channel?.invokeMethod('seekTo', {'positionMs': position});
    }
  }

  Future<void> retry(String videoId, BuildContext context) async {
    _hasError = false;
    _isInitialized = false;
    _sourceParams = null;
    notifyListeners();
    await initialize(videoId, context);
  }

  void togglePlayPause() => _isPlaying ? pause() : play();

  void setShouldPlay(bool value) {
    _shouldPlay = value;
  }

  void play() {
    _shouldPlay = true;
    _channel?.invokeMethod('play');
  }

  void pause() {
    _shouldPlay = false;
    _channel?.invokeMethod('pause');
  }

  bool _isHoldSpeeding = false;
  bool get isHoldSpeeding => _isHoldSpeeding;

  /// Press-and-hold fast-forward, like the watch player.
  void startHoldSpeed() {
    if (!_isPlaying || _isHoldSpeeding) return;
    _isHoldSpeeding = true;
    HapticFeedback.selectionClick();
    _channel?.invokeMethod('setSpeed', {'speed': 2.0});
    notifyListeners();
  }

  void endHoldSpeed() {
    if (!_isHoldSpeeding) return;
    _isHoldSpeeding = false;
    _channel?.invokeMethod('setSpeed', {'speed': 1.0});
    notifyListeners();
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    progress.dispose();
    _isInitialized = false;
    super.dispose();
  }
}

/// Hosts the native looping player for one short. Mounted only while its page
/// is active, so at most one decoder runs in the feed at a time.
class _NativeShortPlayer extends StatefulWidget {
  const _NativeShortPlayer({required this.controller});

  final _ShortVideoController controller;

  @override
  State<_NativeShortPlayer> createState() => _NativeShortPlayerState();
}

class _NativeShortPlayerState extends State<_NativeShortPlayer> {
  @override
  void dispose() {
    widget.controller.detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AndroidView(
      viewType: 'fluxtube/short_exoplayer',
      creationParams: widget.controller.sourceParams,
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: widget.controller.attach,
    );
  }
}

/// Stateful widget for comments list with scroll-based pagination
class _ShortsCommentsList extends StatefulWidget {
  const _ShortsCommentsList({
    required this.scrollController,
    required this.theme,
    required this.locals,
    required this.watchState,
    required this.videoId,
  });

  final ScrollController scrollController;
  final ThemeData theme;
  final S locals;
  final WatchState watchState;
  final String videoId;

  @override
  State<_ShortsCommentsList> createState() => _ShortsCommentsListState();
}

class _ShortsCommentsListState extends State<_ShortsCommentsList> {
  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final settingsState = context.read<SettingsBloc>().state;
    final state = widget.watchState;

    if (widget.scrollController.position.pixels >=
        widget.scrollController.position.maxScrollExtent - 200) {
      // Load more based on service
      if (settingsState.ytService == YouTubeServices.newpipe.name) {
        if (state.fetchMoreNewPipeCommentsStatus != ApiStatus.loading &&
            !state.isMoreNewPipeCommentsFetchCompleted &&
            state.newPipeComments.nextPage != null) {
          context.read<WatchBloc>().add(WatchEvent.getMoreNewPipeComments(
              id: widget.videoId, nextPage: state.newPipeComments.nextPage!));
        }
      } else if (settingsState.ytService == YouTubeServices.invidious.name) {
        if (state.fetchMoreInvidiousCommentsStatus != ApiStatus.loading &&
            !state.isMoreInvidiousCommentsFetchCompleted &&
            state.invidiousComments.continuation != null) {
          context.read<WatchBloc>().add(WatchEvent.getMoreInvidiousComments(
              id: widget.videoId,
              continuation: state.invidiousComments.continuation!));
        }
      } else {
        if (state.fetchMoreCommentsStatus != ApiStatus.loading &&
            !state.isMoreCommentsFetchCompleted &&
            state.comments.nextpage != null) {
          context.read<WatchBloc>().add(WatchEvent.getMoreCommentsData(
              id: widget.videoId, nextPage: state.comments.nextpage));
        }
      }
    }
  }

  void _showReplies(BuildContext context, Comment comment) {
    debugPrint(
        '[Shorts] _showReplies called: commentId=${comment.commentId}, repliesPage=${comment.repliesPage}');
    if (comment.commentId != null && comment.repliesPage != null) {
      context.read<WatchBloc>().add(WatchEvent.getCommentRepliesData(
          id: comment.commentId!, nextPage: comment.repliesPage!));
      _showRepliesSheet(context, comment);
    } else {
      debugPrint(
          '[Shorts] Cannot show replies: commentId or repliesPage is null');
    }
  }

  void _showNewPipeReplies(BuildContext context, NewPipeComment comment) {
    debugPrint(
        '[Shorts] _showNewPipeReplies called: repliesPage=${comment.repliesPage}');
    if (comment.repliesPage != null) {
      context.read<WatchBloc>().add(WatchEvent.getNewPipeCommentReplies(
          videoId: widget.videoId, repliesPage: comment.repliesPage!));
      _showNewPipeRepliesSheet(context, comment);
    } else {
      debugPrint('[Shorts] Cannot show NewPipe replies: repliesPage is null');
    }
  }

  void _showNewPipeRepliesSheet(
      BuildContext context, NewPipeComment parentComment) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NewPipeRepliesSheet(
        parentComment: parentComment,
        theme: theme,
        isDark: isDark,
        locals: widget.locals,
        videoId: widget.videoId,
      ),
    );
  }

  void _showRepliesSheet(BuildContext context, Comment parentComment) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PipedRepliesSheet(
        parentComment: parentComment,
        theme: theme,
        isDark: isDark,
        locals: widget.locals,
        videoId: widget.videoId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = context.read<SettingsBloc>().state;
    final state = widget.watchState;

    if (settingsState.ytService == YouTubeServices.newpipe.name) {
      final comments = state.newPipeComments.comments ?? [];
      final isLoadingMore =
          state.fetchMoreNewPipeCommentsStatus == ApiStatus.loading;
      final hasMore = !state.isMoreNewPipeCommentsFetchCompleted;

      return ListView.builder(
        controller: widget.scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: comments.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= comments.length) {
            return isLoadingMore
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(child: cIndicator(context)),
                  )
                : const SizedBox.shrink();
          }

          final comment = comments[index];
          // Check if we can show replies: replyCount > 0 AND repliesPage is available
          final canShowReplies = comment.replyCount != null &&
              comment.replyCount! > 0 &&
              comment.repliesPage != null;
          return _CommentTile(
            avatarUrl: comment.authorAvatarUrl,
            author: comment.authorName ?? widget.locals.commentAuthorNotFound,
            time: comment.uploadDate ?? '',
            text: comment.text ?? '',
            likeCount: comment.likeCount?.toString() ?? '0',
            theme: widget.theme,
            locals: widget.locals,
            replyCount: comment.replyCount,
            onReplyTap: canShowReplies
                ? () => _showNewPipeReplies(context, comment)
                : null,
            isHearted: comment.isHearted ?? false,
            isPinned: comment.isPinned ?? false,
            isVerified: comment.authorVerified ?? false,
          );
        },
      );
    } else if (settingsState.ytService == YouTubeServices.invidious.name) {
      final comments = state.invidiousComments.comments ?? [];
      final isLoadingMore =
          state.fetchMoreInvidiousCommentsStatus == ApiStatus.loading;
      final hasMore = !state.isMoreInvidiousCommentsFetchCompleted;

      return ListView.builder(
        controller: widget.scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: comments.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= comments.length) {
            return isLoadingMore
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(child: cIndicator(context)),
                  )
                : const SizedBox.shrink();
          }

          final comment = comments[index];
          return _CommentTile(
            avatarUrl: comment.authorThumbnails?.isNotEmpty == true
                ? comment.authorThumbnails!.first.url
                : null,
            author: comment.author ?? widget.locals.commentAuthorNotFound,
            time: comment.publishedText ?? '',
            text: comment.content ?? '',
            likeCount: comment.likeCount?.toString() ?? '0',
            theme: widget.theme,
            locals: widget.locals,
            replyCount: comment.replies?.replyCount,
            onReplyTap: null, // Invidious reply API not implemented
            isPinned: comment.isPinned ?? false,
            isVerified: comment.verified ?? false,
          );
        },
      );
    } else {
      // Piped service - has reply support
      final comments = state.comments.comments;
      final isLoadingMore = state.fetchMoreCommentsStatus == ApiStatus.loading;
      final hasMore = !state.isMoreCommentsFetchCompleted;

      return ListView.builder(
        controller: widget.scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: comments.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= comments.length) {
            return isLoadingMore
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(child: cIndicator(context)),
                  )
                : const SizedBox.shrink();
          }

          final comment = comments[index];
          // Check if we can show replies: replyCount > 0 AND repliesPage is available
          final canShowReplies = comment.replyCount != null &&
              comment.replyCount! > 0 &&
              comment.repliesPage != null;
          return _CommentTile(
            avatarUrl: comment.thumbnail,
            author: comment.author ?? widget.locals.commentAuthorNotFound,
            time: comment.commentedTime ?? '',
            text: comment.commentText ?? '',
            likeCount: comment.likeCount?.toString() ?? '0',
            theme: widget.theme,
            locals: widget.locals,
            replyCount: comment.replyCount,
            onReplyTap:
                canShowReplies ? () => _showReplies(context, comment) : null,
            isHearted: comment.hearted ?? false,
            isPinned: comment.pinned ?? false,
            isVerified: comment.verified ?? false,
          );
        },
      );
    }
  }
}

/// NewPipe replies sheet with pagination support
class _NewPipeRepliesSheet extends StatefulWidget {
  const _NewPipeRepliesSheet({
    required this.parentComment,
    required this.theme,
    required this.isDark,
    required this.locals,
    required this.videoId,
  });

  final NewPipeComment parentComment;
  final ThemeData theme;
  final bool isDark;
  final S locals;
  final String videoId;

  @override
  State<_NewPipeRepliesSheet> createState() => _NewPipeRepliesSheetState();
}

class _NewPipeRepliesSheetState extends State<_NewPipeRepliesSheet> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final state = context.read<WatchBloc>().state;
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        state.fetchMoreNewPipeCommentRepliesStatus != ApiStatus.loading &&
        state.newPipeCommentReplies.nextPage != null) {
      context.read<WatchBloc>().add(WatchEvent.getMoreNewPipeCommentReplies(
          videoId: widget.videoId,
          nextPage: state.newPipeCommentReplies.nextPage));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      builder: (context, sheetScrollController) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    S.of(context).repliesPlural(2),
                    style: widget.theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.xmark),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Parent comment
            Padding(
              padding: const EdgeInsets.all(16),
              child: _CommentTile(
                avatarUrl: widget.parentComment.authorAvatarUrl,
                author: widget.parentComment.authorName ??
                    widget.locals.commentAuthorNotFound,
                time: widget.parentComment.uploadDate ?? '',
                text: widget.parentComment.text ?? '',
                likeCount: widget.parentComment.likeCount?.toString() ?? '0',
                theme: widget.theme,
                locals: widget.locals,
                isHearted: widget.parentComment.isHearted ?? false,
                isPinned: widget.parentComment.isPinned ?? false,
                isVerified: widget.parentComment.authorVerified ?? false,
              ),
            ),
            const Divider(height: 1),
            // Replies list
            Expanded(
              child: BlocBuilder<WatchBloc, WatchState>(
                buildWhen: (previous, current) =>
                    previous.fetchNewPipeCommentRepliesStatus !=
                        current.fetchNewPipeCommentRepliesStatus ||
                    previous.fetchMoreNewPipeCommentRepliesStatus !=
                        current.fetchMoreNewPipeCommentRepliesStatus ||
                    previous.newPipeCommentReplies !=
                        current.newPipeCommentReplies,
                builder: (context, state) {
                  if (state.fetchNewPipeCommentRepliesStatus ==
                      ApiStatus.loading) {
                    return Center(child: cIndicator(context));
                  }

                  final replies = state.newPipeCommentReplies.comments ?? [];
                  if (replies.isEmpty) {
                    return Center(
                      child: Text(
                        'No replies',
                        style: widget.theme.textTheme.bodyMedium?.copyWith(
                          color: widget.theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }

                  final hasMore = state.newPipeCommentReplies.nextPage != null;
                  final isLoadingMore =
                      state.fetchMoreNewPipeCommentRepliesStatus ==
                          ApiStatus.loading;

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: replies.length + (hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= replies.length) {
                        return isLoadingMore
                            ? Padding(
                                padding: const EdgeInsets.all(16),
                                child: Center(child: cIndicator(context)),
                              )
                            : const SizedBox.shrink();
                      }
                      final reply = replies[index];
                      return _CommentTile(
                        avatarUrl: reply.authorAvatarUrl,
                        author: reply.authorName ??
                            widget.locals.commentAuthorNotFound,
                        time: reply.uploadDate ?? '',
                        text: reply.text ?? '',
                        likeCount: reply.likeCount?.toString() ?? '0',
                        theme: widget.theme,
                        locals: widget.locals,
                        isHearted: reply.isHearted ?? false,
                        isPinned: reply.isPinned ?? false,
                        isVerified: reply.authorVerified ?? false,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Piped replies sheet with pagination support
class _PipedRepliesSheet extends StatefulWidget {
  const _PipedRepliesSheet({
    required this.parentComment,
    required this.theme,
    required this.isDark,
    required this.locals,
    required this.videoId,
  });

  final Comment parentComment;
  final ThemeData theme;
  final bool isDark;
  final S locals;
  final String videoId;

  @override
  State<_PipedRepliesSheet> createState() => _PipedRepliesSheetState();
}

class _PipedRepliesSheetState extends State<_PipedRepliesSheet> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final state = context.read<WatchBloc>().state;
    final nextpage = state.commentReplies.nextpage;
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        state.fetchMoreCommentRepliesStatus != ApiStatus.loading &&
        !state.isMoreReplyCommentsFetchCompleted &&
        nextpage != null &&
        nextpage.isNotEmpty) {
      context.read<WatchBloc>().add(WatchEvent.getMoreReplyCommentsData(
          id: widget.videoId, nextPage: nextpage));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      builder: (context, sheetScrollController) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    S.of(context).repliesPlural(2),
                    style: widget.theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.xmark),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Parent comment
            Padding(
              padding: const EdgeInsets.all(16),
              child: _CommentTile(
                avatarUrl: widget.parentComment.thumbnail,
                author: widget.parentComment.author ??
                    widget.locals.commentAuthorNotFound,
                time: widget.parentComment.commentedTime ?? '',
                text: widget.parentComment.commentText ?? '',
                likeCount: widget.parentComment.likeCount?.toString() ?? '0',
                theme: widget.theme,
                locals: widget.locals,
                isHearted: widget.parentComment.hearted ?? false,
                isPinned: widget.parentComment.pinned ?? false,
                isVerified: widget.parentComment.verified ?? false,
              ),
            ),
            const Divider(height: 1),
            // Replies list
            Expanded(
              child: BlocBuilder<WatchBloc, WatchState>(
                buildWhen: (previous, current) =>
                    previous.fetchCommentRepliesStatus !=
                        current.fetchCommentRepliesStatus ||
                    previous.fetchMoreCommentRepliesStatus !=
                        current.fetchMoreCommentRepliesStatus ||
                    previous.commentReplies != current.commentReplies ||
                    previous.isMoreReplyCommentsFetchCompleted !=
                        current.isMoreReplyCommentsFetchCompleted,
                builder: (context, state) {
                  if (state.fetchCommentRepliesStatus == ApiStatus.loading) {
                    return Center(child: cIndicator(context));
                  }

                  final replies = state.commentReplies.comments;
                  if (replies.isEmpty) {
                    return Center(
                      child: Text(
                        'No replies',
                        style: widget.theme.textTheme.bodyMedium?.copyWith(
                          color: widget.theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }

                  final replyNextpage = state.commentReplies.nextpage;
                  final hasMore = !state.isMoreReplyCommentsFetchCompleted &&
                      replyNextpage != null &&
                      replyNextpage.isNotEmpty;
                  final isLoadingMore =
                      state.fetchMoreCommentRepliesStatus == ApiStatus.loading;

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: replies.length + (hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= replies.length) {
                        return isLoadingMore
                            ? Padding(
                                padding: const EdgeInsets.all(16),
                                child: Center(child: cIndicator(context)),
                              )
                            : const SizedBox.shrink();
                      }
                      final reply = replies[index];
                      return _CommentTile(
                        avatarUrl: reply.thumbnail,
                        author:
                            reply.author ?? widget.locals.commentAuthorNotFound,
                        time: reply.commentedTime ?? '',
                        text: reply.commentText ?? '',
                        likeCount: reply.likeCount?.toString() ?? '0',
                        theme: widget.theme,
                        locals: widget.locals,
                        isHearted: reply.hearted ?? false,
                        isPinned: reply.pinned ?? false,
                        isVerified: reply.verified ?? false,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HoldSpeedPill extends StatelessWidget {
  const _HoldSpeedPill();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '2x',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            SizedBox(width: 4),
            Icon(CupertinoIcons.forward_fill, color: Colors.white, size: 14),
          ],
        ),
      ),
    );
  }
}
