import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_in_app_pip/flutter_in_app_pip.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/enums.dart';
import 'package:fluxtube/presentation/watch/content/iframe.dart';
import 'package:fluxtube/widgets/widgets.dart';

import 'widgets/explode/pip_video_player.dart';

class IFramScreenWatch extends StatefulWidget {
  const IFramScreenWatch({
    super.key,
    required this.id,
    required this.channelId,
  });

  final String id;
  final String channelId;

  @override
  State<IFramScreenWatch> createState() => _IFramScreenWatchState();
}

class _IFramScreenWatchState extends State<IFramScreenWatch> {
  @override
  Widget build(BuildContext context) {
    PictureInPicture.stopPiP();

    BlocProvider.of<SavedBloc>(context)
        .add(const SavedEvent.getAllVideoInfoList());
    BlocProvider.of<SavedBloc>(context)
        .add(SavedEvent.checkVideoInfo(id: widget.id));
    BlocProvider.of<SubscribeBloc>(context)
        .add(SubscribeEvent.checkSubscribeInfo(id: widget.channelId));

    return BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
      return BlocBuilder<WatchBloc, WatchState>(buildWhen: (previous, current) {
        return previous.fetchExplodeWatchInfoStatus !=
                current.fetchExplodeWatchInfoStatus ||
            previous.fetchSubtitlesStatus != current.fetchSubtitlesStatus;
      }, builder: (context, state) {
        return BlocBuilder<SavedBloc, SavedState>(
          builder: (context, savedState) {
            if ((state.oldId != widget.id || state.oldId == null) &&
                !(state.fetchExplodeWatchInfoStatus == ApiStatus.loaded ||
                    state.fetchExplodeWatchInfoStatus == ApiStatus.loading)) {
              BlocProvider.of<WatchBloc>(context)
                  .add(WatchEvent.getExplodeWatchInfo(id: widget.id));
              BlocProvider.of<WatchBloc>(context)
                  .add(WatchEvent.getExplodeMuxStreamInfo(id: widget.id));
              BlocProvider.of<WatchBloc>(context)
                  .add(WatchEvent.getExplodeRelatedVideoInfo(id: widget.id));
              BlocProvider.of<WatchBloc>(context)
                  .add(WatchEvent.getSubtitles(id: widget.id));
            }

            bool isSaved = (savedState.videoInfo?.id == widget.id &&
                    savedState.videoInfo?.isSaved == true)
                ? true
                : false;

            if (state.fetchExplodeWatchInfoStatus == ApiStatus.error) {
              return ErrorRetryWidget(
                lottie: 'assets/cat-404.zip',
                onTap: () {
                  BlocProvider.of<WatchBloc>(context)
                      .add(WatchEvent.getExplodeWatchInfo(id: widget.id));
                  BlocProvider.of<WatchBloc>(context)
                      .add(WatchEvent.getExplodeMuxStreamInfo(id: widget.id));
                  BlocProvider.of<WatchBloc>(context).add(
                      WatchEvent.getExplodeRelatedVideoInfo(id: widget.id));
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
                key: ValueKey(widget.id),
                child: PopScope(
                  canPop: false,
                  onPopInvoked: (didPop) => buildPip(
                      context: context,
                      isSaved: isSaved,
                      savedState: savedState,
                      settingsState: settingsState,
                      state: state),
                  child: IFrameVideoPlayerContent(
                    id: widget.id,
                    isLive: state.explodeWatchResp.isLive,
                    channelId: widget.channelId,
                    settingsState: settingsState,
                    isSaved: isSaved,
                    savedState: savedState,
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
          videoId: widget.id,
          watchInfo: state.explodeWatchResp,
          defaultQuality: settingsState.defaultQuality,
          playbackPosition: savedState.videoInfo?.playbackPosition ?? 0,
          isSaved: isSaved,
          liveUrl: state.liveStreamUrl,
          availableVideoTracks: state.muxedStreams ?? [],
          subtitles: (state.fetchSubtitlesStatus == ApiStatus.loading ||
                  state.fetchSubtitlesStatus == ApiStatus.initial)
              ? []
              : state.subtitles,
        );
      }, //Optional
    ));
  }
}
