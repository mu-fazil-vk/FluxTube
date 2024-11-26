import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/watch/watch_bloc.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/domain/watch/models/basic_info.dart';
import 'package:fluxtube/domain/watch/models/invidious/video/invidious_watch_resp.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/widgets/related_video_widget.dart';
import 'package:go_router/go_router.dart';

class InvidiousRelatedVideoSection extends StatelessWidget {
  const InvidiousRelatedVideoSection({
    super.key,
    required this.locals,
    required this.watchInfo,
  });

  final S locals;
  final InvidiousWatchResp watchInfo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          locals.relatedTitle,
          style: TextStyle(
              color: Theme.of(context).textTheme.labelMedium!.color,
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
        kHeightBox20,
        SizedBox(
          height: 250,
          width: double.infinity,
          child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final String videoId =
                    watchInfo.recommendedVideos![index].videoId!;
                final String channelId =
                    watchInfo.recommendedVideos![index].authorId!;
                return GestureDetector(
                    onTap: () {
                      BlocProvider.of<WatchBloc>(context).add(
                          WatchEvent.setSelectedVideoBasicDetails(
                              details: VideoBasicInfo(
                                  id: videoId,
                                  title:
                                      watchInfo.recommendedVideos![index].title,
                                  thumbnailUrl: watchInfo
                                      .recommendedVideos![index]
                                      .videoThumbnails!
                                      .first
                                      .url,
                                  channelName: watchInfo
                                      .recommendedVideos![index].author,
                                  channelThumbnailUrl: null,
                                  channelId: channelId,
                                  uploaderVerified: watchInfo
                                      .recommendedVideos![index]
                                      .authorVerified)));
                      context.goNamed('watch', pathParameters: {
                        'videoId': videoId,
                        'channelId': channelId,
                      });
                    },
                    child: RelatedVideoWidget(
                      title: watchInfo.recommendedVideos![index].title ??
                          locals.noVideoTitle,
                      thumbnailUrl: watchInfo
                          .recommendedVideos![index].videoThumbnails!.first.url,
                      duration:
                          watchInfo.recommendedVideos![index].lengthSeconds,
                    ));
              },
              separatorBuilder: (context, index) => kWidthBox10,
              itemCount: watchInfo.recommendedVideos?.length ?? 0),
        ),
      ],
    );
  }
}
