import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/core/enums.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/presentation/trending/widgets/invidious/trending_videos_section.dart';
import 'package:fluxtube/presentation/trending/widgets/piped/trending_videos_section.dart';
import 'package:fluxtube/widgets/widgets.dart';

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
            TrendingEvent.getTrendingData(
                serviceType: settingsState.ytService));
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
                          serviceType: settingsState.ytService)),
                  child: BlocBuilder<TrendingBloc, TrendingState>(
                    builder: (context, state) {
                      if (settingsState.ytService ==
                          YouTubeServices.piped.name) {
                        return _buildPipedTrendingSection(
                            state, locals, context, settingsState);
                      } else {
                        return _buildInvidiousTrendingSection(
                            state, locals, context, settingsState);
                      }
                    },
                  ),
                )));
      },
    );
  }

  Widget _buildPipedTrendingSection(
      TrendingState state, S locals, context, SettingsState settingsState) {
    if (state.fetchTrendingStatus == ApiStatus.loading ||
        state.fetchTrendingStatus == ApiStatus.initial) {
      return ListView.separated(
        separatorBuilder: (context, index) => kHeightBox10,
        itemBuilder: (context, index) {
          return const ShimmerHomeVideoInfoCard();
        },
        itemCount: 10,
      );
    } else if (state.fetchTrendingStatus == ApiStatus.error ||
        state.trendingResult.isEmpty) {
      if (state.trendingResult.isEmpty) {
        Fluttertoast.showToast(
          msg: locals.switchRegion,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      }
      return ErrorRetryWidget(
        lottie: 'assets/black-cat.zip',
        onTap: () => BlocProvider.of<TrendingBloc>(context).add(
            TrendingEvent.getForcedTrendingData(
                serviceType: settingsState.ytService)),
      );
    } else {
      return TrendingVideosSection(state: state, locals: locals);
    }
  }

  Widget _buildInvidiousTrendingSection(
      TrendingState state, S locals, context, SettingsState settingsState) {
    if (state.fetchInvidiousTrendingStatus == ApiStatus.loading ||
        state.fetchInvidiousTrendingStatus == ApiStatus.initial) {
      return ListView.separated(
        separatorBuilder: (context, index) => kHeightBox10,
        itemBuilder: (context, index) {
          return const ShimmerHomeVideoInfoCard();
        },
        itemCount: 10,
      );
    } else if (state.fetchInvidiousTrendingStatus == ApiStatus.error ||
        state.invidiousTrendingResult.isEmpty) {
      if (state.invidiousTrendingResult.isEmpty) {
        Fluttertoast.showToast(
          msg: locals.switchRegion,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      }
      return ErrorRetryWidget(
        lottie: 'assets/black-cat.zip',
        onTap: () => BlocProvider.of<TrendingBloc>(context).add(
            TrendingEvent.getForcedTrendingData(
                serviceType: settingsState.ytService)),
      );
    } else {
      return InvidiousTrendingVideosSection(state: state, locals: locals);
    }
  }
}
