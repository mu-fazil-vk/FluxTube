import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluxtube/widgets/thumbnail_image.dart';
import 'package:fluxtube/core/animations/animations.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/core/operations/math_operations.dart';

class RelatedVideoWidget extends StatelessWidget {
  const RelatedVideoWidget({
    super.key,
    required this.title,
    required this.thumbnailUrl,
    required this.duration,
    this.isDeleteIcon = false,
    this.onDeleteTap,
    this.onTap,
    this.index = 0,
  });

  final String title;
  final String? thumbnailUrl;
  final int? duration;
  final bool isDeleteIcon;
  final VoidCallback? onDeleteTap;
  final VoidCallback? onTap;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final String durationStr = formatDuration(duration);
    final isLive = durationStr == "Live";

    return AnimatedListItem(
      index: index,
      child: ScaleTap(
        onTap: onTap,
        scaleDown: 0.95,
        child: SizedBox(
          width: 275,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail container
              Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                width: 275,
                height: 155,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceVariantDark
                      : AppColors.surfaceVariant,
                  borderRadius: AppRadius.borderMd,
                ),
                child: ClipRRect(
                  borderRadius: AppRadius.borderMd,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Thumbnail image
                      if (thumbnailUrl != null)
                        ThumbnailImage.small(url: thumbnailUrl!),

                      // Delete button overlay
                      if (isDeleteIcon)
                        Positioned(
                          top: AppSpacing.sm,
                          right: AppSpacing.sm,
                          child: ScaleTap(
                            onTap: onDeleteTap,
                            child: Container(
                              padding: AppSpacing.paddingXs,
                              decoration: BoxDecoration(
                                color: AppColors.overlay,
                                borderRadius: AppRadius.borderSm,
                              ),
                              child: Icon(
                                CupertinoIcons.delete_solid,
                                color: AppColors.error,
                                size: AppIconSize.sm,
                              ),
                            ),
                          ),
                        ),

                      // Duration badge
                      Positioned(
                        bottom: AppSpacing.sm,
                        right: AppSpacing.sm,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: isLive ? AppColors.youtubeRed : kBlackColor,
                            borderRadius: AppRadius.borderXs,
                          ),
                          child: Text(
                            durationStr,
                            style: TextStyle(
                              color: kWhiteColor,
                              fontSize: AppFontSize.caption,
                              fontWeight:
                                  isLive ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
