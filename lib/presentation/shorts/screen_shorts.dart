import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/colors.dart';
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
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
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
  });

  final List<ShortItem> shorts;
  final int initialIndex;

  @override
  State<ScreenShorts> createState() => _ScreenShortsState();
}

class _ScreenShortsState extends State<ScreenShorts> {
  late PageController _pageController;
  late List<_ShortVideoController> _controllers;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // Initialize controllers for each short
    _controllers = widget.shorts.map((short) => _ShortVideoController()).toList();

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
        leading: IconButton(
          icon: const Icon(CupertinoIcons.xmark, color: kWhiteColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          locals.shorts,
          style: const TextStyle(
            color: kWhiteColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: PageView.builder(
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
            onComment: () => _handleComment(short),
            onShare: () => _handleShare(short),
            onChannelTap: () => _handleChannelTap(short),
            onQualityTap: () => _showQualitySheet(controller),
          );
        },
      ),
    );
  }

  void _handleComment(ShortItem short) {
    _showCommentsSheet(short);
  }

  void _showCommentsSheet(ShortItem short) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
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
                  color: AppColors.disabled,
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
                      'Comments',
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
                    final isLoading = watchState.fetchCommentsStatus == ApiStatus.loading ||
                        watchState.fetchNewPipeCommentsStatus == ApiStatus.loading ||
                        watchState.fetchInvidiousCommentsStatus == ApiStatus.loading;

                    if (isLoading) {
                      return Center(child: cIndicator(context));
                    }

                    // Get comments from the appropriate source
                    final pipedComments = watchState.comments.comments;
                    final newPipeComments = watchState.newPipeComments.comments ?? [];
                    final invidiousComments = watchState.invidiousComments.comments ?? [];

                    // Use whichever has data
                    final hasComments = pipedComments.isNotEmpty ||
                        newPipeComments.isNotEmpty ||
                        invidiousComments.isNotEmpty;

                    if (!hasComments) {
                      return Center(
                        child: Text(
                          locals.noCommentsFound,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.disabled,
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
    if (controller.availableQualities == null || controller.availableQualities!.isEmpty) {
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF212121),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(CupertinoIcons.xmark, color: kWhiteColor, size: 20),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Quality',
                    style: TextStyle(
                      color: kWhiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            // Quality options - constrained height
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: controller.availableQualities!.length,
                itemBuilder: (context, index) {
                  final quality = controller.availableQualities![index];
                  final isSelected = quality.label == controller.currentQuality;
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        controller.changeQuality(quality.label);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 24,
                              child: isSelected
                                  ? const Icon(CupertinoIcons.checkmark, color: kWhiteColor, size: 16)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                quality.label,
                                style: TextStyle(
                                  color: isSelected ? kWhiteColor : Colors.white70,
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (quality.fps != null && quality.fps! > 30)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${quality.fps}fps',
                                  style: const TextStyle(color: kWhiteColor, fontSize: 10),
                                ),
                              ),
                          ],
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
      ),
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

  const _ShortVideoPage({
    required this.short,
    required this.controller,
    required this.isActive,
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
        if (controller.isInitialized && isActive)
          GestureDetector(
            onTap: () => controller.togglePlayPause(),
            child: Video(
              controller: controller.videoController!,
              fit: BoxFit.cover,
              controls: NoVideoControls,
            ),
          )
        else if (short.thumbnailUrl != null)
          ThumbnailImage.small(url: short.thumbnailUrl!)
        else
          Container(color: kBlackColor),

        // Loading indicator - only show when loading AND not initialized
        if (isActive && controller.isLoading && !controller.isInitialized)
          const Center(
            child: CircularProgressIndicator(color: kWhiteColor),
          ),

        // Buffering indicator - only show when buffering during playback
        if (isActive && controller.isInitialized && controller.isBuffering)
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
        if (controller.isInitialized && !controller.isPlaying && isActive && !controller.isLoading && !controller.isBuffering)
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
          child: Container(
            height: 200,
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

        // Progress bar at bottom
        if (controller.isInitialized && isActive)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _VideoProgressBar(controller: controller),
          ),

        // Quality badge (top right, below app bar)
        if (controller.isInitialized && controller.currentQuality != null)
          Positioned(
            top: 100,
            right: 12,
            child: GestureDetector(
              onTap: onQualityTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: kBlackColor.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      controller.currentQuality!,
                      style: const TextStyle(
                        color: kWhiteColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      CupertinoIcons.chevron_down,
                      color: kWhiteColor,
                      size: 12,
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Right side action buttons
        Positioned(
          right: 12,
          bottom: 100,
          child: Column(
            children: [
              // Like count display
              _ActionButton(
                icon: CupertinoIcons.heart_fill,
                label: controller.likeCount != null
                    ? (controller.likeCount == -1 ? locals.like : formatCount(controller.likeCount.toString()))
                    : (short.likeCount != null
                        ? (short.likeCount == -1 ? locals.like : formatCount(short.likeCount.toString()))
                        : ''),
                onTap: () {},
                isActive: true,
              ),
              const SizedBox(height: 20),
              // View count display
              _ActionButton(
                icon: CupertinoIcons.eye_fill,
                label: controller.viewCount != null
                    ? formatCount(controller.viewCount.toString())
                    : (short.viewCount != null ? formatCount(short.viewCount.toString()) : ''),
                onTap: () {},
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
            ],
          ),
        ),

        // Bottom info
        Positioned(
          bottom: 30,
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
                    _buildChannelAvatar(controller.uploaderAvatar ?? short.uploaderAvatar),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  controller.uploaderName ?? short.uploaderName ?? locals.noUploaderName,
                                  style: const TextStyle(
                                    color: kWhiteColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (controller.uploaderVerified == true || short.uploaderVerified == true) ...[
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
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _durationSub;
  Player? _lastPlayer;

  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  void _setupListeners() {
    final player = widget.controller.player;

    // Only re-setup if player has changed
    if (player == _lastPlayer && _positionSub != null) {
      return;
    }

    _positionSub?.cancel();
    _durationSub?.cancel();
    _lastPlayer = player;

    // Reset values when switching to new player
    _position = Duration.zero;
    _duration = Duration.zero;

    if (player != null) {
      // Get initial values first
      _position = player.state.position;
      _duration = player.state.duration;

      _positionSub = player.stream.position.listen((pos) {
        if (mounted) setState(() => _position = pos);
      });
      _durationSub = player.stream.duration.listen((dur) {
        if (mounted) setState(() => _duration = dur);
      });
    }
  }

  @override
  void didUpdateWidget(covariant _VideoProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Always check if player has changed
    if (widget.controller.player != _lastPlayer) {
      _setupListeners();
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _duration.inMilliseconds > 0
        ? _position.inMilliseconds / _duration.inMilliseconds
        : 0.0;

    return SizedBox(
      height: 3,
      child: LinearProgressIndicator(
        value: progress.clamp(0.0, 1.0),
        backgroundColor: kWhiteColor.withValues(alpha: 0.3),
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        minHeight: 3,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
              color: isActive ? AppColors.youtubeRed : kWhiteColor,
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
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          ClipOval(
            child: avatarUrl != null
                ? ThumbnailImage.small(
                    url: avatarUrl!,
                    width: 32,
                    height: 32,
                    errorWidget: (_, __, ___) => Container(
                      width: 32,
                      height: 32,
                      color: AppColors.surfaceVariant,
                      child: const Icon(CupertinoIcons.person_fill, size: 16),
                    ),
                  )
                : Container(
                    width: 32,
                    height: 32,
                    color: AppColors.surfaceVariant,
                    child: const Icon(CupertinoIcons.person_fill, size: 16),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author, time & badges
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Text(
                      author,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.onSurfaceVariantDark
                            : AppColors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Verified badge
                    if (isVerified)
                      Icon(
                        CupertinoIcons.checkmark_seal_fill,
                        size: 12,
                        color: AppColors.primary,
                      ),
                    if (time.isNotEmpty)
                      Text(
                        time,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.disabled,
                          fontSize: 11,
                        ),
                      ),
                    // Hearted badge
                    if (isHearted)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.red.shade400,
                              Colors.pink.shade400,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.heart_fill,
                              size: 10,
                              color: Colors.white,
                            ),
                            SizedBox(width: 3),
                            Text(
                              'Liked',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Pinned badge
                    if (isPinned)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.pin_fill,
                              size: 10,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              locals.pinned,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                // Comment text with HTML formatting
                RichReadMoreText(
                  HTML.toTextSpan(
                    context,
                    // Decode HTML entities
                    text
                        .replaceAll('&amp;', '&')
                        .replaceAll('&lt;', '<')
                        .replaceAll('&gt;', '>')
                        .replaceAll('&quot;', '"')
                        .replaceAll('&#39;', "'")
                        .replaceAll('&nbsp;', ' '),
                    defaultTextStyle: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                  settings: LineModeSettings(
                    trimLines: 4,
                    trimCollapsedText: ' ${locals.readMoreText}',
                    trimExpandedText: ' ${locals.showLessText}',
                    moreStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                    lessStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Like count and reply button
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.hand_thumbsup,
                      size: 14,
                      color: AppColors.disabled,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formatCount(likeCount),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.disabled,
                        fontSize: 11,
                      ),
                    ),
                    // Reply button - show if replyCount > 0 and onReplyTap is provided
                    if (replyCount != null && replyCount! > 0 && onReplyTap != null) ...[
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: onReplyTap,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.arrowtriangle_down_fill,
                                size: 10,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${formatCount(replyCount.toString())} ${locals.repliesPlural(replyCount!)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
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
  Player? _player;
  VideoController? _videoController;
  NewPipeWatchResp? _watchResp;
  PlaybackConfiguration? _currentConfig;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _isBuffering = false;
  bool _hasError = false;
  bool _shouldPlay = false; // Track if this controller should play when ready (default false)
  bool _isInitializing = false; // Prevent concurrent initialization

  // Quality
  List<StreamQualityInfo>? _availableQualities;
  String? _currentQuality;

  // Audio URL for re-setting on loop
  String? _audioUrl;
  StreamSubscription<bool>? _completedSubscription;

  // Video info from API
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
  VideoController? get videoController => _videoController;
  Player? get player => _player;

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
      // Fetch video info using NewPipe
      _watchResp = await NewPipeChannel.getStreamInfo(videoId);

      // Extract video metadata
      _title = _watchResp!.title;
      _uploaderName = _watchResp!.uploaderName;
      _uploaderAvatar = _watchResp!.uploaderAvatarUrl;
      _uploaderId = _extractChannelId(_watchResp!.uploaderUrl);
      _uploaderVerified = _watchResp!.uploaderVerified;
      _likeCount = _watchResp!.likeCount;
      _viewCount = _watchResp!.viewCount;

      // Get available qualities
      _availableQualities = NewPipeStreamHelper.getAvailableQualities(_watchResp!);

      // Get playable stream URL using resolver
      final resolver = NewPipePlaybackResolver();
      _currentConfig = resolver.resolve(
        watchResp: _watchResp!,
        preferredQuality: '720p',
        preferHighQuality: false,
      );

      _currentQuality = _currentConfig!.qualityLabel;

      if (!_currentConfig!.isValid) {
        _hasError = true;
        _isLoading = false;
        notifyListeners();
        return;
      }

      _player = Player();
      _videoController = VideoController(_player!);

      // Listen to player state
      _player!.stream.playing.listen((playing) {
        _isPlaying = playing;
        notifyListeners();
      });

      _player!.stream.buffering.listen((buffering) {
        _isBuffering = buffering;
        notifyListeners();
      });

      // Setup media source based on type
      await _setupMediaSource(_currentConfig!);

      // For merging source type, listen for completion to re-set audio on loop
      if (_currentConfig!.sourceType == MediaSourceType.merging && _audioUrl != null) {
        _setupCompletedListener();
      }

      await _player!.setPlaylistMode(PlaylistMode.loop);

      _isInitialized = true;
      _isInitializing = false;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing short video: $e');
      _hasError = true;
      _isInitializing = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Listen to completed stream to re-set audio when video loops
  void _setupCompletedListener() {
    _completedSubscription?.cancel();
    _completedSubscription = _player!.stream.completed.listen((completed) async {
      if (completed && _audioUrl != null) {
        // Video completed (will loop due to PlaylistMode.loop)
        // Re-set audio track immediately
        debugPrint('[Shorts] Video completed, re-setting audio track for loop');
        try {
          // Small delay to ensure the loop has started
          await Future.delayed(const Duration(milliseconds: 50));
          await _player!.setAudioTrack(AudioTrack.uri(_audioUrl!));
        } catch (e) {
          debugPrint('[Shorts] Error re-setting audio on loop: $e');
        }
      }
    });
  }

  Future<void> _setupMediaSource(PlaybackConfiguration config) async {
    switch (config.sourceType) {
      case MediaSourceType.progressive:
        // Muxed stream (has audio) - open without auto-play, then play if shouldPlay
        await _player!.open(
          Media(
            config.videoUrl!,
            httpHeaders: {
              'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            },
          ),
          play: false,
        );
        if (_shouldPlay) {
          await _player!.play();
        }
        debugPrint('[Shorts] Opened progressive stream, shouldPlay: $_shouldPlay');
        break;

      case MediaSourceType.merging:
        // Separate video + audio
        _audioUrl = _selectMediumQualityAudio();

        await _player!.open(
          Media(
            config.videoUrl!,
            httpHeaders: {
              'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            },
          ),
          play: false,
        );

        await Future.delayed(const Duration(milliseconds: 100));

        if (_audioUrl != null) {
          try {
            await _player!.setAudioTrack(AudioTrack.uri(_audioUrl!));
            debugPrint('[Shorts] Opened video + audio');
          } catch (e) {
            debugPrint('[Shorts] Error setting audio track: $e');
          }
        }

        if (_shouldPlay) {
          await _player!.play();
        }
        debugPrint('[Shorts] Merging stream ready, shouldPlay: $_shouldPlay');
        break;

      case MediaSourceType.hls:
        await _player!.open(Media(config.manifestUrl!), play: false);
        if (_shouldPlay) {
          await _player!.play();
        }
        debugPrint('[Shorts] Opened HLS stream, shouldPlay: $_shouldPlay');
        break;

      case MediaSourceType.dash:
        await _player!.open(Media(config.manifestUrl!), play: false);
        if (_shouldPlay) {
          await _player!.play();
        }
        debugPrint('[Shorts] Opened DASH stream, shouldPlay: $_shouldPlay');
        break;
    }
  }

  /// Select medium-quality original audio stream
  String? _selectMediumQualityAudio() {
    final audioStreams = _watchResp?.audioStreams ?? [];
    if (audioStreams.isEmpty) return null;

    // Filter to only original audio streams
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

    // Find audio around 128kbps
    const targetBitrate = 128;
    NewPipeAudioStream? selectedAudio = candidateStreams.first;
    int smallestDiff = 999999;

    for (var audio in candidateStreams) {
      final bitrate = audio.averageBitrate ?? 0;
      final diff = (bitrate - targetBitrate).abs();
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
    if (_isInitialized) return;
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
      _availableQualities = NewPipeStreamHelper.getAvailableQualities(watchResp);
    } catch (e) {
      debugPrint('Error preloading short: $e');
    }
  }

  Future<void> changeQuality(String newQuality) async {
    if (_currentQuality == newQuality || _watchResp == null) return;

    _isBuffering = true;
    notifyListeners();

    try {
      // Save current position BEFORE any changes
      final currentPosition = _player!.state.position;
      final wasPlaying = _player!.state.playing;

      debugPrint('[Shorts] Changing quality from $_currentQuality to $newQuality at position: ${currentPosition.inSeconds}s');

      // Resolve new configuration
      final resolver = NewPipePlaybackResolver();
      final newConfig = resolver.resolve(
        watchResp: _watchResp!,
        preferredQuality: newQuality,
        preferHighQuality: true,
      );

      if (!newConfig.isValid) {
        _isBuffering = false;
        notifyListeners();
        return;
      }

      // Pause current playback first
      await _player!.pause();

      // Setup new media source (this opens the new stream)
      await _setupMediaSourceWithPosition(newConfig, currentPosition, wasPlaying);

      // Re-setup completed listener if merging
      if (newConfig.sourceType == MediaSourceType.merging && _audioUrl != null) {
        _setupCompletedListener();
      }

      _currentConfig = newConfig;
      _currentQuality = newQuality;
      _isBuffering = false;
      notifyListeners();

      debugPrint('[Shorts] Quality changed to: $newQuality');
    } catch (e) {
      debugPrint('[Shorts] Error changing quality: $e');
      _isBuffering = false;
      notifyListeners();
    }
  }

  Future<void> _setupMediaSourceWithPosition(PlaybackConfiguration config, Duration seekPosition, bool shouldPlay) async {
    switch (config.sourceType) {
      case MediaSourceType.progressive:
        // Muxed stream (has audio)
        await _player!.open(
          Media(
            config.videoUrl!,
            httpHeaders: {
              'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            },
          ),
          play: false,
        );
        // Wait for media to be ready
        await Future.delayed(const Duration(milliseconds: 200));
        // Seek to position
        if (seekPosition.inMilliseconds > 0) {
          await _player!.seek(seekPosition);
          await Future.delayed(const Duration(milliseconds: 100));
        }
        if (shouldPlay) {
          await _player!.play();
        }
        debugPrint('[Shorts] Opened progressive stream at ${seekPosition.inSeconds}s');
        break;

      case MediaSourceType.merging:
        // Separate video + audio
        _audioUrl = _selectMediumQualityAudio();

        await _player!.open(
          Media(
            config.videoUrl!,
            httpHeaders: {
              'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            },
          ),
          play: false,
        );

        await Future.delayed(const Duration(milliseconds: 150));

        if (_audioUrl != null) {
          try {
            await _player!.setAudioTrack(AudioTrack.uri(_audioUrl!));
          } catch (e) {
            debugPrint('[Shorts] Error setting audio track: $e');
          }
        }

        await Future.delayed(const Duration(milliseconds: 100));

        // Seek to position
        if (seekPosition.inMilliseconds > 0) {
          await _player!.seek(seekPosition);
          await Future.delayed(const Duration(milliseconds: 100));
        }

        if (shouldPlay) {
          await _player!.play();
        }
        debugPrint('[Shorts] Opened video + audio at ${seekPosition.inSeconds}s');
        break;

      case MediaSourceType.hls:
        await _player!.open(Media(config.manifestUrl!), play: false);
        await Future.delayed(const Duration(milliseconds: 200));
        if (seekPosition.inMilliseconds > 0) {
          await _player!.seek(seekPosition);
          await Future.delayed(const Duration(milliseconds: 100));
        }
        if (shouldPlay) {
          await _player!.play();
        }
        debugPrint('[Shorts] Opened HLS stream at ${seekPosition.inSeconds}s');
        break;

      case MediaSourceType.dash:
        await _player!.open(Media(config.manifestUrl!), play: false);
        await Future.delayed(const Duration(milliseconds: 200));
        if (seekPosition.inMilliseconds > 0) {
          await _player!.seek(seekPosition);
          await Future.delayed(const Duration(milliseconds: 100));
        }
        if (shouldPlay) {
          await _player!.play();
        }
        debugPrint('[Shorts] Opened DASH stream at ${seekPosition.inSeconds}s');
        break;
    }
  }

  Future<void> retry(String videoId, BuildContext context) async {
    _hasError = false;
    _isInitialized = false;
    _completedSubscription?.cancel();
    _player?.dispose();
    _player = null;
    _videoController = null;
    _audioUrl = null;
    notifyListeners();
    await initialize(videoId, context);
  }

  void togglePlayPause() {
    if (_player != null) {
      _player!.playOrPause();
    }
  }

  void setShouldPlay(bool value) {
    _shouldPlay = value;
  }

  void play() {
    _shouldPlay = true;
    if (_player != null && !_isPlaying) {
      _player!.play();
    }
  }

  void pause() {
    _shouldPlay = false;
    if (_player != null && _isPlaying) {
      _player!.pause();
    }
  }

  @override
  void dispose() {
    _completedSubscription?.cancel();
    _player?.dispose();
    _player = null;
    _videoController = null;
    _isInitialized = false;
    super.dispose();
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
              id: widget.videoId, continuation: state.invidiousComments.continuation!));
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
    debugPrint('[Shorts] _showReplies called: commentId=${comment.commentId}, repliesPage=${comment.repliesPage}');
    if (comment.commentId != null && comment.repliesPage != null) {
      context.read<WatchBloc>().add(WatchEvent.getCommentRepliesData(
          id: comment.commentId!, nextPage: comment.repliesPage!));
      _showRepliesSheet(context, comment);
    } else {
      debugPrint('[Shorts] Cannot show replies: commentId or repliesPage is null');
    }
  }

  void _showNewPipeReplies(BuildContext context, NewPipeComment comment) {
    debugPrint('[Shorts] _showNewPipeReplies called: repliesPage=${comment.repliesPage}');
    if (comment.repliesPage != null) {
      context.read<WatchBloc>().add(WatchEvent.getNewPipeCommentReplies(
          videoId: widget.videoId, repliesPage: comment.repliesPage!));
      _showNewPipeRepliesSheet(context, comment);
    } else {
      debugPrint('[Shorts] Cannot show NewPipe replies: repliesPage is null');
    }
  }

  void _showNewPipeRepliesSheet(BuildContext context, NewPipeComment parentComment) {
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
      final isLoadingMore = state.fetchMoreNewPipeCommentsStatus == ApiStatus.loading;
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
      final isLoadingMore = state.fetchMoreInvidiousCommentsStatus == ApiStatus.loading;
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
            onReplyTap: canShowReplies
                ? () => _showReplies(context, comment)
                : null,
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
          color: widget.isDark ? AppColors.surfaceDark : AppColors.surface,
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
                color: AppColors.disabled,
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
                    'Replies',
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
                author: widget.parentComment.authorName ?? widget.locals.commentAuthorNotFound,
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
                    previous.fetchNewPipeCommentRepliesStatus != current.fetchNewPipeCommentRepliesStatus ||
                    previous.fetchMoreNewPipeCommentRepliesStatus != current.fetchMoreNewPipeCommentRepliesStatus ||
                    previous.newPipeCommentReplies != current.newPipeCommentReplies,
                builder: (context, state) {
                  if (state.fetchNewPipeCommentRepliesStatus == ApiStatus.loading) {
                    return Center(child: cIndicator(context));
                  }

                  final replies = state.newPipeCommentReplies.comments ?? [];
                  if (replies.isEmpty) {
                    return Center(
                      child: Text(
                        'No replies',
                        style: widget.theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.disabled,
                        ),
                      ),
                    );
                  }

                  final hasMore = state.newPipeCommentReplies.nextPage != null;
                  final isLoadingMore = state.fetchMoreNewPipeCommentRepliesStatus == ApiStatus.loading;

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
                        author: reply.authorName ?? widget.locals.commentAuthorNotFound,
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
          color: widget.isDark ? AppColors.surfaceDark : AppColors.surface,
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
                color: AppColors.disabled,
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
                    'Replies',
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
                author: widget.parentComment.author ?? widget.locals.commentAuthorNotFound,
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
                    previous.fetchCommentRepliesStatus != current.fetchCommentRepliesStatus ||
                    previous.fetchMoreCommentRepliesStatus != current.fetchMoreCommentRepliesStatus ||
                    previous.commentReplies != current.commentReplies ||
                    previous.isMoreReplyCommentsFetchCompleted != current.isMoreReplyCommentsFetchCompleted,
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
                          color: AppColors.disabled,
                        ),
                      ),
                    );
                  }

                  final replyNextpage = state.commentReplies.nextpage;
                  final hasMore = !state.isMoreReplyCommentsFetchCompleted &&
                      replyNextpage != null &&
                      replyNextpage.isNotEmpty;
                  final isLoadingMore = state.fetchMoreCommentRepliesStatus == ApiStatus.loading;

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
                        author: reply.author ?? widget.locals.commentAuthorNotFound,
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
