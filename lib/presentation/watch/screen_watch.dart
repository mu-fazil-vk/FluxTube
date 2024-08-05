import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_in_app_pip/flutter_in_app_pip.dart';
import 'package:fluxtube/application/saved/saved_bloc.dart';
import 'package:fluxtube/application/watch/watch_bloc.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/presentation/watch/widgets/comment_widgets.dart';
import 'package:fluxtube/presentation/watch/widgets/sections/description_section.dart';
import 'package:fluxtube/presentation/watch/widgets/sections/like_section.dart';
import 'package:fluxtube/presentation/watch/widgets/sections/related_video_section.dart';
import 'package:fluxtube/presentation/watch/widgets/sections/subscribe_section.dart';
import 'package:fluxtube/widgets/error_widget.dart';
import 'package:fluxtube/widgets/indicator.dart';
import 'package:fluxtube/widgets/shimmer_home_video_card.dart';
import 'package:fluxtube/widgets/shimmer_related_video.dart';

import '../../application/settings/settings_bloc.dart';
import '../../application/subscribe/subscribe_bloc.dart';
import '../../core/constants.dart';
import '../../widgets/common_video_description_widget.dart';
import 'widgets/pip_video_player.dart';
import 'widgets/video_player_widget.dart';

class ScreenWatch extends StatelessWidget {
  const ScreenWatch({
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
        return current != previous;
      }, builder: (context, state) {
        return BlocBuilder<SavedBloc, SavedState>(
          builder: (context, savedState) {
            if ((state.oldId != id || state.oldId == null) &&
                !state.isWatchInfoError) {
              BlocProvider.of<WatchBloc>(context)
                  .add(WatchEvent.getWatchInfo(id: id));
              BlocProvider.of<WatchBloc>(context)
                  .add(WatchEvent.getSubtitles(id: id));
            }

            final watchInfo = state.watchResp;

            bool isSaved = (savedState.videoInfo?.id == id &&
                    savedState.videoInfo?.isSaved == true)
                ? true
                : false;

            if (state.isWatchInfoError ||
                (settingsState.isHlsPlayer && watchInfo.hls == null)) {
              return ErrorRetryWidget(
                lottie: 'assets/cat-404.zip',
                onTap: () => BlocProvider.of<WatchBloc>(context)
                    .add(WatchEvent.getWatchInfo(id: id)),
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
                                    height: 200,
                                    color: kBlackColor,
                                    child: Center(
                                      child: cIndicator(context),
                                    ),
                                  )
                                  : VideoPlayerWidget(
                                      videoId: id,
                                      watchInfo: state.watchResp,
                                      defaultQuality:
                                          settingsState.defaultQuality,
                                      playbackPosition: savedState
                                              .videoInfo?.playbackPosition ??
                                          0,
                                      isSaved: isSaved,
                                      isHlsPlayer: settingsState.isHlsPlayer,
                                      subtitles: state.isSubtitleLoading
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
                                      (state.isLoading)
                                          ? CaptionRowWidget(
                                              caption: state.title,
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
                                      (state.isLoading)
                                          ? const SizedBox()
                                          : ViewRowWidget(
                                              views: watchInfo.views,
                                              uploadedDate:
                                                  watchInfo.uploadDate,
                                            ),

                                      kHeightBox10,

                                      // * like row
                                      (state.isLoading)
                                          ? const ShimmerLikeWidget()
                                          : LikeSection(
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
                                      (state.isLoading)
                                          ? const ShimmerSubscribeWidget()
                                          : ChannelInfoSection(
                                              state: state,
                                              watchInfo: watchInfo,
                                              locals: locals),
                                      if (!state.isTapComments) const Divider(),
                                      kHeightBox10,

                                      // * description
                                      state.isDescriptionTapped
                                          ? DescriptionSection(
                                              height: _height,
                                              watchInfo: watchInfo,
                                              locals: locals)
                                          :
                                          // * related videos
                                          state.isTapComments == false
                                              ? settingsState.isHideRelated
                                                  ? const SizedBox()
                                                  : (state.isLoading)
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
                                                      : RelatedVideoSection(
                                                          locals: locals,
                                                          watchInfo: watchInfo)
                                              //comments section
                                              : CommentSection(
                                                  videoId: id,
                                                  state: state,
                                                  height: _height,
                                                  locals: locals,
                                                )
                                    ]),
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
        return PipVideoPlayerWidget(
          videoId: id,
          watchInfo: state.watchResp,
          defaultQuality: settingsState.defaultQuality,
          playbackPosition: savedState.videoInfo?.playbackPosition ?? 0,
          isSaved: isSaved,
          isHlsPlayer: settingsState.isHlsPlayer,
          subtitles: state.isSubtitleLoading ? [] : state.subtitles,
        );
      }, //Optional
    ));
  }
}
