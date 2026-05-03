import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluxtube/widgets/thumbnail_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/watch/watch_bloc.dart';
import 'package:fluxtube/core/animations/animations.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/core/operations/math_operations.dart';
import 'package:fluxtube/domain/watch/models/basic_info.dart';
import 'package:fluxtube/domain/watch/models/newpipe/newpipe_related.dart';
import 'package:fluxtube/domain/watch/models/newpipe/newpipe_watch_resp.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/presentation/search/widgets/newpipe/home_video_info_card_widget.dart';
import 'package:fluxtube/presentation/shorts/screen_shorts.dart';
import 'package:go_router/go_router.dart';

class NewPipeRelatedVideoSection extends StatelessWidget {
  const NewPipeRelatedVideoSection({
    super.key,
    required this.locals,
    required this.watchInfo,
  });

  final S locals;
  final NewPipeWatchResp watchInfo;

  @override
  Widget build(BuildContext context) {
    final allRelated = watchInfo.relatedStreams ?? [];

    if (allRelated.isEmpty) {
      return const SizedBox();
    }

    // Separate shorts and regular videos
    final shorts = allRelated.where((v) => v.isShort == true).toList();
    final videos = allRelated.where((v) => v.isShort != true).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Shorts section if available
        if (shorts.isNotEmpty) ...[
          _ShortsSection(shorts: shorts, locals: locals),
          AppSpacing.height20,
        ],

        // Related Videos section
        if (videos.isNotEmpty)
          _RelatedVideosSection(videos: videos, locals: locals),
      ],
    );
  }
}

// ============================================================================
// SHORTS SECTION
// ============================================================================

class _ShortsSection extends StatelessWidget {
  const _ShortsSection({
    required this.shorts,
    required this.locals,
  });

  final List<NewPipeRelatedStream> shorts;
  final S locals;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final shortItems = shorts
        .map((s) => ShortItem(
              id: _extractVideoId(s.url) ?? '',
              title: s.name,
              thumbnailUrl: s.thumbnailUrl,
              uploaderName: s.uploaderName,
              uploaderAvatar: s.uploaderAvatarUrl,
              uploaderId: _extractChannelId(s.uploaderUrl),
              viewCount: s.viewCount,
              duration: s.duration,
              uploaderVerified: s.uploaderVerified,
            ))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              // Shorts icon with gradient background
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.youtubeRed,
                      AppColors.youtubeRed.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  CupertinoIcons.play_rectangle_fill,
                  color: kWhiteColor,
                  size: 16,
                ),
              ),
              AppSpacing.width12,
              Text(
                locals.shorts,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              // Count badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceVariantDark
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${shorts.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.onSurfaceVariantDark
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
        AppSpacing.height12,

        // Shorts horizontal list
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: shortItems.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index < shortItems.length - 1 ? 12 : 0,
                ),
                child: _ShortCard(
                  short: shortItems[index],
                  index: index,
                  onTap: () => _openShorts(context, shortItems, index),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _openShorts(BuildContext context, List<ShortItem> items, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ScreenShorts(
          shorts: items,
          initialIndex: index,
        ),
      ),
    );
  }
}

class _ShortCard extends StatelessWidget {
  const _ShortCard({
    required this.short,
    required this.index,
    required this.onTap,
  });

  final ShortItem short;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedListItem(
      index: index,
      child: ScaleTap(
        onTap: onTap,
        scaleDown: 0.95,
        child: Container(
          width: 130,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Thumbnail
                _buildThumbnail(isDark),

                // Gradient overlay
                _buildGradientOverlay(),

                // Shorts badge
                _buildShortsBadge(),

                // View count
                if (short.viewCount != null) _buildViewCount(),

                // Title
                _buildTitle(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(bool isDark) {
    if (short.thumbnailUrl != null) {
      return ThumbnailImage.small(url: short.thumbnailUrl!);
    }
    return Container(
      color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.3, 0.7, 1.0],
          colors: [
            kBlackColor.withValues(alpha: 0.3),
            Colors.transparent,
            Colors.transparent,
            kBlackColor.withValues(alpha: 0.85),
          ],
        ),
      ),
    );
  }

  Widget _buildShortsBadge() {
    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.youtubeRed,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.bolt_fill,
              color: kWhiteColor,
              size: 10,
            ),
            SizedBox(width: 3),
            Text(
              'SHORT',
              style: TextStyle(
                color: kWhiteColor,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewCount() {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: kBlackColor.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              CupertinoIcons.eye_fill,
              color: kWhiteColor,
              size: 10,
            ),
            const SizedBox(width: 3),
            Text(
              formatCount(short.viewCount.toString()),
              style: const TextStyle(
                color: kWhiteColor,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Positioned(
      bottom: 10,
      left: 10,
      right: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            short.title ?? '',
            style: const TextStyle(
              color: kWhiteColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.3,
              shadows: [
                Shadow(
                  color: Colors.black54,
                  blurRadius: 4,
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (short.uploaderName != null) ...[
            const SizedBox(height: 4),
            Text(
              short.uploaderName!,
              style: TextStyle(
                color: kWhiteColor.withValues(alpha: 0.8),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================================
// RELATED VIDEOS SECTION - Large Thumbnail Card Layout
// ============================================================================

class _RelatedVideosSection extends StatelessWidget {
  const _RelatedVideosSection({
    required this.videos,
    required this.locals,
  });

  final List<NewPipeRelatedStream> videos;
  final S locals;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              // Icon with subtle background
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  CupertinoIcons.play_circle_fill,
                  color: AppColors.primary,
                  size: 16,
                ),
              ),
              AppSpacing.width12,
              Text(
                locals.relatedTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              // Count badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceVariantDark
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${videos.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.onSurfaceVariantDark
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
        AppSpacing.height16,

        // Videos list - Large card layout
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: videos.length,
          itemBuilder: (context, index) {
            return _LargeVideoCard(
              video: videos[index],
              index: index,
              locals: locals,
            );
          },
        ),
      ],
    );
  }
}

// Large thumbnail card with details below
class _LargeVideoCard extends StatelessWidget {
  const _LargeVideoCard({
    required this.video,
    required this.index,
    required this.locals,
  });

  final NewPipeRelatedStream video;
  final int index;
  final S locals;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final videoId = _extractVideoId(video.url) ?? '';
    final channelId = _extractChannelId(video.uploaderUrl) ?? '';

    if (videoId.isEmpty) return const SizedBox.shrink();

    return AnimatedListItem(
      index: index,
      child: ScaleTap(
        onTap: () => _navigateToVideo(context, videoId, channelId),
        scaleDown: 0.98,
        child: Container(
          margin: const EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : kWhiteColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Large Thumbnail
              _buildThumbnail(isDark),

              // Details section
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      video.name ?? locals.noVideoTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 12),

                    // Channel info row
                    Row(
                      children: [
                        // Channel avatar
                        if (video.uploaderAvatarUrl != null)
                          Container(
                            width: 32,
                            height: 32,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.black.withValues(alpha: 0.05),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: ThumbnailImage.small(
                                url: video.uploaderAvatarUrl!,
                                errorWidget: (_, __, ___) => ColoredBox(
                                  color: AppColors.surfaceVariant,
                                  child: const Icon(
                                    CupertinoIcons.person_fill,
                                    size: 16,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      video.uploaderName ?? locals.noUploaderName,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? AppColors.onSurfaceDark
                                            : AppColors.onSurface,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (video.uploaderVerified == true)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: Icon(
                                        CupertinoIcons.checkmark_seal_fill,
                                        size: 14,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              // Stats row
                              Row(
                                children: [
                                  if (video.viewCount != null) ...[
                                    Text(
                                      '${formatCount(video.viewCount.toString())} views',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: isDark
                                            ? AppColors.onSurfaceVariantDark
                                            : AppColors.onSurfaceVariant,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                  if (video.viewCount != null && video.uploadDate != null)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 6),
                                      child: Text(
                                        '•',
                                        style: TextStyle(
                                          color: isDark
                                              ? AppColors.onSurfaceVariantDark
                                              : AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  if (video.uploadDate != null)
                                    Flexible(
                                      child: Text(
                                        video.uploadDate!,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: isDark
                                              ? AppColors.onSurfaceVariantDark
                                              : AppColors.onSurfaceVariant,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(bool isDark) {
    final isLive = video.isLive == true;
    final duration = video.duration ?? 0;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            if (video.thumbnailUrl != null)
              ThumbnailImage.small(url: video.thumbnailUrl!)
            else
              Container(
                color: isDark
                    ? AppColors.surfaceVariantDark
                    : AppColors.surfaceVariant,
              ),

            // Subtle gradient for depth
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      kBlackColor.withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
            ),

            // Duration or Live badge
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isLive
                      ? AppColors.youtubeRed
                      : kBlackColor.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLive) ...[
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(right: 5),
                        decoration: const BoxDecoration(
                          color: kWhiteColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                    Text(
                      isLive ? 'LIVE' : formatDuration(duration),
                      style: const TextStyle(
                        color: kWhiteColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content availability badge (top left)
            if (video.contentAvailability != null)
              Positioned(
                top: 10,
                left: 10,
                child: ContentAvailabilityBadge(
                  availability: video.contentAvailability!,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _navigateToVideo(BuildContext context, String videoId, String channelId) {
    BlocProvider.of<WatchBloc>(context).add(
      WatchEvent.setSelectedVideoBasicDetails(
        details: VideoBasicInfo(
          id: videoId,
          title: video.name,
          thumbnailUrl: video.thumbnailUrl,
          channelName: video.uploaderName,
          channelThumbnailUrl: video.uploaderAvatarUrl,
          channelId: channelId,
          uploaderVerified: video.uploaderVerified,
        ),
      ),
    );
    context.pushReplacementNamed('watch', pathParameters: {
      'videoId': videoId,
      'channelId': channelId,
    });
  }
}

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

String? _extractVideoId(String? url) {
  if (url == null) return null;
  final uri = Uri.tryParse(url);
  if (uri != null) {
    if (uri.queryParameters.containsKey('v')) {
      return uri.queryParameters['v'];
    }
    if (uri.host == 'youtu.be' && uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.first;
    }
  }
  return null;
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
