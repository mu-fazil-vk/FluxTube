import 'package:flutter/cupertino.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/core/operations/math_operations.dart';
import 'package:fluxtube/domain/trending/models/newpipe/newpipe_trending_resp.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/widgets/widgets.dart';
import 'package:go_router/go_router.dart';

class NewPipeTrendingVideoInfoCardWidget extends StatelessWidget {
  const NewPipeTrendingVideoInfoCardWidget({
    super.key,
    this.cardInfo,
    this.isSubscribed = false,
    this.subscribeRowVisible = true,
    this.onSubscribeTap,
    required this.channelId,
  });

  final String channelId;
  final NewPipeTrendingResp? cardInfo;
  final bool isSubscribed;
  final bool subscribeRowVisible;
  final VoidCallback? onSubscribeTap;

  @override
  Widget build(BuildContext context) {
    final locals = S.of(context);
    final bool isLive = cardInfo?.isLive ?? false;
    final String duration =
        formatDuration(isLive ? -1 : cardInfo?.duration);
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
                        })
                    : null,
              ),
              child: Align(
                  alignment: const Alignment(0.85, 0.85),
                  child: Container(
                      color: duration == "Live" ? kRedColor : kBlackColor,
                      padding: const EdgeInsets.only(right: 5, left: 5),
                      child: Text(
                        duration,
                        style: const TextStyle(color: kWhiteColor),
                      )))),
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
                        onTap: () =>
                            context.goNamed('channel', pathParameters: {
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
