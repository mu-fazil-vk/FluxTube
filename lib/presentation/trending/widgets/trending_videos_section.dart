import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/subscribe/subscribe_bloc.dart';
import 'package:fluxtube/application/trending/trending_bloc.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/domain/subscribes/models/subscribe.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/widgets/home_video_info_card_widget.dart';
import 'package:go_router/go_router.dart';

class TrendingVideosSection extends StatelessWidget {
  const TrendingVideosSection({
    super.key,
    required this.locals, required this.state,
  });

  final S locals;
  final TrendingState state;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscribeBloc, SubscribeState>(
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
              onTap: () => context.go('/watch/$videoId/$channelId'),
              child: HomeVideoInfoCardWidget(
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