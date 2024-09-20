import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/core/enums.dart';
import 'package:fluxtube/domain/subscribes/models/subscribe.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/presentation/trending/widgets/invidious/trending_videos_section.dart';
import 'package:fluxtube/widgets/widgets.dart';

import 'widgets/widgets.dart';

class ScreenHome extends StatelessWidget {
  const ScreenHome({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsBloc = BlocProvider.of<SettingsBloc>(context);
    final subscribeBloc = BlocProvider.of<SubscribeBloc>(context);
    final trendingBloc = BlocProvider.of<TrendingBloc>(context);
    final locals = S.of(context);

    // Initialize settings and subscription data on first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      settingsBloc.add(SettingsEvent.initializeSettings());
      subscribeBloc.add(const SubscribeEvent.getAllSubscribeList());
    });

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        return SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) =>
                [const HomeAppBar()],
            body: BlocBuilder<SubscribeBloc, SubscribeState>(
              buildWhen: (previous, current) =>
                  previous.subscribedChannels != current.subscribedChannels,
              builder: (context, subscribeState) {
                final List<Subscribe> subscribeList =
                    subscribeState.subscribedChannels;

                if (subscribeList.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    trendingBloc.add(TrendingEvent.getForcedHomeFeedData(
                        channels: subscribeList));
                  });
                }

                return BlocBuilder<TrendingBloc, TrendingState>(
                  builder: (context, trendingState) {
                    if (settingsState.ytService == YouTubeServices.piped.name) {
                      return _buildPipedTrendingSection(
                        trendingState,
                        locals,
                        context,
                        subscribeState,
                        trendingBloc,
                        settingsState,
                      );
                    } else {
                      return _buildInvidiousTrendingSection(
                        trendingState,
                        locals,
                        context,
                        subscribeState,
                        trendingBloc,
                        settingsState,
                      );
                    }
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildPipedTrendingSection(
      TrendingState trendingState,
      S locals,
      BuildContext context,
      SubscribeState subscribeState,
      TrendingBloc trendingBloc,
      SettingsState settingsState) {
    if (trendingState.trendingResult.isEmpty &&
        !(trendingState.fetchTrendingStatus == ApiStatus.error)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        trendingBloc.add(TrendingEvent.getTrendingData(
            serviceType: settingsState.ytService));
      });
    }

    if (trendingState.fetchTrendingStatus == ApiStatus.loading ||
        trendingState.fetchTrendingStatus == ApiStatus.initial) {
      return _buildLoadingList();
    }

    if (trendingState.fetchFeedStatus == ApiStatus.loading) {
      return _buildLoadingList();
    }

    if (trendingState.feedResult.isEmpty ||
        trendingState.fetchFeedStatus == ApiStatus.error) {
      return _buildErrorOrTrendingSection(
        context,
        trendingState,
        locals,
        settingsState,
      );
    }

    return _buildFeedSection(
      trendingState,
      locals,
      subscribeState,
      trendingBloc,
    );
  }

  Widget _buildInvidiousTrendingSection(
      TrendingState trendingState,
      S locals,
      BuildContext context,
      SubscribeState subscribeState,
      TrendingBloc trendingBloc,
      SettingsState settingsState) {
    if (trendingState.invidiousTrendingResult.isEmpty &&
        !(trendingState.fetchInvidiousTrendingStatus == ApiStatus.error)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        trendingBloc.add(TrendingEvent.getTrendingData(
            serviceType: settingsState.ytService));
      });
    }

    if (trendingState.fetchInvidiousTrendingStatus == ApiStatus.loading ||
        trendingState.fetchInvidiousTrendingStatus == ApiStatus.initial) {
      return _buildLoadingList();
    }

    if (trendingState.fetchFeedStatus == ApiStatus.loading) {
      return _buildLoadingList();
    }

    if (trendingState.feedResult.isEmpty ||
        trendingState.fetchFeedStatus == ApiStatus.error) {
      return _buildErrorOrTrendingSection(
        context,
        trendingState,
        locals,
        settingsState,
      );
    }

    return _buildFeedSection(
      trendingState,
      locals,
      subscribeState,
      trendingBloc,
    );
  }

  Widget _buildLoadingList() {
    return ListView.separated(
      separatorBuilder: (context, index) => kHeightBox10,
      itemBuilder: (context, index) {
        return const ShimmerHomeVideoInfoCard();
      },
      itemCount: 10,
    );
  }

  Widget _buildErrorOrTrendingSection(
    BuildContext context,
    TrendingState trendingState,
    S locals,
    SettingsState settingsState,
  ) {
    if (settingsState.ytService == YouTubeServices.piped.name) {
      if (trendingState.fetchTrendingStatus == ApiStatus.error ||
          trendingState.trendingResult.isEmpty) {
        return ErrorRetryWidget(
          lottie: 'assets/dog.zip',
          onTap: () => BlocProvider.of<TrendingBloc>(context).add(
            TrendingEvent.getForcedTrendingData(
                serviceType: settingsState.ytService),
          ),
        );
      }
    } else {
      if (trendingState.fetchInvidiousTrendingStatus == ApiStatus.error ||
          trendingState.invidiousTrendingResult.isEmpty) {
        return ErrorRetryWidget(
          lottie: 'assets/dog.zip',
          onTap: () => BlocProvider.of<TrendingBloc>(context).add(
            TrendingEvent.getForcedTrendingData(
                serviceType: settingsState.ytService),
          ),
        );
      }
    }

    return InvidiousTrendingVideosSection(
      locals: locals,
      state: trendingState,
    );
  }

  Widget _buildFeedSection(
    TrendingState trendingState,
    S locals,
    SubscribeState subscribeState,
    TrendingBloc trendingBloc,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        trendingBloc.add(TrendingEvent.getForcedHomeFeedData(
          channels: subscribeState.subscribedChannels,
        ));
      },
      child: FeedVideoSection(
        trendingState: trendingState,
        locals: locals,
        subscribeState: subscribeState,
      ),
    );
  }
}
