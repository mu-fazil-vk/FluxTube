import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/domain/saved/models/local_store.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/widgets/error_widget.dart';
import 'package:fluxtube/widgets/related_video_widget.dart';
import 'package:go_router/go_router.dart';

import '../../application/saved/saved_bloc.dart';
import '../../application/settings/settings_bloc.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/home_video_info_card_widget.dart';

class ScreenSaved extends StatelessWidget {
  const ScreenSaved({super.key});

  @override
  Widget build(BuildContext context) {
    final locals = S.of(context);
    BlocProvider.of<SavedBloc>(context)
        .add(const SavedEvent.getAllVideoInfoList());
    return SafeArea(
        child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  BlocBuilder<SavedBloc, SavedState>(
                    builder: (context, state) {
                      return CustomAppBar(
                        title: locals.savedVideosTitle,
                        count: state.localSavedVideos.length,
                      );
                    },
                  )
                ],
            body: BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, settingsState) {
                return BlocBuilder<SavedBloc, SavedState>(
                  builder: (context, savedState) {
                    if (savedState.isLoading) {
                      return Center(
                        child: CupertinoActivityIndicator(
                            color: Theme.of(context).indicatorColor),
                      );
                    } else if (savedState.isError) {
                      return Center(
                        child: Text(locals.thereIsNoSavedOrHistoryVideos),
                      );
                    } else {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Visibility(
                            visible: settingsState.isHistoryVisible &&
                                savedState.localSavedHistoryVideos.isNotEmpty,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 15, bottom: 10, left: 10),
                              child: Text(
                                locals.history,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ),
                          //history visibility check
                          settingsState.isHistoryVisible &&
                                  savedState.localSavedHistoryVideos.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: SizedBox(
                                    height: 250,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, index) {
                                        final historyVideo = savedState
                                            .localSavedHistoryVideos[index];
                                        final String videoId = historyVideo.id;

                                        final String channelId =
                                            historyVideo.uploaderId!;

                                        return GestureDetector(
                                          onTap: () => context
                                              .go('/watch/$videoId/$channelId'),
                                          child: RelatedVideoWidget(
                                            title: historyVideo.title ??
                                                locals.noVideoTitle,
                                            thumbnailUrl:
                                                historyVideo.thumbnail,
                                            duration:
                                                historyVideo.isLive ?? false
                                                    ? -1
                                                    : historyVideo.duration,
                                            isDeleteIcon: true,
                                            onDeleteTap: () =>
                                                BlocProvider.of<SavedBloc>(
                                                        context)
                                                    .add(
                                              SavedEvent.addVideoInfo(
                                                videoInfo: LocalStoreVideoInfo(
                                                    id: videoId,
                                                    title: historyVideo.title,
                                                    views: historyVideo.views,
                                                    thumbnail:
                                                        historyVideo.thumbnail,
                                                    uploadedDate: historyVideo
                                                        .uploadedDate,
                                                    uploaderAvatar: historyVideo
                                                        .uploaderAvatar,
                                                    uploaderName: historyVideo
                                                        .uploaderName,
                                                    uploaderId:
                                                        historyVideo.uploaderId,
                                                    uploaderSubscriberCount:
                                                        historyVideo
                                                            .uploaderSubscriberCount,
                                                    duration:
                                                        historyVideo.duration,
                                                    uploaderVerified:
                                                        historyVideo
                                                            .uploaderVerified,
                                                    isSaved: savedState
                                                        .videoInfo?.isSaved,
                                                    isHistory: false),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      separatorBuilder: (context, index) =>
                                          kWidthBox10,
                                      itemCount: savedState
                                          .localSavedHistoryVideos.length,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),

                          Expanded(
                            child: savedState.localSavedVideos.isEmpty
                                ? Center(
                                    child: Text(locals.thereIsNoSavedVideos),
                                  )
                                : savedState.isLoading //loading check
                                    ? Center(
                                        child: CupertinoActivityIndicator(
                                            color: Theme.of(context)
                                                .indicatorColor),
                                      )
                                    : savedState.isError //empty list check
                                        ? ErrorRetryWidget(
                                            lottie: 'assets/black-cat.zip',
                                            onTap: () =>
                                                BlocProvider.of<SavedBloc>(
                                                        context)
                                                    .add(const SavedEvent
                                                        .getAllVideoInfoList()),
                                          )
                                        // disply result
                                        : ListView.builder(
                                            itemBuilder: (context, index) {
                                              final savedVideo = savedState
                                                  .localSavedVideos[index];
                                              final String videoId =
                                                  savedVideo.id;

                                              final String channelId =
                                                  savedVideo.uploaderId!;
                                              return GestureDetector(
                                                onTap: () => context.go(
                                                    '/watch/$videoId/$channelId'),
                                                child: HomeVideoInfoCardWidget(
                                                  cardInfo: savedVideo,
                                                  subscribeRowVisible: false,
                                                  isLive: savedVideo.isLive ??
                                                      false,
                                                ),
                                              );
                                            },
                                            itemCount: savedState
                                                .localSavedVideos.length,
                                          ),
                          ),
                        ],
                      );
                    }
                  },
                );
              },
            )));
  }
}
