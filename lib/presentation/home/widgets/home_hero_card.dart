import 'package:flutter/material.dart';
import 'package:fluxtube/core/animations/animations.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/core/operations/math_operations.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/widgets/thumbnail_image.dart';

/// Large featured card rendered at the top of the home feed.
///
/// Shows the first feed item as a full-width thumbnail with a gradient
/// scrim, bold title and channel/views metadata overlaid at the bottom.
class HomeHeroCard extends StatelessWidget {
  const HomeHeroCard({
    super.key,
    required this.thumbnailUrl,
    required this.title,
    required this.channelName,
    this.views,
    this.uploadedDate,
    this.durationLabel,
    this.isLive = false,
    required this.onTap,
  });

  final String? thumbnailUrl;
  final String title;
  final String channelName;
  final int? views;
  final String? uploadedDate;
  final String? durationLabel;
  final bool isLive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locals = S.of(context);

    return ScaleTap(
      scaleDown: 0.98,
      enableHaptic: false,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xs,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        child: ClipRRect(
          borderRadius: AppRadius.borderLg,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (thumbnailUrl != null)
                  ThumbnailImage(url: thumbnailUrl!)
                else
                  ColoredBox(
                    color: theme.colorScheme.surfaceContainerHigh,
                    child: Icon(
                      Icons.movie_outlined,
                      size: AppIconSize.xxl,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),

                // Bottom gradient scrim
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.85),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Duration / live badge (small pill)
                if (isLive ||
                    (durationLabel != null && durationLabel!.isNotEmpty))
                  Positioned(
                    top: AppSpacing.md,
                    right: AppSpacing.md,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: isLive
                            ? theme.colorScheme.error
                            : Colors.black.withValues(alpha: 0.6),
                        borderRadius: AppRadius.borderFull,
                      ),
                      child: Text(
                        isLive ? locals.live : durationLabel!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color:
                              isLive ? theme.colorScheme.onError : Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                // Title + channel + views/date overlay
                Positioned(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  bottom: AppSpacing.lg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppSpacing.height4,
                      Text(
                        _buildMetaText(locals),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _buildMetaText(S locals) {
    final parts = <String>[channelName];
    if (views != null && views! > 0) {
      final formatted = formatCount(views.toString());
      parts.add('$formatted ${locals.videoViews(views!)}');
    }
    if (uploadedDate != null && uploadedDate!.isNotEmpty) {
      parts.add(uploadedDate!);
    }
    return parts.join('  •  ');
  }
}
