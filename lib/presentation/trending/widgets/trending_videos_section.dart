import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/domain/subscribes/models/subscribe.dart';
import 'package:fluxtube/domain/watch/models/basic_info.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/widgets/widgets.dart';
import 'package:go_router/go_router.dart';

class TrendingVideosSection extends StatelessWidget {
  const TrendingVideosSection({
    super.key,
    required this.locals,
    required this.state,
  });

  final S locals;
  final TrendingState state;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscribeBloc, SubscribeState>(
      buildWhen: (previous, current) =>
          previous.subscribedChannels != current.subscribedChannels,
      builder: (context, subscribeState) {
        return ListView.separated(
          separatorBuilder: (context, index) => kHeightBox10,
          itemBuilder: (context, index) {
            final trending = state.trendingResult[index];
            final String videoId = trending.url!.split('=').last;

            final String channelId = trending.uploaderUrl!.split("/").last;
            final bool isSubscribed = subscribeState.subscribedChannels
                .where((channel) => channel.id == channelId)
                .isNotEmpty;
            return GestureDetector(
              onTap: () {
                BlocProvider.of<WatchBloc>(context).add(
                    WatchEvent.setSelectedVideoBasicDetails(
                        details: VideoBasicInfo(
                            title: trending.title,
                            thumbnailUrl: trending.thumbnail,
                            channelName: trending.uploaderName,
                            channelThumbnailUrl: trending.uploaderAvatar,
                            channelId: channelId,
                            uploaderVerified: trending.uploaderVerified)));
                context.go('/watch/$videoId/$channelId');
              },
              child: HomeVideoInfoCardWidget(
                channelId: channelId,
                cardInfo: trending,
                isSubscribed: isSubscribed,
                onSubscribeTap: () {
                  if (isSubscribed) {
                    BlocProvider.of<SubscribeBloc>(context)
                        .add(SubscribeEvent.deleteSubscribeInfo(id: channelId));
                  } else {
                    BlocProvider.of<SubscribeBloc>(context).add(
                        SubscribeEvent.addSubscribe(
                            channelInfo: Subscribe(
                                id: channelId,
                                channelName: trending.uploaderName ??
                                    locals.noUploaderName,
                                isVerified:
                                    trending.uploaderVerified ?? false)));
                  }
                },
              ),
            );
          },
          itemCount: state.trendingResult.length,
        );
      },
    );
  }
}
