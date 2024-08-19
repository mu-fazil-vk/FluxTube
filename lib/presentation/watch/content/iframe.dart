// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_in_app_pip/flutter_in_app_pip.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/application/watch/watch_bloc.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/presentation/watch/widgets/comment_widgets.dart';
import 'package:fluxtube/presentation/watch/widgets/explode/description_section.dart';
import 'package:fluxtube/presentation/watch/widgets/explode/like_section.dart';
import 'package:fluxtube/presentation/watch/widgets/explode/pip_video_player.dart';
import 'package:fluxtube/presentation/watch/widgets/explode/subscribe_section.dart';
import 'package:fluxtube/widgets/widgets.dart';

import '../widgets/explode/related_video_section.dart';

class IFrameVideoPlayerContent extends StatefulWidget {
  const IFrameVideoPlayerContent({
    super.key,
    required this.id,
    required this.channelId,
    required this.settingsState,
    required this.isSaved,
    required this.savedState,
    this.isLive = false,
  });

  final String id;
  final String channelId;
  final SettingsState settingsState;
  final bool isSaved;
  final SavedState savedState;
  final bool isLive;

  @override
  State<IFrameVideoPlayerContent> createState() =>
      _IFrameVideoPlayerContentState();
}

class _IFrameVideoPlayerContentState extends State<IFrameVideoPlayerContent> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.id,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
        playsInline: false,
        enableCaption: false,
        showVideoAnnotations: false,
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locals = S.of(context);
    final double _height = MediaQuery.of(context).size.height;

    return YoutubePlayerScaffold(
      controller: _controller,
      aspectRatio: 16 / 9,
      enableFullScreenOnVerticalDrag: false,
      builder: (context, player) {
        return Scaffold(
            body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                player,
                BlocBuilder<WatchBloc, WatchState>(
                  builder: (context, state) {
                    final watchInfo = state.explodeWatchResp;
                    return Padding(
                        padding:
                            const EdgeInsets.only(top: 12, left: 20, right: 20),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // * caption row
                              (state.isLoading)
                                  ? CaptionRowWidget(
                                      caption: state.selectedVideoBasicDetails
                                              ?.title ??
                                          '',
                                      icon: state.isDescriptionTapped
                                          ? CupertinoIcons.chevron_up
                                          : CupertinoIcons.chevron_down,
                                    )
                                  : GestureDetector(
                                      onTap: () =>
                                          BlocProvider.of<WatchBloc>(context)
                                              .add(WatchEvent.tapDescription()),
                                      child: CaptionRowWidget(
                                        caption: watchInfo.title,
                                        icon: state.isDescriptionTapped
                                            ? CupertinoIcons.chevron_up
                                            : CupertinoIcons.chevron_down,
                                      ),
                                    ),

                              kHeightBox5,

                              // * views row
                              (state.isLoading)
                                  ? const SizedBox()
                                  : ViewRowWidget(
                                      views: watchInfo.viewCount,
                                      uploadedDate:
                                          watchInfo.uploadDate.toString(),
                                    ),

                              kHeightBox10,

                              // * like row
                              (state.isLoading)
                                  ? const ShimmerLikeWidget()
                                  : ExplodeLikeSection(
                                      id: widget.id,
                                      state: state,
                                      watchInfo: watchInfo,
                                      pipClicked: () => buildPip(
                                          context: context,
                                          isSaved: widget.isSaved,
                                          savedState: widget.savedState,
                                          settingsState: widget.settingsState,
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
                              if (!state.isTapComments) const Divider(),
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
                                      ? widget.settingsState.isHideRelated
                                          ? const SizedBox()
                                          : (state.isRelatedVideosLoading)
                                              ? SizedBox(
                                                  height: 350,
                                                  child: ListView.separated(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return const ShimmerRelatedVideoWidget();
                                                      },
                                                      separatorBuilder:
                                                          (context, index) =>
                                                              kWidthBox10,
                                                      itemCount: 5),
                                                )
                                              : ExplodeRelatedVideoSection(
                                                  locals: locals,
                                                  watchInfo: watchInfo,
                                                  related:
                                                      state.relatedVideos ?? [],
                                                )
                                      //comments section
                                      : CommentSection(
                                          videoId: widget.id,
                                          state: state,
                                          height: _height,
                                          locals: locals,
                                        )
                            ]));
                  },
                ),
              ],
            ),
          ),
        ));
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
        return ExplodePipVideoPlayerWidget(
          videoId: widget.id,
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
