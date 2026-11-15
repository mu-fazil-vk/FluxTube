import 'package:flutter/material.dart';
import 'package:fluxtube/core/animations/animations.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/core/operations/math_operations.dart';
import 'package:fluxtube/domain/trending/models/newpipe/newpipe_trending_resp.dart';
import 'package:fluxtube/domain/trending/models/piped/trending_resp.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/widgets/thumbnail_image.dart';

class FeedVideoCardPiped extends StatelessWidget {
  const FeedVideoCardPiped({
    super.key,
    required this.video,
    required this.index,
    required this.onTap,
  });

  final TrendingResp video;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locals = S.of(context);
    final duration = formatDuration(video.duration ?? 0);
    final isLive = video.duration == null || video.duration == -1;

    return AnimatedListItem(
      index: index,
      child: ScaleTap(
        onTap: onTap,
        scaleDown: 0.98,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          decoration: BoxDecoration(
            color: scheme.surfaceContainer,
            borderRadius: AppRadius.borderLg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (video.thumbnail != null)
                        ThumbnailImage.small(url: video.thumbnail!),
                      Positioned(
                        bottom: AppSpacing.sm,
                        right: AppSpacing.sm,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: isLive ? scheme.error : Colors.black87,
                            borderRadius: AppRadius.borderXs,
                          ),
                          child: Text(
                            isLive ? locals.live.toUpperCase() : duration,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (video.uploaderAvatar != null)
                      ClipOval(
                        child: ThumbnailImage.small(
                          url: video.uploaderAvatar!,
                          width: 36,
                          height: 36,
                          errorWidget: (_, __, ___) => _avatarFallback(context),
                        ),
                      )
                    else
                      _avatarFallback(context),
                    AppSpacing.width12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            video.title ?? locals.noVideoTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                          ),
                          AppSpacing.height4,
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  video.uploaderName ?? locals.noUploaderName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              if (video.uploaderVerified == true) ...[
                                AppSpacing.width4,
                                Icon(
                                  Icons.verified,
                                  size: 12,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ],
                            ],
                          ),
                          AppSpacing.height2,
                          Text(
                            '${formatCount(video.views?.toString() ?? '0')} ${locals.views} • ${video.uploadedDate ?? ''}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
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

  Widget _avatarFallback(BuildContext context) => Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
        ),
        child: const Icon(Icons.person, size: 20),
      );
}

class FeedVideoCardNewPipe extends StatelessWidget {
  const FeedVideoCardNewPipe({
    super.key,
    required this.video,
    required this.index,
    required this.onTap,
  });

  final NewPipeTrendingResp video;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locals = S.of(context);
    final duration = formatDuration(video.duration ?? 0);
    final isLive = video.duration == null || video.duration == -1;

    return AnimatedListItem(
      index: index,
      child: ScaleTap(
        onTap: onTap,
        scaleDown: 0.98,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          decoration: BoxDecoration(
            color: scheme.surfaceContainer,
            borderRadius: AppRadius.borderLg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (video.thumbnailUrl != null)
                        ThumbnailImage.small(url: video.thumbnailUrl!),
                      Positioned(
                        bottom: AppSpacing.sm,
                        right: AppSpacing.sm,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: isLive ? scheme.error : Colors.black87,
                            borderRadius: AppRadius.borderXs,
                          ),
                          child: Text(
                            isLive ? locals.live.toUpperCase() : duration,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (video.uploaderAvatarUrl != null)
                      ClipOval(
                        child: ThumbnailImage.small(
                          url: video.uploaderAvatarUrl!,
                          width: 36,
                          height: 36,
                          errorWidget: (_, __, ___) => _avatarFallback(context),
                        ),
                      )
                    else
                      _avatarFallback(context),
                    AppSpacing.width12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            video.name ?? locals.noVideoTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                          ),
                          AppSpacing.height4,
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  video.uploaderName ?? locals.noUploaderName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              if (video.uploaderVerified == true) ...[
                                AppSpacing.width4,
                                Icon(
                                  Icons.verified,
                                  size: 12,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ],
                            ],
                          ),
                          AppSpacing.height2,
                          Text(
                            '${formatCount(video.viewCount?.toString() ?? '0')} ${locals.views} • ${video.uploadDate ?? ''}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
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

  Widget _avatarFallback(BuildContext context) => Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
        ),
        child: const Icon(Icons.person, size: 20),
      );
}

class ShimmerVideoCard extends StatelessWidget {
  const ShimmerVideoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: AppRadius.borderLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.surfaceContainerHigh,
                  ),
                ),
                AppSpacing.width12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHigh,
                          borderRadius: AppRadius.borderXs,
                        ),
                      ),
                      AppSpacing.height8,
                      Container(
                        height: 12,
                        width: 100,
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHigh,
                          borderRadius: AppRadius.borderXs,
                        ),
                      ),
                    ],
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
