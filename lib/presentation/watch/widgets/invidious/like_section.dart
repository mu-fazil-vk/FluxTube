import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/strings.dart';
import 'package:fluxtube/domain/saved/models/local_store.dart';
import 'package:fluxtube/domain/watch/models/invidious/video/invidious_watch_resp.dart';
import 'package:fluxtube/domain/watch/playback/invidious_stream_helper.dart';
import 'package:fluxtube/presentation/download/widgets/download_options_sheet.dart';
import 'package:fluxtube/presentation/settings/utils/launch_url.dart';
import 'package:fluxtube/presentation/watch/widgets/redesigned/action_buttons_row.dart';
import 'package:fluxtube/presentation/watch/widgets/redesigned/share_bottom_sheet.dart';

class InvidiousLikeSection extends StatelessWidget {
  const InvidiousLikeSection({
    super.key,
    required this.id,
    required this.watchInfo,
    required this.state,
    required this.pipClicked,
  });

  final String id;
  final InvidiousWatchResp watchInfo;
  final WatchState state;
  final VoidCallback pipClicked;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SavedBloc, SavedState>(
      buildWhen: (previous, current) {
        // Only rebuild if the isSaved state for THIS video actually changed
        final prevIsSaved = previous.videoInfo?.id == id &&
            (previous.videoInfo?.isSaved ?? false);
        final currIsSaved = current.videoInfo?.id == id &&
            (current.videoInfo?.isSaved ?? false);
        return prevIsSaved != currIsSaved;
      },
      builder: (context, savedState) {
        bool isSaved = (savedState.videoInfo?.id == id &&
                savedState.videoInfo?.isSaved == true)
            ? true
            : false;
        return BlocBuilder<SettingsBloc, SettingsState>(
          buildWhen: (previous, current) =>
              previous.isDislikeVisible != current.isDislikeVisible ||
              previous.isPipDisabled != current.isPipDisabled,
          builder: (context, settingsState) {
            return ActionButtonsRow(
              videoId: id,
              likes: watchInfo.likeCount ?? 0,
              dislikes: watchInfo.dislikeCount ?? 0,
              showDislike: settingsState.isDislikeVisible,
              isCommentActive: state.isTapComments,
              showPip: !settingsState.isPipDisabled,
              isSaved: isSaved,
              isLive: watchInfo.liveNow ?? false,
              onTapComment: () {
                if (state.isDescriptionTapped) {
                  BlocProvider.of<WatchBloc>(context)
                      .add(WatchEvent.tapDescription());
                }
                log(state.isTapComments.toString());
                BlocProvider.of<WatchBloc>(context)
                    .add(WatchEvent.getInvidiousComments(id: id));
              },
              onTapShare: () {
                ShareBottomSheet.show(
                  context,
                  videoId: id,
                  videoTitle: watchInfo.title ?? '',
                  thumbnailUrl: watchInfo.videoThumbnails?.first.url,
                );
              },
              onTapSave: () {
                BlocProvider.of<SavedBloc>(context).add(
                  SavedEvent.addVideoInfo(
                    videoInfo: LocalStoreVideoInfo(
                        id: id,
                        title: watchInfo.title,
                        views: watchInfo.viewCount,
                        thumbnail: watchInfo.videoThumbnails!.first.url,
                        uploadedDate: watchInfo.published.toString(),
                        uploaderAvatar: watchInfo.authorThumbnails!.first.url,
                        uploaderName: watchInfo.author,
                        uploaderId: watchInfo.authorId,
                        uploaderSubscriberCount: watchInfo.subCountText,
                        duration: watchInfo.lengthSeconds,
                        playbackPosition:
                            savedState.videoInfo?.playbackPosition,
                        uploaderVerified: watchInfo.authorVerified,
                        isSaved: !isSaved,
                        isLive: watchInfo.liveNow,
                        isHistory: savedState.videoInfo?.isHistory),
                  ),
                );
              },
              onTapDownload: () {
                // Convert Invidious streams to NewPipe format for download compatibility
                final videoOnlyStreams = InvidiousStreamHelper.convertVideoStreams(watchInfo.adaptiveFormats);
                final muxedStreams = InvidiousStreamHelper.convertMuxedStreams(watchInfo.formatStreams);
                final audioStreams = InvidiousStreamHelper.convertAudioStreams(watchInfo.adaptiveFormats);

                DownloadOptionsSheet.showWithStreams(
                  context,
                  videoId: id,
                  title: watchInfo.title ?? '',
                  channelName: watchInfo.author ?? '',
                  thumbnailUrl: watchInfo.videoThumbnails?.first.url,
                  duration: watchInfo.lengthSeconds,
                  serviceType: settingsState.ytService,
                  videoStreams: muxedStreams,
                  videoOnlyStreams: videoOnlyStreams,
                  audioStreams: audioStreams,
                );
              },
              onTapYoutube: () async => await urlLaunchWithSettings(context, '$kYTBaseUrl$id'),
              onTapPip: pipClicked,
            );
          },
        );
      },
    );
  }
}
