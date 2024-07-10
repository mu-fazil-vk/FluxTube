import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/saved/saved_bloc.dart';
import 'package:fluxtube/application/settings/settings_bloc.dart';
import 'package:fluxtube/application/watch/watch_bloc.dart';
import 'package:fluxtube/core/strings.dart';
import 'package:fluxtube/domain/saved/models/local_store.dart';
import 'package:fluxtube/domain/watch/models/video/watch_resp.dart';
import 'package:fluxtube/presentation/watch/widgets/like_widget.dart';
import 'package:share_plus/share_plus.dart';

class LikeSection extends StatelessWidget {
  const LikeSection({
    super.key,
    required this.id,
    required this.watchInfo, required this.state,
  });

  final String id;
  final WatchResp watchInfo;
  final WatchState state;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SavedBloc, SavedState>(
      builder: (context, savedState) {
        bool isSaved = (savedState.videoInfo?.id == id &&
                savedState.videoInfo?.isSaved == true)
            ? true
            : false;
        return BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, settingsState) {
            return LikeRowWidget(
              like: watchInfo.likes ?? 0,
              dislikes: watchInfo.dislikes ?? 0,
              isDislikeVisible: settingsState.isDislikeVisible,
              isCommentTapped: state.isTapComments,
              onTapComment: () {
                if (state.isDescriptionTapped) {
                  BlocProvider.of<WatchBloc>(context)
                      .add(WatchEvent.tapDescription());
                }
                BlocProvider.of<WatchBloc>(context)
                    .add(WatchEvent.getCommentData(id: id));
              },
              onTapShare: () async {
                await Share.share("${watchInfo.title}\n\n$kYTBaseUrl$id");
              },
              isSaveTapped: isSaved,
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
                            watchInfo.uploaderSubscriberCount,
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
            );
          },
        );
      },
    );
  }
}