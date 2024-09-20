import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/core/enums.dart';
import 'package:fluxtube/domain/channel/models/invidious/invidious_channel_resp.dart';
import 'package:fluxtube/domain/channel/models/invidious/latest_video.dart';
import 'package:fluxtube/domain/watch/models/basic_info.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/presentation/channel/widgets/invidious/video_info_card.dart';
import 'package:fluxtube/widgets/widgets.dart';
import 'package:go_router/go_router.dart';

class InvidiousChannelRelatedVideoSection extends StatelessWidget {
  InvidiousChannelRelatedVideoSection({
    super.key,
    required this.channelId,
    required this.locals,
    required this.channelInfo,
    required this.state,
  });

  final S locals;
  final String channelId;
  final ChannelState state;
  final InvidiousChannelResp channelInfo;

  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    // _scrollController.addListener(() {
    //   if (_scrollController.position.pixels ==
    //           _scrollController.position.maxScrollExtent &&
    //       !(state.moreChannelDetailsFetchStatus == ApiStatus.loading) &&
    //       !state.isMoreFetchCompleted) {
    //     BlocProvider.of<ChannelBloc>(context).add(
    //         ChannelEvent.getMoreChannelVideos(
    //             channelId: channelId, nextPage: state.pipedChannelResp?.nextpage));
    //   }
    // });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            locals.relatedTitle,
            style: TextStyle(
                color: Theme.of(context).textTheme.labelMedium!.color,
                fontWeight: FontWeight.bold,
                fontSize: 18),
          ),
        ),
        kHeightBox20,
        Expanded(
          child: ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              if (index < state.invidiousChannelResp!.latestVideos!.length) {
                final LatestVideo videoInfo = channelInfo.latestVideos![index];
                final String videoId = videoInfo.videoId!;
                final String channelId = videoInfo.authorId!;

                return GestureDetector(
                  onTap: () {
                    BlocProvider.of<WatchBloc>(context).add(
                        WatchEvent.setSelectedVideoBasicDetails(
                            details: VideoBasicInfo(
                                title: videoInfo.title,
                                thumbnailUrl:
                                    videoInfo.videoThumbnails!.last.url,
                                channelName: videoInfo.author,
                                channelThumbnailUrl:
                                    channelInfo.authorThumbnails!.last.url!,
                                channelId: channelId,
                                uploaderVerified: videoInfo.authorVerified)));
                    context.go('/watch/$videoId/$channelId');
                  },
                  child: InvidiousChannelRelatedVideoInfoCardWidget(
                    channelId: channelId,
                    latestVideo: videoInfo,
                    autherUrl: channelInfo.authorThumbnails!.last.url,
                    subscribeRowVisible: false,
                  ),
                );
              } else {
                if (state.moreChannelDetailsFetchStatus == ApiStatus.loading) {
                  return cIndicator(context);
                } else if (state.isMoreFetchCompleted) {
                  return const SizedBox();
                } else {
                  return cIndicator(context);
                }
              }
            },
            separatorBuilder: (context, index) => kWidthBox10,
            itemCount: channelInfo.latestVideos?.length ?? 0,
          ),
        ),
      ],
    );
  }
}
