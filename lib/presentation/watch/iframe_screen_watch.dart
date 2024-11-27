import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/enums.dart';
import 'package:fluxtube/presentation/watch/content/iframe.dart';
import 'package:fluxtube/widgets/widgets.dart';

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
    BlocProvider.of<WatchBloc>(context).add(WatchEvent.togglePip(value: false));
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
                !(state.fetchExplodeWatchInfoStatus == ApiStatus.error ||
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
              return PopScope(
                canPop: true,
                onPopInvokedWithResult: (didPop, _) {
                  if (!settingsState.isPipDisabled) {
                    BlocProvider.of<WatchBloc>(context)
                        .add(WatchEvent.togglePip(value: true));
                  }
                },
                child: IFrameVideoPlayerContent(
                  id: widget.id,
                  isLive: state.explodeWatchResp.isLive,
                  channelId: widget.channelId,
                  settingsState: settingsState,
                  isSaved: isSaved,
                  savedState: savedState,
                ),
              );
            }
          },
        );
      });
    });
  }
}
