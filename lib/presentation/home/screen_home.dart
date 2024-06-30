import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/settings/settings_bloc.dart';
import 'package:fluxtube/application/trending/trending_bloc.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/domain/subscribes/models/subscribe.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/widgets/error_widget.dart';
import 'package:go_router/go_router.dart';
import '../../application/subscribe/subscribe_bloc.dart';
import '../../widgets/home_video_info_card_widget.dart';
import 'widgets/home_app_bar.dart';

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

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          BlocProvider.of<TrendingBloc>(context).add(
              TrendingEvent.getTrendingData(
                  region: settingsState.defaultRegion));
        });
        return SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) =>
                [const HomeAppBar()],
            body: BlocBuilder<SubscribeBloc, SubscribeState>(
                builder: (context, subscribeState) {
              if (subscribeState.subscribedChannels.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  BlocProvider.of<TrendingBloc>(context).add(
                      TrendingEvent.getForcedHomeFeedData(
                          channels: subscribeState.subscribedChannels));
                });
              }

              return BlocBuilder<TrendingBloc, TrendingState>(
                  builder: (context, trendingState) {
                //if feed loading (here used trending loading commonly)
                if (trendingState.isLoading) {
                  return Center(
                    child: CupertinoActivityIndicator(
                      color: Theme.of(context).indicatorColor,
                    ),
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
                    return ListView.separated(
                      separatorBuilder: (context, index) => kHeightBox10,
                      itemBuilder: (context, index) {
                        final trending = trendingState.trendingResult[index];
                        final String videoId = trending.url!.split('=').last;

                        final String channelId =
                            trending.uploaderUrl!.split("/").last;
                        final bool isSubscribed = subscribeState
                            .subscribedChannels
                            .where((channel) => channel.id == channelId)
                            .isNotEmpty;
                        return GestureDetector(
                          onTap: () => context.go('/watch/$videoId/$channelId'),
                          child: HomeVideoInfoCardWidget(
                            cardInfo: trending,
                            isSubscribed: isSubscribed,
                            onSubscribeTap: () {
                              if (isSubscribed) {
                                BlocProvider.of<SubscribeBloc>(context).add(
                                    SubscribeEvent.deleteSubscribeInfo(
                                        id: channelId));
                              } else {
                                BlocProvider.of<SubscribeBloc>(context).add(
                                    SubscribeEvent.addSubscribe(
                                        channelInfo: Subscribe(
                                            id: channelId,
                                            channelName:
                                                trending.uploaderName ??
                                                    locals.noUploaderName,
                                            isVerified:
                                                trending.uploaderVerified ??
                                                    false)));
                              }
                            },
                          ),
                        );
                      },
                      itemCount: trendingState.trendingResult.length,
                    );
                  } else {
                    // if feed not empty then show feed data
                    return RefreshIndicator(
                      onRefresh: () async {
                        BlocProvider.of<TrendingBloc>(context).add(
                            TrendingEvent.getForcedHomeFeedData(
                                channels: subscribeState.subscribedChannels));
                      },
                      child: ListView.separated(
                        separatorBuilder: (context, index) => kHeightBox10,
                        itemBuilder: (context, index) {
                          final feed = trendingState.feedResult[index];
                          final String videoId = feed.url!.split('=').last;

                          final String channelId =
                              feed.uploaderUrl!.split("/").last;
                          final bool isSubscribed = subscribeState
                              .subscribedChannels
                              .where((channel) => channel.id == channelId)
                              .isNotEmpty;
                          return GestureDetector(
                            onTap: () =>
                                context.go('/watch/$videoId/$channelId'),
                            child: HomeVideoInfoCardWidget(
                              cardInfo: feed,
                              isSubscribed: isSubscribed,
                              onSubscribeTap: () {
                                if (isSubscribed) {
                                  BlocProvider.of<SubscribeBloc>(context).add(
                                      SubscribeEvent.deleteSubscribeInfo(
                                          id: channelId));
                                } else {
                                  BlocProvider.of<SubscribeBloc>(context).add(
                                      SubscribeEvent.addSubscribe(
                                          channelInfo: Subscribe(
                                              id: channelId,
                                              channelName: feed.uploaderName ??
                                                  locals.noUploaderName,
                                              isVerified:
                                                  feed.uploaderVerified ??
                                                      false)));
                                }
                              },
                            ),
                          );
                        },
                        itemCount: trendingState.feedResult.length,
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
