import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/settings/settings_bloc.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/presentation/trending/widgets/trending_videos_section.dart';
import 'package:fluxtube/widgets/custom_app_bar.dart';
import 'package:fluxtube/widgets/error_widget.dart';
import 'package:fluxtube/widgets/shimmer_home_video_card.dart';

import '../../application/subscribe/subscribe_bloc.dart';
import '../../application/trending/trending_bloc.dart';

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
                        isSearchVisible: true,
                      )
                    ],
                body: RefreshIndicator(
                  onRefresh: () async => BlocProvider.of<TrendingBloc>(context)
                      .add(TrendingEvent.getForcedTrendingData(
                          region: settingsState.defaultRegion)),
                  child: BlocBuilder<TrendingBloc, TrendingState>(
                    builder: (context, state) {
                      if (state.isLoading) {
                        return ListView.separated(
                          separatorBuilder: (context, index) => kHeightBox10,
                          itemBuilder: (context, index) {
                            return const ShimmerHomeVideoInfoCard();
                          },
                          itemCount: 10,
                        );
                      } else if (state.isError ||
                          state.trendingResult.isEmpty) {
                        return ErrorRetryWidget(
                          lottie: 'assets/black-cat.zip',
                          onTap: () => BlocProvider.of<TrendingBloc>(context)
                              .add(TrendingEvent.getForcedTrendingData(
                                  region: settingsState.defaultRegion)),
                        );
                      } else {
                        return TrendingVideosSection(
                            state: state, locals: locals);
                      }
                    },
                  ),
                )));
      },
    );
  }
}
