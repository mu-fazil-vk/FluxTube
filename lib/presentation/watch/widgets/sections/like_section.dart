import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/strings.dart';
import 'package:fluxtube/domain/saved/models/local_store.dart';
import 'package:fluxtube/domain/watch/models/piped/video/watch_resp.dart';
import 'package:fluxtube/domain/watch/playback/piped_stream_helper.dart';
import 'package:fluxtube/presentation/download/widgets/download_options_sheet.dart';
import 'package:fluxtube/presentation/settings/utils/launch_url.dart';
import 'package:fluxtube/presentation/watch/widgets/redesigned/action_buttons_row.dart';
import 'package:fluxtube/presentation/watch/widgets/redesigned/share_bottom_sheet.dart';

class LikeSection extends StatelessWidget {
  const LikeSection({
    super.key,
    required this.id,
    required this.watchInfo,
    required this.state,
    required this.pipClicked,
  });

  final String id;
  final WatchResp watchInfo;
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
              likes: watchInfo.likes ?? 0,
              dislikes: watchInfo.dislikes ?? 0,
              showDislike: settingsState.isDislikeVisible,
              isCommentActive: state.isTapComments,
              showPip: !settingsState.isPipDisabled,
              isSaved: isSaved,
              isLive: watchInfo.livestream ?? false,
              onTapComment: () {
                if (state.isDescriptionTapped) {
                  BlocProvider.of<WatchBloc>(context)
                      .add(WatchEvent.tapDescription());
                }
                BlocProvider.of<WatchBloc>(context)
                    .add(WatchEvent.getCommentData(id: id));
              },
              onTapShare: () {
                ShareBottomSheet.show(
                  context,
                  videoId: id,
                  videoTitle: watchInfo.title ?? '',
                  thumbnailUrl: watchInfo.thumbnailUrl,
                );
              },
              onTapSave: () {
                BlocProvider.of<SavedBloc>(context).add(
                  SavedEvent.addVideoInfo(
                    videoInfo: LocalStoreVideoInfo(
                        id: id,
                        title: watchInfo.title,
                        views: watchInfo.views,
                        thumbnail: watchInfo.thumbnailUrl,
                        uploadedDate: watchInfo.uploadDate,
                        uploaderAvatar: watchInfo.uploaderAvatar,
                        uploaderName: watchInfo.uploader,
                        uploaderId: watchInfo.uploaderUrl!.split("/").last,
                        uploaderSubscriberCount:
                            watchInfo.uploaderSubscriberCount.toString(),
                        duration: watchInfo.duration,
                        playbackPosition:
                            savedState.videoInfo?.playbackPosition,
                        uploaderVerified: watchInfo.uploaderVerified,
                        isSaved: !isSaved,
                        isLive: watchInfo.livestream,
                        isHistory: savedState.videoInfo?.isHistory),
                  ),
                );
              },
              onTapDownload: () {
                // Convert Piped streams to NewPipe format for download compatibility
                final separated = PipedStreamHelper.separateVideoStreams(watchInfo.videoStreams);
                final audioStreams = PipedStreamHelper.convertAudioStreams(watchInfo.audioStreams);

                DownloadOptionsSheet.showWithStreams(
                  context,
                  videoId: id,
                  title: watchInfo.title ?? '',
                  channelName: watchInfo.uploader ?? '',
                  thumbnailUrl: watchInfo.thumbnailUrl,
                  duration: watchInfo.duration,
                  serviceType: settingsState.ytService,
                  videoStreams: separated.muxed,
                  videoOnlyStreams: separated.videoOnly,
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
