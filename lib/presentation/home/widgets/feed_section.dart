import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/subscribe/subscribe_bloc.dart';
import 'package:fluxtube/application/trending/trending_bloc.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/domain/subscribes/models/subscribe.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/widgets/home_video_info_card_widget.dart';
import 'package:go_router/go_router.dart';

class FeedVideoSection extends StatelessWidget {
  const FeedVideoSection({
    super.key,
    required this.locals,
    required this.trendingState, required this.subscribeState,
  });

  final S locals;
  final TrendingState trendingState;
  final SubscribeState subscribeState;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (context, index) => kHeightBox10,
      itemBuilder: (context, index) {
        final feed = trendingState.feedResult[index];
        final String videoId = feed.url!.split('=').last;

        final String channelId = feed.uploaderUrl!.split("/").last;
        final bool isSubscribed = subscribeState.subscribedChannels
            .where((channel) => channel.id == channelId)
            .isNotEmpty;
        return GestureDetector(
          onTap: () => context.go('/watch/$videoId/$channelId'),
          child: HomeVideoInfoCardWidget(
            cardInfo: feed,
            isSubscribed: isSubscribed,
            onSubscribeTap: () => onSubscribeTapped(
                context, isSubscribed, channelId, feed, locals),
          ),
        );
      },
      itemCount: trendingState.feedResult.length,
    );
  }
}

onSubscribeTapped(context, isSubscribed, channelId, channelDetails, locals) {
  if (isSubscribed) {
    BlocProvider.of<SubscribeBloc>(context)
        .add(SubscribeEvent.deleteSubscribeInfo(id: channelId));
  } else {
    BlocProvider.of<SubscribeBloc>(context).add(SubscribeEvent.addSubscribe(
        channelInfo: Subscribe(
            id: channelId,
            channelName: channelDetails.uploaderName ?? locals.noUploaderName,
            isVerified: channelDetails.uploaderVerified ?? false)));
  }
}