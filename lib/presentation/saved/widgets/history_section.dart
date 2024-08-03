import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/saved/saved_bloc.dart';
import 'package:fluxtube/application/settings/settings_bloc.dart';
import 'package:fluxtube/application/watch/watch_bloc.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/domain/saved/models/local_store.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/widgets/related_video_widget.dart';
import 'package:go_router/go_router.dart';

class HistoryVideosSection extends StatelessWidget {
  const HistoryVideosSection({
    super.key,
    required this.locals,
    required this.settingsState,
    required this.savedState,
  });

  final S locals;
  final SettingsState settingsState;
  final SavedState savedState;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: settingsState.isHistoryVisible &&
              savedState.localSavedHistoryVideos.isNotEmpty,
          child: Padding(
            padding: const EdgeInsets.only(top: 15, bottom: 10, left: 10),
            child: Text(
              locals.history,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
        //history visibility check
        settingsState.isHistoryVisible &&
                savedState.localSavedHistoryVideos.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: SizedBox(
                  height: 250,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final historyVideo =
                          savedState.localSavedHistoryVideos[index];
                      final String videoId = historyVideo.id;

                      final String channelId = historyVideo.uploaderId!;

                      return GestureDetector(
                        onTap: () {
                          BlocProvider.of<WatchBloc>(context).add(
                              WatchEvent.assignTitle(
                                  title: historyVideo.title ?? ''));
                          context.go('/watch/$videoId/$channelId');
                        },
                        child: RelatedVideoWidget(
                          title: historyVideo.title ?? locals.noVideoTitle,
                          thumbnailUrl: historyVideo.thumbnail,
                          duration: historyVideo.isLive ?? false
                              ? -1
                              : historyVideo.duration,
                          isDeleteIcon: true,
                          onDeleteTap: () =>
                              BlocProvider.of<SavedBloc>(context).add(
                            SavedEvent.addVideoInfo(
                              videoInfo: LocalStoreVideoInfo(
                                  id: videoId,
                                  title: historyVideo.title,
                                  views: historyVideo.views,
                                  thumbnail: historyVideo.thumbnail,
                                  uploadedDate: historyVideo.uploadedDate,
                                  uploaderAvatar: historyVideo.uploaderAvatar,
                                  uploaderName: historyVideo.uploaderName,
                                  uploaderId: historyVideo.uploaderId,
                                  uploaderSubscriberCount:
                                      historyVideo.uploaderSubscriberCount,
                                  duration: historyVideo.duration,
                                  uploaderVerified:
                                      historyVideo.uploaderVerified,
                                  isSaved: savedState.videoInfo?.isSaved,
                                  isHistory: false),
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => kWidthBox10,
                    itemCount: savedState.localSavedHistoryVideos.length,
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
