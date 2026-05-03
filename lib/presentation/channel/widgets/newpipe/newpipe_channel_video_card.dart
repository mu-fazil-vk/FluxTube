import 'package:flutter/material.dart';
import 'package:fluxtube/widgets/thumbnail_image.dart';
import 'package:fluxtube/core/animations/animations.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/core/operations/math_operations.dart';
import 'package:fluxtube/domain/watch/models/newpipe/newpipe_related.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/presentation/search/widgets/newpipe/home_video_info_card_widget.dart';
import 'package:fluxtube/widgets/common_video_description_widget.dart';
import 'package:go_router/go_router.dart';

/// NewPipe-specific video card widget for channel videos
class NewPipeChannelVideoCard extends StatelessWidget {
  const NewPipeChannelVideoCard({
    super.key,
    required this.videoInfo,
    required this.channelId,
    this.subscribeRowVisible = false,
    this.isSubscribed = false,
    this.onSubscribeTap,
    this.onTap,
    this.index = 0,
  });

  final NewPipeRelatedStream videoInfo;
  final String channelId;
  final bool subscribeRowVisible;
  final bool isSubscribed;
  final VoidCallback? onSubscribeTap;
  final VoidCallback? onTap;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final locals = S.of(context);
    final String duration =
        formatDuration(videoInfo.isLive == true ? -1 : videoInfo.duration);
    final isLiveVideo = duration == "Live";

    return AnimatedListItem(
      index: index,
      child: ScaleTap(
        scaleDown: 0.98,
        enableHaptic: false,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.xs,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.md,
          ),
          child: Column(
            children: [
              // Thumbnail container
              Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                width: double.infinity,
                height: 210,
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
                      if (videoInfo.thumbnailUrl != null)
                        ThumbnailImage.small(url: videoInfo.thumbnailUrl!),

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
                            color: isLiveVideo
                                ? AppColors.youtubeRed
                                : kBlackColor,
                            borderRadius: AppRadius.borderXs,
                          ),
                          child: Text(
                            duration,
                            style: TextStyle(
                              color: kWhiteColor,
                              fontSize: AppFontSize.caption,
                              fontWeight: isLiveVideo
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      // Content availability badge (top left)
                      if (videoInfo.contentAvailability != null)
                        Positioned(
                          top: AppSpacing.sm,
                          left: AppSpacing.sm,
                          child: ContentAvailabilityBadge(
                            availability: videoInfo.contentAvailability!,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Video info section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: Column(
                  children: [
                    // Title
                    CaptionRowWidget(
                      caption: videoInfo.name ?? locals.noVideoTitle,
                    ),

                    AppSpacing.height4,

                    // Views and date
                    ViewRowWidget(
                      views: videoInfo.viewCount ?? 0,
                      uploadedDate: videoInfo.uploadDate ?? locals.noUploadDate,
                    ),

                    AppSpacing.height8,

                    // Channel info row
                    if (subscribeRowVisible)
                      ScaleTap(
                        onTap: () => context.pushNamed(
                          'channel',
                          pathParameters: {'channelId': channelId},
                          queryParameters: {
                            'avatarUrl': videoInfo.uploaderAvatarUrl
                          },
                        ),
                        enableHaptic: false,
                        child: SubscribeRowWidget(
                          uploaderUrl: videoInfo.uploaderAvatarUrl ?? '',
                          uploader:
                              videoInfo.uploaderName ?? locals.noUploaderName,
                          isVerified: videoInfo.uploaderVerified,
                          subscribed: isSubscribed,
                          onSubscribeTap: onSubscribeTap,
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
}
