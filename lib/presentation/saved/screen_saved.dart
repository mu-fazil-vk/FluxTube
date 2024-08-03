import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/presentation/saved/widgets/history_section.dart';
import 'package:fluxtube/presentation/saved/widgets/saved_section.dart';
import 'package:fluxtube/widgets/indicator.dart';
import 'package:fluxtube/widgets/shimmer_home_video_card.dart';

import '../../application/saved/saved_bloc.dart';
import '../../application/settings/settings_bloc.dart';
import '../../widgets/custom_app_bar.dart';

class ScreenSaved extends StatelessWidget {
  const ScreenSaved({super.key});

  @override
  Widget build(BuildContext context) {
    final locals = S.of(context);
    BlocProvider.of<SavedBloc>(context)
        .add(const SavedEvent.getAllVideoInfoList());
    return SafeArea(
        child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  BlocBuilder<SavedBloc, SavedState>(
                    builder: (context, state) {
                      return CustomAppBar(
                        title: locals.savedVideosTitle,
                        count: state.localSavedVideos.length,
                      );
                    },
                  )
                ],
            body: BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, settingsState) {
                return BlocBuilder<SavedBloc, SavedState>(
                  builder: (context, savedState) {
                    if (savedState.isLoading) {
                      return ListView.separated(
                    separatorBuilder: (context, index) => kHeightBox10,
                    itemBuilder: (context, index) {
                      return const ShimmerHomeVideoInfoCard(subscribeRowVisible: false,);
                    },
                    itemCount: 10,
                  );
                    } else if (savedState.isError) {
                      return Center(
                        child: Text(locals.thereIsNoSavedOrHistoryVideos),
                      );
                    } else {
                      return Column(
                        children: [
                          HistoryVideosSection(
                            locals: locals,
                            settingsState: settingsState,
                            savedState: savedState,
                          ),
                          SavedVideosSection(
                              savedState: savedState, locals: locals),
                        ],
                      );
                    }
                  },
                );
              },
            )));
  }
}
