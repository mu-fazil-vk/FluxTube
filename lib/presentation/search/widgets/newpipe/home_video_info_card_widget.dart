import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/core/operations/math_operations.dart';
import 'package:fluxtube/domain/search/models/newpipe/newpipe_search_resp.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/widgets/widgets.dart';
import 'package:go_router/go_router.dart';

/// Content availability badge widget for members-only, paid, or upcoming videos
class ContentAvailabilityBadge extends StatelessWidget {
  const ContentAvailabilityBadge({
    super.key,
    required this.availability,
  });

  final String availability;

  @override
  Widget build(BuildContext context) {
    // Only show badge for restricted content
    if (availability == 'AVAILABLE' || availability == 'UNKNOWN') {
      return const SizedBox.shrink();
    }

    IconData icon;
    Color bgColor;
    String label;

    switch (availability) {
      case 'MEMBERSHIP':
        icon = CupertinoIcons.person_2_fill;
        bgColor = Colors.purple;
        label = 'Members';
        break;
      case 'PAID':
        icon = CupertinoIcons.money_dollar_circle_fill;
        bgColor = Colors.orange;
        label = 'Paid';
        break;
      case 'UPCOMING':
        icon = CupertinoIcons.clock_fill;
        bgColor = Colors.blue;
        label = 'Upcoming';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class NewPipeSearchVideoInfoCardWidget extends StatelessWidget {
  const NewPipeSearchVideoInfoCardWidget({
    super.key,
    this.cardInfo,
    this.isSubscribed = false,
    this.subscribeRowVisible = true,
    this.onSubscribeTap,
    required this.channelId,
  });

  final String channelId;
  final NewPipeSearchItem? cardInfo;
  final bool isSubscribed;
  final bool subscribeRowVisible;
  final VoidCallback? onSubscribeTap;

  @override
  Widget build(BuildContext context) {
    final locals = S.of(context);
    final bool isLive = cardInfo?.isLive ?? false;
    final String duration = formatDuration(isLive ? -1 : cardInfo?.duration);
    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 20, right: 20, bottom: 10),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            width: double.infinity,
            height: 230,
            decoration: BoxDecoration(
              color: kGreyColor,
              borderRadius: BorderRadius.circular(20),
              image: cardInfo?.thumbnailUrl != null
                  ? DecorationImage(
                      image: cachedThumbnailProvider(cardInfo!.thumbnailUrl!),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) {
                        const SizedBox();
                      },
                    )
                  : null,
            ),
            child: Stack(
              children: [
                // Duration badge (bottom right)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    color: duration == "Live" ? kRedColor : kBlackColor,
                    padding: const EdgeInsets.only(right: 5, left: 5),
                    child: Text(
                      duration,
                      style: const TextStyle(color: kWhiteColor),
                    ),
                  ),
                ),
                // Content availability badge (top left)
                if (cardInfo?.contentAvailability != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: ContentAvailabilityBadge(
                      availability: cardInfo!.contentAvailability!,
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12, left: 12),
            child: Column(
              children: [
                // * caption row
                CaptionRowWidget(
                  caption: cardInfo?.name ?? locals.noVideoTitle,
                ),

                kHeightBox5,

                // * views row
                ViewRowWidget(
                  views: cardInfo?.viewCount ?? 0,
                  uploadedDate: cardInfo?.uploadDate ?? locals.noUploadDate,
                ),

                kHeightBox10,

                // * channel info row
                subscribeRowVisible
                    ? GestureDetector(
                        onTap: () => context.goNamed('channel', pathParameters: {
                          'channelId': channelId
                        }, queryParameters: {
                          'avatarUrl': cardInfo?.uploaderAvatarUrl,
                        }),
                        child: SubscribeRowWidget(
                          uploaderUrl: cardInfo?.uploaderAvatarUrl,
                          uploader: cardInfo?.uploaderName ?? locals.noUploaderName,
                          isVerified: cardInfo?.uploaderVerified,
                          subscribed: isSubscribed,
                          onSubscribeTap: onSubscribeTap,
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
