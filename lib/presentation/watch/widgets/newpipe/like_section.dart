import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/services/ryd_service.dart';
import 'package:fluxtube/core/strings.dart';
import 'package:fluxtube/domain/saved/models/local_store.dart';
import 'package:fluxtube/domain/watch/models/newpipe/newpipe_watch_resp.dart';
import 'package:fluxtube/presentation/download/widgets/download_options_sheet.dart';
import 'package:fluxtube/presentation/settings/utils/launch_url.dart';
import 'package:fluxtube/presentation/watch/widgets/redesigned/action_buttons_row.dart';
import 'package:fluxtube/presentation/watch/widgets/redesigned/share_bottom_sheet.dart';

class NewPipeLikeSection extends StatelessWidget {
  const NewPipeLikeSection({
    super.key,
    required this.id,
    required this.watchInfo,
    required this.state,
    required this.pipClicked,
  });

  final String id;
  final NewPipeWatchResp watchInfo;
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
            final nativeDislikes = watchInfo.dislikeCount ?? -1;
            if (!settingsState.isDislikeVisible || nativeDislikes > 0) {
              return _buildRow(
                  context, settingsState, isSaved, savedState, nativeDislikes);
            }
            return FutureBuilder<int?>(
              future: RydService.instance.dislikes(id),
              builder: (context, snapshot) => _buildRow(context, settingsState,
                  isSaved, savedState, snapshot.data ?? -1),
            );
          },
        );
      },
    );
  }

  Widget _buildRow(BuildContext context, SettingsState settingsState,
      bool isSaved, SavedState savedState, int dislikes) {
    return ActionButtonsRow(
      likes: watchInfo.likeCount ?? 0,
      dislikes: dislikes,
      showDislike: settingsState.isDislikeVisible,
      isCommentActive: state.isTapComments,
      showPip: !settingsState.isPipDisabled,
      isSaved: isSaved,
      isLive: watchInfo.isLive ?? false,
      onTapComment: () {
        if (state.isDescriptionTapped) {
          BlocProvider.of<WatchBloc>(context).add(WatchEvent.tapDescription());
        }
        log(state.isTapComments.toString());
        BlocProvider.of<WatchBloc>(context)
            .add(WatchEvent.getNewPipeComments(id: id));
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
                views: watchInfo.viewCount,
                thumbnail: watchInfo.thumbnailUrl,
                uploadedDate: watchInfo.textualUploadDate ?? '',
                uploaderAvatar: watchInfo.uploaderAvatarUrl,
                uploaderName: watchInfo.uploaderName,
                uploaderId: _extractChannelId(watchInfo.uploaderUrl),
                uploaderSubscriberCount:
                    watchInfo.uploaderSubscriberCount?.toString(),
                duration: watchInfo.duration,
                playbackPosition: savedState.videoInfo?.playbackPosition,
                uploaderVerified: watchInfo.uploaderVerified,
                isSaved: !isSaved,
                isLive: watchInfo.isLive,
                isHistory: savedState.videoInfo?.isHistory),
          ),
        );
      },
      onTapDownload: () {
        // Use NewPipe streams directly for downloads - same URLs that work for playback
        DownloadOptionsSheet.showWithStreams(
          context,
          videoId: id,
          title: watchInfo.title ?? '',
          channelName: watchInfo.uploaderName ?? '',
          thumbnailUrl: watchInfo.thumbnailUrl,
          duration: watchInfo.duration,
          serviceType: settingsState.ytService,
          videoStreams: watchInfo.videoStreams ?? [],
          videoOnlyStreams: watchInfo.videoOnlyStreams ?? [],
          audioStreams: watchInfo.audioStreams ?? [],
        );
      },
      onTapYoutube: () async =>
          await urlLaunchWithSettings(context, '$kYTBaseUrl$id'),
      onTapPip: pipClicked,
    );
  }

  String? _extractChannelId(String? uploaderUrl) {
    if (uploaderUrl == null) return null;
    // Extract channel ID from URL like "https://www.youtube.com/channel/UCxxx"
    final uri = Uri.tryParse(uploaderUrl);
    if (uri != null && uri.pathSegments.isNotEmpty) {
      final channelIndex = uri.pathSegments.indexOf('channel');
      if (channelIndex != -1 && channelIndex + 1 < uri.pathSegments.length) {
        return uri.pathSegments[channelIndex + 1];
      }
    }
    return null;
  }
}
