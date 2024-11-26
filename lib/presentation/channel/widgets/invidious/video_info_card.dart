import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/core/operations/math_operations.dart';
import 'package:fluxtube/domain/channel/models/invidious/latest_video.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/widgets/widgets.dart';
import 'package:go_router/go_router.dart';

class InvidiousChannelRelatedVideoInfoCardWidget extends StatelessWidget {
  const InvidiousChannelRelatedVideoInfoCardWidget({
    super.key,
    this.latestVideo,
    this.isSubscribed = false,
    this.subscribeRowVisible = true,
    this.onSubscribeTap,
    this.isLive = false,
    required this.channelId,
    this.autherUrl,
  });

  final String channelId;
  final LatestVideo? latestVideo;
  final bool isSubscribed;
  final bool subscribeRowVisible;
  final VoidCallback? onSubscribeTap;
  final bool isLive;
  final String? autherUrl;

  @override
  Widget build(BuildContext context) {
    final locals = S.of(context);
    final String duration =
        formatDuration(isLive ? -1 : latestVideo?.lengthSeconds);
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
                image: latestVideo?.videoThumbnails?.last.url != null
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(
                            latestVideo!.videoThumbnails!.last.url!),
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
                  caption: latestVideo?.title ?? locals.noVideoTitle,
                ),

                kHeightBox5,

                // * views row
                ViewRowWidget(
                  views: latestVideo?.viewCount ?? 0,
                  uploadedDate:
                      '${latestVideo?.published ?? locals.noUploadDate}',
                ),

                kHeightBox10,

                // * channel info row
                subscribeRowVisible
                    ? GestureDetector(
                        onTap: () => context.goNamed('channel',
                            pathParameters: {'channelId': channelId},
                            queryParameters: {'avtarUrl': autherUrl}),
                        child: SubscribeRowWidget(
                          uploaderUrl: autherUrl ?? '',
                          uploader:
                              latestVideo?.author ?? locals.noUploaderName,
                          isVerified: latestVideo?.authorVerified,
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
