import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_in_app_pip/flutter_in_app_pip.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/presentation/watch/widgets/explode/description_section.dart';
import 'package:fluxtube/presentation/watch/widgets/explode/like_section.dart';
import 'package:fluxtube/presentation/watch/widgets/explode/subscribe_section.dart';
import 'package:fluxtube/presentation/watch/widgets/explode/video_player_widget.dart';
import 'package:fluxtube/widgets/widgets.dart';

import 'widgets/explode/pip_video_player.dart';
import 'widgets/explode/related_video_section.dart';
import 'widgets/widgets.dart';

class ExplodeScreenWatch extends StatelessWidget {
  const ExplodeScreenWatch({
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
      return BlocBuilder<WatchBloc, WatchState>(buildWhen: (previous, current) {
        return previous.isLoading != current.isLoading ||
            previous.isSubtitleLoading != current.isSubtitleLoading ||
            previous.isWatchInfoError != current.isWatchInfoError;
      }, builder: (context, state) {
        return BlocBuilder<SavedBloc, SavedState>(
          builder: (context, savedState) {
            if ((state.oldId != id || state.oldId == null) &&
                !state.isWatchInfoError) {
              BlocProvider.of<WatchBloc>(context)
                  .add(WatchEvent.getExplodeWatchInfo(id: id));
              BlocProvider.of<WatchBloc>(context)
                  .add(WatchEvent.getExplodeMuxStreamInfo(id: id));
              BlocProvider.of<WatchBloc>(context)
                  .add(WatchEvent.getExplodeRelatedVideoInfo(id: id));
              BlocProvider.of<WatchBloc>(context)
                  .add(WatchEvent.getSubtitles(id: id));
            }

            final watchInfo = state.explodeWatchResp;

            bool isSaved = (savedState.videoInfo?.id == id &&
                    savedState.videoInfo?.isSaved == true)
                ? true
                : false;

            if (state.isWatchInfoError) {
              return ErrorRetryWidget(
                lottie: 'assets/cat-404.zip',
                onTap: () {
                  BlocProvider.of<WatchBloc>(context)
                      .add(WatchEvent.getExplodeWatchInfo(id: id));
                  BlocProvider.of<WatchBloc>(context)
                      .add(WatchEvent.getExplodeMuxStreamInfo(id: id));
                  BlocProvider.of<WatchBloc>(context)
                      .add(WatchEvent.getExplodeRelatedVideoInfo(id: id));
                },
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
                              (state.isLoading || state.isSubtitleLoading)
                                  ? Container(
                                      height: 230,
                                      color: kBlackColor,
                                      child: Center(
                                        child: cIndicator(context),
                                      ),
                                    )
                                  : ExplodeVideoPlayerWidget(
                                      videoId: id,
                                      watchInfo: state.explodeWatchResp,
                                      defaultQuality:
                                          settingsState.defaultQuality,
                                      playbackPosition: savedState
                                              .videoInfo?.playbackPosition ??
                                          0,
                                      isSaved: isSaved,
                                      liveUrl: state.liveStreamUrl,
                                      availableVideoTracks:
                                          state.muxedStreams ?? [],
                                      subtitles: state.isSubtitleLoading
                                          ? []
                                          : state.subtitles,
                                      selectedVideoBasicDetails:
                                          state.selectedVideoBasicDetails,
                                    ),
                              BlocBuilder<WatchBloc, WatchState>(
                                builder: (context, state) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        top: 12, left: 20, right: 20),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // * caption row
                                          (state.isLoading)
                                              ? CaptionRowWidget(
                                                  caption: state
                                                          .selectedVideoBasicDetails
                                                          ?.title ??
                                                      '',
                                                  icon:
                                                      state.isDescriptionTapped
                                                          ? CupertinoIcons
                                                              .chevron_up
                                                          : CupertinoIcons
                                                              .chevron_down,
                                                )
                                              : GestureDetector(
                                                  onTap: () => BlocProvider.of<
                                                          WatchBloc>(context)
                                                      .add(WatchEvent
                                                          .tapDescription()),
                                                  child: CaptionRowWidget(
                                                    caption: watchInfo.title,
                                                    icon:
                                                        state.isDescriptionTapped
                                                            ? CupertinoIcons
                                                                .chevron_up
                                                            : CupertinoIcons
                                                                .chevron_down,
                                                  ),
                                                ),

                                          kHeightBox5,

                                          // * views row
                                          (state.isLoading)
                                              ? const SizedBox()
                                              : ViewRowWidget(
                                                  views: watchInfo.viewCount,
                                                  uploadedDate: watchInfo
                                                      .uploadDate
                                                      .toString(),
                                                ),

                                          kHeightBox10,

                                          // * like row
                                          (state.isLoading)
                                              ? const ShimmerLikeWidget()
                                              : ExplodeLikeSection(
                                                  id: id,
                                                  state: state,
                                                  watchInfo: watchInfo,
                                                  pipClicked: () => buildPip(
                                                      context: context,
                                                      isSaved: isSaved,
                                                      savedState: savedState,
                                                      settingsState:
                                                          settingsState,
                                                      state: state),
                                                ),

                                          kHeightBox10,

                                          const Divider(),

                                          // * channel info row
                                          (state.isLoading)
                                              ? const ShimmerSubscribeWidget()
                                              : ExplodeChannelInfoSection(
                                                  state: state,
                                                  watchInfo: watchInfo,
                                                  locals: locals),
                                          if (!state.isTapComments)
                                            const Divider(),
                                          kHeightBox10,

                                          // * description
                                          state.isDescriptionTapped
                                              ? ExplodeDescriptionSection(
                                                  height: _height,
                                                  watchInfo: watchInfo,
                                                  locals: locals)
                                              :
                                              // * related videos
                                              state.isTapComments == false
                                                  ? settingsState.isHideRelated
                                                      ? const SizedBox()
                                                      : (state.isRelatedVideosLoading)
                                                          ? SizedBox(
                                                              height: 350,
                                                              child: ListView
                                                                  .separated(
                                                                      scrollDirection:
                                                                          Axis
                                                                              .horizontal,
                                                                      itemBuilder: (context, index) {
                                                                        return const ShimmerRelatedVideoWidget();
                                                                      },
                                                                      separatorBuilder:
                                                                          (context, index) =>
                                                                              kWidthBox10,
                                                                      itemCount:
                                                                          5),
                                                            )
                                                          : ExplodeRelatedVideoSection(
                                                              locals: locals,
                                                              watchInfo:
                                                                  watchInfo,
                                                              related: state
                                                                      .relatedVideos ??
                                                                  [],
                                                            )
                                                  //comments section
                                                  : CommentSection(
                                                      videoId: id,
                                                      state: state,
                                                      height: _height,
                                                      locals: locals,
                                                    )
                                        ]),
                                  );
                                },
                              ),
                            ]),
                      ),
                    ),
                  ),
                ),
              );
            }
          },
        );
      });
    });
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
        return ExplodePipVideoPlayerWidget(
          videoId: id,
          watchInfo: state.explodeWatchResp,
          defaultQuality: settingsState.defaultQuality,
          playbackPosition: savedState.videoInfo?.playbackPosition ?? 0,
          isSaved: isSaved,
          liveUrl: state.liveStreamUrl,
          availableVideoTracks: state.muxedStreams ?? [],
          subtitles: state.isSubtitleLoading ? [] : state.subtitles,
        );
      }, //Optional
    ));
  }
}
