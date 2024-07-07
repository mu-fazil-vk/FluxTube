import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/settings/settings_bloc.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/widgets/custom_app_bar.dart';
import 'package:fluxtube/widgets/error_widget.dart';
import 'package:fluxtube/widgets/indicator.dart';
import 'package:go_router/go_router.dart';

import '../../application/subscribe/subscribe_bloc.dart';
import '../../application/trending/trending_bloc.dart';
import '../../domain/subscribes/models/subscribe.dart';
import '../../widgets/home_video_info_card_widget.dart';

class ScreenTrending extends StatelessWidget {
  const ScreenTrending({super.key});

  @override
  Widget build(BuildContext context) {
    final locals = S.of(context);
    BlocProvider.of<SubscribeBloc>(context)
        .add(const SubscribeEvent.getAllSubscribeList());

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        BlocProvider.of<TrendingBloc>(context).add(
            TrendingEvent.getTrendingData(region: settingsState.defaultRegion));
        return SafeArea(
            child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                      CustomAppBar(
                        title: locals.trending,
                      )
                    ],
                body: RefreshIndicator(
                  onRefresh: () async => BlocProvider.of<TrendingBloc>(context)
                      .add(TrendingEvent.getForcedTrendingData(
                          region: settingsState.defaultRegion)),
                  child: BlocBuilder<TrendingBloc, TrendingState>(
                    builder: (context, state) {
                      if (state.isLoading) {
                        return cIndicator(context);
                      } else if (state.isError ||
                          state.trendingResult.isEmpty) {
                        return ErrorRetryWidget(
                          lottie: 'assets/black-cat.zip',
                          onTap: () => BlocProvider.of<TrendingBloc>(context)
                              .add(TrendingEvent.getForcedTrendingData(
                                  region: settingsState.defaultRegion)),
                        );
                      } else {
                        return BlocBuilder<SubscribeBloc, SubscribeState>(
                          builder: (context, subscribeState) {
                            return ListView.separated(
                              separatorBuilder: (context, index) =>
                                  kHeightBox10,
                              itemBuilder: (context, index) {
                                final trending = state.trendingResult[index];
                                final String videoId =
                                    trending.url!.split('=').last;

                                final String channelId =
                                    trending.uploaderUrl!.split("/").last;
                                final bool isSubscribed = subscribeState
                                    .subscribedChannels
                                    .where((channel) => channel.id == channelId)
                                    .isNotEmpty;
                                return GestureDetector(
                                  onTap: () =>
                                      context.go('/watch/$videoId/$channelId'),
                                  child: HomeVideoInfoCardWidget(
                                    cardInfo: trending,
                                    isSubscribed: isSubscribed,
                                    onSubscribeTap: () {
                                      if (isSubscribed) {
                                        BlocProvider.of<SubscribeBloc>(context)
                                            .add(SubscribeEvent
                                                .deleteSubscribeInfo(
                                                    id: channelId));
                                      } else {
                                        BlocProvider.of<SubscribeBloc>(context)
                                            .add(SubscribeEvent.addSubscribe(
                                                channelInfo: Subscribe(
                                                    id: channelId,
                                                    channelName: trending
                                                            .uploaderName ??
                                                        locals.noUploaderName,
                                                    isVerified: trending
                                                            .uploaderVerified ??
                                                        false)));
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
                    },
                  ),
                )));
      },
    );
  }
}
