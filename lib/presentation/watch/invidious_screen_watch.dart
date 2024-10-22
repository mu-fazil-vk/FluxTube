import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_in_app_pip/flutter_in_app_pip.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/core/enums.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/widgets/widgets.dart';

import 'widgets/invidious/comment_widgets.dart';
import 'widgets/invidious/description_section.dart';
import 'widgets/invidious/like_section.dart';
import 'widgets/invidious/pip_video_player.dart';
import 'widgets/invidious/related_video_section.dart';
import 'widgets/invidious/subscribe_section.dart';
import 'widgets/invidious/video_player_widget.dart';

class InvidiousScreenWatch extends StatelessWidget {
  const InvidiousScreenWatch({
    super.key,
    required this.id,
    required this.channelId,
  });

  final String id;
  final String channelId;

  @override
  Widget build(BuildContext context) {
    final locals = S.of(context);
    final double _height = MediaQuery.of(context).size.height;

    PictureInPicture.stopPiP();

    BlocProvider.of<SavedBloc>(context)
        .add(const SavedEvent.getAllVideoInfoList());
    BlocProvider.of<SavedBloc>(context).add(SavedEvent.checkVideoInfo(id: id));
    BlocProvider.of<SubscribeBloc>(context)
        .add(SubscribeEvent.checkSubscribeInfo(id: channelId));

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        return BlocBuilder<WatchBloc, WatchState>(
          buildWhen: (previous, current) {
            return previous != current;
          },
          builder: (context, state) {
            return BlocBuilder<SavedBloc, SavedState>(
              builder: (context, savedState) {
                if ((state.oldId != id || state.oldId == null) &&
                    !(state.fetchInvidiousWatchInfoStatus ==
                            ApiStatus.loading ||
                        state.fetchInvidiousWatchInfoStatus ==
                            ApiStatus.error)) {
                  BlocProvider.of<WatchBloc>(context)
                      .add(WatchEvent.getInvidiousWatchInfo(id: id));
                  BlocProvider.of<WatchBloc>(context)
                      .add(WatchEvent.getSubtitles(id: id));
                }

                final watchInfo = state.invidiousWatchResp;

                bool isSaved = (savedState.videoInfo?.id == id &&
                        savedState.videoInfo?.isSaved == true)
                    ? true
                    : false;

                if (state.fetchInvidiousWatchInfoStatus == ApiStatus.error ||
                    (settingsState.isHlsPlayer && watchInfo.dashUrl == null)) {
                  return ErrorRetryWidget(
                    lottie: 'assets/cat-404.zip',
                    onTap: () => BlocProvider.of<WatchBloc>(context)
                        .add(WatchEvent.getInvidiousWatchInfo(id: id)),
                  );
                } else {
                  return Dismissible(
                    direction: DismissDirection.down,
                    onDismissed: (direction) {
                      buildPip(
                          context: context,
                          isSaved: isSaved,
                          savedState: savedState,
                          settingsState: settingsState,
                          state: state);
                    },
                    key: ValueKey(id),
                    child: PopScope(
                      canPop: false,
                      onPopInvoked: (didPop) => buildPip(
                          context: context,
                          isSaved: isSaved,
                          savedState: savedState,
                          settingsState: settingsState,
                          state: state),
                      child: Scaffold(
                        body: SafeArea(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                (state.fetchInvidiousWatchInfoStatus ==
                                            ApiStatus.initial ||
                                        state.fetchInvidiousWatchInfoStatus ==
                                            ApiStatus.loading ||
                                        state.fetchSubtitlesStatus ==
                                            ApiStatus.loading)
                                    ? Container(
                                        height: 200,
                                        color: kBlackColor,
                                        child: Center(
                                          child: cIndicator(context),
                                        ),
                                      )
                                    : InvidiousVideoPlayerWidget(
                                        videoId: id,
                                        watchInfo: state.invidiousWatchResp,
                                        defaultQuality:
                                            settingsState.defaultQuality,
                                        playbackPosition: savedState
                                                .videoInfo?.playbackPosition ??
                                            0,
                                        isSaved: isSaved,
                                        isHlsPlayer: settingsState.isHlsPlayer,
                                        subtitles: state.fetchSubtitlesStatus ==
                                                ApiStatus.loading
                                            ? []
                                            : state.subtitles,
                                      ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 12, left: 20, right: 20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // * caption row
                                      (state.fetchInvidiousWatchInfoStatus ==
                                                  ApiStatus.initial ||
                                              state.fetchInvidiousWatchInfoStatus ==
                                                  ApiStatus.loading)
                                          ? CaptionRowWidget(
                                              caption: state
                                                      .selectedVideoBasicDetails
                                                      ?.title ??
                                                  locals.noVideoTitle,
                                              icon: state.isDescriptionTapped
                                                  ? CupertinoIcons.chevron_up
                                                  : CupertinoIcons.chevron_down,
                                            )
                                          : GestureDetector(
                                              onTap: () =>
                                                  BlocProvider.of<WatchBloc>(
                                                          context)
                                                      .add(WatchEvent
                                                          .tapDescription()),
                                              child: CaptionRowWidget(
                                                caption: watchInfo.title ??
                                                    locals.noVideoTitle,
                                                icon: state.isDescriptionTapped
                                                    ? CupertinoIcons.chevron_up
                                                    : CupertinoIcons
                                                        .chevron_down,
                                              ),
                                            ),

                                      kHeightBox5,

                                      // * views row
                                      (state.fetchInvidiousWatchInfoStatus ==
                                                  ApiStatus.initial ||
                                              state.fetchInvidiousWatchInfoStatus ==
                                                  ApiStatus.loading)
                                          ? const SizedBox()
                                          : ViewRowWidget(
                                              views: watchInfo.viewCount,
                                              uploadedDate: watchInfo.published
                                                  .toString(),
                                            ),

                                      kHeightBox10,

                                      // * like row
                                      (state.fetchInvidiousWatchInfoStatus ==
                                                  ApiStatus.initial ||
                                              state.fetchInvidiousWatchInfoStatus ==
                                                  ApiStatus.loading)
                                          ? const ShimmerLikeWidget()
                                          : InvidiousLikeSection(
                                              id: id,
                                              state: state,
                                              watchInfo: watchInfo,
                                              pipClicked: () => buildPip(
                                                  context: context,
                                                  isSaved: isSaved,
                                                  savedState: savedState,
                                                  settingsState: settingsState,
                                                  state: state),
                                            ),

                                      kHeightBox10,

                                      const Divider(),

                                      // * channel info row
                                      (state.fetchInvidiousWatchInfoStatus ==
                                                  ApiStatus.initial ||
                                              state.fetchInvidiousWatchInfoStatus ==
                                                  ApiStatus.loading)
                                          ? const ShimmerSubscribeWidget()
                                          : InvidiousChannelInfoSection(
                                              state: state,
                                              watchInfo: watchInfo,
                                              locals: locals),
                                      if (!state.isTapComments) const Divider(),
                                      kHeightBox10,

                                      // * description
                                      state.isDescriptionTapped
                                          ? InvidiousDescriptionSection(
                                              height: _height,
                                              watchInfo: watchInfo,
                                              locals: locals)
                                          :
                                          // * related videos
                                          state.isTapComments == false
                                              ? settingsState.isHideRelated
                                                  ? const SizedBox()
                                                  : (state.fetchInvidiousWatchInfoStatus ==
                                                              ApiStatus
                                                                  .initial ||
                                                          state.fetchInvidiousWatchInfoStatus ==
                                                              ApiStatus.loading)
                                                      ? SizedBox(
                                                          height: 350,
                                                          child: ListView
                                                              .separated(
                                                                  scrollDirection:
                                                                      Axis
                                                                          .horizontal,
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    return const ShimmerRelatedVideoWidget();
                                                                  },
                                                                  separatorBuilder:
                                                                      (context,
                                                                              index) =>
                                                                          kWidthBox10,
                                                                  itemCount: 5),
                                                        )
                                                      : InvidiousRelatedVideoSection(
                                                          locals: locals,
                                                          watchInfo: watchInfo)
                                              //comments section
                                              : InvidiousCommentSection(
                                                  videoId: id,
                                                  state: state,
                                                  height: _height,
                                                  locals: locals,
                                                ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  void buildPip(
      {context,
      state,
      settingsState,
      savedState,
      isSaved,
      isPop = true}) async {
    if (isPop) {
      Navigator.pop(context);
    }
    BlocProvider.of<WatchBloc>(context).add(WatchEvent.togglePip(value: true));
    PictureInPicture.startPiP(
        pipWidget: NavigatablePiPWidget(
      onPiPClose: () {
        BlocProvider.of<WatchBloc>(context)
            .add(WatchEvent.togglePip(value: false));
      },
      elevation: 10, //Optional
      pipBorderRadius: 10,
      builder: (BuildContext context) {
        return InvidiousPipVideoPlayerWidget(
          videoId: id,
          watchInfo: state.invidiousWatchResp,
          defaultQuality: settingsState.defaultQuality,
          playbackPosition: savedState.videoInfo?.playbackPosition ?? 0,
          isSaved: isSaved,
          isHlsPlayer: settingsState.isHlsPlayer,
          subtitles: (state.fetchSubtitlesStatus == ApiStatus.loading ||
                  state.fetchSubtitlesStatus == ApiStatus.initial)
              ? []
              : state.subtitles,
        );
      }, //Optional
    ));
  }
}
