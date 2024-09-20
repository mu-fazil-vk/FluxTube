import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluxtube/core/operations/math_operations.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:go_router/go_router.dart';
import '../core/colors.dart';
import '../core/constants.dart';
import 'common_video_description_widget.dart';

// if trending or search *videos*, this will return (bcz of common values)
class HomeVideoInfoCardWidget extends StatelessWidget {
  const HomeVideoInfoCardWidget(
      {super.key,
      this.cardInfo,
      this.isSubscribed = false,
      this.subscribeRowVisible = true,
      this.onSubscribeTap,
      this.isLive = false,
      required this.channelId});

  final String channelId;
  final dynamic cardInfo;
  final bool isSubscribed;
  final bool subscribeRowVisible;
  final VoidCallback? onSubscribeTap;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    final locals = S.of(context);
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
                image: cardInfo?.thumbnail != null
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(cardInfo!.thumbnail!),
                        fit: BoxFit.cover)
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
                  caption: cardInfo?.title ?? locals.noVideoTitle,
                ),

                kHeightBox5,

                // * views row
                ViewRowWidget(
                  views: cardInfo?.views ?? 0,
                  uploadedDate: cardInfo?.uploadedDate ?? locals.noUploadDate,
                ),

                kHeightBox10,

                // * channel info row
                subscribeRowVisible
                    ? GestureDetector(
                        onTap: () => context.goNamed('channel',
                            pathParameters: {
                              'channelId': channelId
                            },
                            queryParameters: {
                              'avtarUrl': cardInfo?.uploaderAvatar
                            }),
                        child: SubscribeRowWidget(
                          uploaderUrl: cardInfo?.uploaderAvatar ?? '',
                          uploader:
                              cardInfo?.uploaderName ?? locals.noUploaderName,
                          isVerified: cardInfo.uploaderVerified,
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
