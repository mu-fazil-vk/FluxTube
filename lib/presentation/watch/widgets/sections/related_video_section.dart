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
import 'package:fluxtube/domain/watch/models/piped/video/watch_resp.dart';
import 'package:fluxtube/domain/watch/models/piped/video/related_stream.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/presentation/shorts/screen_shorts.dart';
import 'package:go_router/go_router.dart';

class RelatedVideoSection extends StatelessWidget {
  const RelatedVideoSection({
    super.key,
    required this.locals,
    required this.watchInfo,
  });

  final S locals;
  final WatchResp watchInfo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Separate shorts and regular videos
    final allRelated = watchInfo.relatedStreams ?? [];
    final shorts = allRelated.where((v) => v.isShort == true).toList();
    final videos = allRelated.where((v) => v.isShort != true).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Shorts section if available
        if (shorts.isNotEmpty) ...[
          _RelatedShortsSection(
            shorts: shorts,
            locals: locals,
          ),
          AppSpacing.height16,
        ],

        // Related Videos Header
        if (videos.isNotEmpty) ...[
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
          // Related Videos List - Large card layout
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final related = videos[index];
              return _RelatedVideoCard(
                related: related,
                watchInfo: watchInfo,
                locals: locals,
                index: index,
              );
            },
          ),
        ],
      ],
    );
  }
}

class _RelatedShortsSection extends StatelessWidget {
  const _RelatedShortsSection({
    required this.shorts,
    required this.locals,
  });

  final List<RelatedStream> shorts;
  final S locals;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Convert to ShortItem list
    final shortItems = shorts.map((s) => ShortItem(
      id: s.url?.split('=').last ?? '',
      title: s.title,
      thumbnailUrl: s.thumbnail,
      uploaderName: s.uploaderName,
      uploaderAvatar: s.uploaderAvatar,
      uploaderId: s.uploaderUrl?.split('/').last,
      viewCount: s.views,
      duration: s.duration,
      uploaderVerified: s.uploaderVerified,
    )).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  CupertinoIcons.play_rectangle_fill,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              AppSpacing.width8,
              Text(
                locals.shorts,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        AppSpacing.height12,
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: shortItems.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return _ShortThumbnailCard(
                short: shortItems[index],
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ScreenShorts(
                        shorts: shortItems,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ShortThumbnailCard extends StatelessWidget {
  const _ShortThumbnailCard({
    required this.short,
    required this.onTap,
  });

  final ShortItem short;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Thumbnail
              if (short.thumbnailUrl != null)
                ThumbnailImage.small(url: short.thumbnailUrl!)
              else
                ColoredBox(
                  color: isDark
                      ? AppColors.surfaceVariantDark
                      : AppColors.surfaceVariant,
                ),

              // Gradient overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        kBlackColor.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
              ),

              // Play icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kBlackColor.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.play_fill,
                    color: kWhiteColor,
                    size: 20,
                  ),
                ),
              ),

              // Title at bottom
              Positioned(
                bottom: 6,
                left: 6,
                right: 6,
                child: Text(
                  short.title ?? '',
                  style: const TextStyle(
                    color: kWhiteColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Large thumbnail card with details below - matches NewPipe design
class _RelatedVideoCard extends StatelessWidget {
  const _RelatedVideoCard({
    required this.related,
    required this.watchInfo,
    required this.locals,
    required this.index,
  });

  final RelatedStream related;
  final WatchResp watchInfo;
  final S locals;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final videoId = related.url?.split('=').last ?? '';
    final channelId = related.uploaderUrl?.split('/').last ??
        watchInfo.uploaderUrl?.split('/').last ??
        '';

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
                      related.title ?? locals.noVideoTitle,
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
                        if (related.uploaderAvatar != null)
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
                                url: related.uploaderAvatar!,
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
                                      related.uploaderName ?? locals.noUploaderName,
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
                                  if (related.uploaderVerified == true)
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
                              if (related.views != null)
                                Text(
                                  '${formatCount(related.views.toString())} views',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isDark
                                        ? AppColors.onSurfaceVariantDark
                                        : AppColors.onSurfaceVariant,
                                    fontWeight: FontWeight.w400,
                                  ),
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
    final duration = related.duration ?? 0;

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
            if (related.thumbnail != null)
              ThumbnailImage.small(url: related.thumbnail!)
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

            // Duration badge
            if (duration > 0)
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: kBlackColor.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    formatDuration(duration),
                    style: const TextStyle(
                      color: kWhiteColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
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
          title: related.title,
          thumbnailUrl: related.thumbnail,
          channelName: related.uploaderName,
          channelThumbnailUrl: related.uploaderAvatar,
          channelId: channelId,
          uploaderVerified: related.uploaderVerified,
        ),
      ),
    );
    context.pushReplacementNamed('watch', pathParameters: {
      'videoId': videoId,
      'channelId': channelId,
    });
  }
}
