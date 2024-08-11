
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/domain/subscribes/models/subscribe.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/presentation/trending/widgets/trending_videos_section.dart';
import 'package:fluxtube/widgets/widgets.dart';

import 'widgets/widgets.dart';

class ScreenHome extends StatelessWidget {
  const ScreenHome({super.key});

  @override
  Widget build(BuildContext context) {
    //initialize setting data frrom system for 1st time
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<SettingsBloc>(context)
          .add(SettingsEvent.initializeSettings());
    });
    BlocProvider.of<SubscribeBloc>(context)
        .add(const SubscribeEvent.getAllSubscribeList());

    final locals = S.of(context);

    List<Subscribe> subscribeList = [];

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        return SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) =>
                [const HomeAppBar()],
            body: BlocBuilder<SubscribeBloc, SubscribeState>(
                builder: (context, subscribeState) {
              if (subscribeState.subscribedChannels.isNotEmpty &&
                  subscribeState.subscribedChannels != subscribeList) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  BlocProvider.of<TrendingBloc>(context).add(
                      TrendingEvent.getForcedHomeFeedData(
                          channels: subscribeState.subscribedChannels));
                });
                subscribeList = subscribeState.subscribedChannels;
              }

              return BlocBuilder<TrendingBloc, TrendingState>(
                  builder: (context, trendingState) {
                if (trendingState.trendingResult.isEmpty &&
                    !trendingState.isError) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    BlocProvider.of<TrendingBloc>(context).add(
                        TrendingEvent.getTrendingData(
                            region: settingsState.defaultRegion));
                  });
                }
                //if feed loading (here used trending loading commonly)
                if (trendingState.isLoading) {
                  return ListView.separated(
                    separatorBuilder: (context, index) => kHeightBox10,
                    itemBuilder: (context, index) {
                      return const ShimmerHomeVideoInfoCard();
                    },
                    itemCount: 10,
                  );
                } else {
                  // if feed empty then show trending
                  if (trendingState.feedResult.isEmpty ||
                      trendingState.isFeedError) {
                    if (trendingState.isError ||
                        trendingState.trendingResult.isEmpty) {
                      return ErrorRetryWidget(
                        lottie: 'assets/dog.zip',
                        onTap: () => BlocProvider.of<TrendingBloc>(context).add(
                            TrendingEvent.getForcedTrendingData(
                                region: settingsState.defaultRegion)),
                      );
                    }
                    return TrendingVideosSection(
                        locals: locals, state: trendingState);
                  } else {
                    // if feed not empty then show feed data
                    return RefreshIndicator(
                      onRefresh: () async {
                        BlocProvider.of<TrendingBloc>(context).add(
                            TrendingEvent.getForcedHomeFeedData(
                                channels: subscribeState.subscribedChannels));
                      },
                      child: FeedVideoSection(
                        trendingState: trendingState,
                        locals: locals,
                        subscribeState: subscribeState,
                      ),
                    );
                  }
                }
              });
            }),
          ),
        );
      },
    );
  }
}
