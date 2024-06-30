import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/saved/saved_bloc.dart';
import 'package:fluxtube/application/watch/watch_bloc.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:fluxtube/core/operations/math_operations.dart';
import 'package:fluxtube/core/strings.dart';
import 'package:fluxtube/domain/saved/models/local_store.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/widgets/error_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:simple_html_css/simple_html_css.dart';

import '../../application/settings/settings_bloc.dart';
import '../../application/subscribe/subscribe_bloc.dart';
import '../../core/constants.dart';
import '../../domain/subscribes/models/subscribe.dart';
import '../../widgets/common_video_description_widget.dart';
import 'widgets/comment_like_widget.dart';
import '../../widgets/related_video_widget.dart';
import 'widgets/video_player_widget.dart';

class ScreenWatch extends StatelessWidget {
  const ScreenWatch({super.key, required this.id, required this.channelId});

  final String id;
  final String channelId;

  @override
  Widget build(BuildContext context) {
    final locals = S.of(context);
    final double _height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          return BlocBuilder<WatchBloc, WatchState>(
            builder: (context, state) {
              if ((state.oldId != id || state.oldId == null) &&
                  !state.isWatchInfoError) {
                BlocProvider.of<WatchBloc>(context)
                    .add(WatchEvent.getWatchInfo(id: id));
              }

              BlocProvider.of<SavedBloc>(context)
                  .add(const SavedEvent.getAllVideoInfoList());
              BlocProvider.of<SavedBloc>(context)
                  .add(SavedEvent.checkVideoInfo(id: id));
              BlocProvider.of<SubscribeBloc>(context)
                  .add(SubscribeEvent.checkSubscribeInfo(id: channelId));

              final watchInfo = state.watchResp;

              if (state.isLoading) {
                return Center(
                    child: CupertinoActivityIndicator(
                        color: Theme.of(context).indicatorColor));
              } else if (state.isWatchInfoError ||
                  (settingsState.isHlsPlayer && watchInfo.hls == null)) {
                return ErrorRetryWidget(
                  lottie: 'assets/cat-404.zip',
                  onTap: () => BlocProvider.of<WatchBloc>(context)
                      .add(WatchEvent.getWatchInfo(id: id)),
                );
              } else {
                return SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(children: [
                            BlocBuilder<SavedBloc, SavedState>(
                              builder: (context, savedState) {
                                return VideoPlayerWidget(
                                  videoId: id,
                                  watchInfo: state.watchResp,
                                  defaultQuality: settingsState.defaultQuality,
                                  playbackPosition:
                                      savedState.videoInfo?.playbackPosition ??
                                          0,
                                  isSaved:
                                      savedState.videoInfo?.isSaved ?? false,
                                  isHlsPlayer: settingsState.isHlsPlayer,
                                );
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 12, left: 20, right: 20),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // * caption row
                                    GestureDetector(
                                      onTap: () =>
                                          BlocProvider.of<WatchBloc>(context)
                                              .add(WatchEvent.tapDescription()),
                                      child: CaptionRowWidget(
                                        caption: watchInfo.title ??
                                            locals.noVideoTitle,
                                        icon: state.isDescriptionTapped
                                            ? CupertinoIcons.chevron_up
                                            : CupertinoIcons.chevron_down,
                                      ),
                                    ),

                                    kHeightBox5,

                                    // * views row
                                    ViewRowWidget(
                                      views: watchInfo.views,
                                      uploadedDate: watchInfo.uploadDate,
                                    ),

                                    kHeightBox10,

                                    // * like row
                                    BlocBuilder<SavedBloc, SavedState>(
                                      builder: (context, savedState) {
                                        return BlocBuilder<SettingsBloc,
                                            SettingsState>(
                                          builder: (context, settingsState) {
                                            return LikeRowWidget(
                                              like: watchInfo.likes ?? 0,
                                              dislikes: watchInfo.dislikes ?? 0,
                                              isDislikeVisible: settingsState
                                                  .isDislikeVisible,
                                              isCommentTapped:
                                                  state.isTapComments,
                                              onTapComment: () {
                                                if (state.isDescriptionTapped) {
                                                  BlocProvider.of<WatchBloc>(
                                                          context)
                                                      .add(WatchEvent
                                                          .tapDescription());
                                                }
                                                BlocProvider.of<WatchBloc>(
                                                        context)
                                                    .add(WatchEvent
                                                        .getCommentData(
                                                            id: id));
                                              },
                                              onTapShare: () async {
                                                await Share.share(
                                                    "${watchInfo.title}\n\n$kYTBaseUrl$id");
                                              },
                                              isSaveTapped: savedState
                                                      .videoInfo?.isSaved ==
                                                  true,
                                              onTapSave: () {
                                                if (savedState
                                                        .videoInfo?.isSaved ==
                                                    false) {
                                                  BlocProvider.of<SavedBloc>(
                                                          context)
                                                      .add(
                                                    SavedEvent.addVideoInfo(
                                                      videoInfo: LocalStoreVideoInfo(
                                                          id: id,
                                                          title:
                                                              watchInfo.title,
                                                          views:
                                                              watchInfo.views,
                                                          thumbnail: watchInfo
                                                              .thumbnailUrl,
                                                          uploadedDate: watchInfo
                                                              .uploadDate,
                                                          uploaderAvatar: watchInfo
                                                              .uploaderAvatar,
                                                          uploaderName:
                                                              watchInfo
                                                                  .uploader,
                                                          uploaderId: watchInfo
                                                              .uploaderUrl!
                                                              .split("/")
                                                              .last,
                                                          uploaderSubscriberCount:
                                                              watchInfo
                                                                  .uploaderSubscriberCount,
                                                          duration: watchInfo
                                                              .duration,
                                                          playbackPosition:
                                                              savedState
                                                                  .videoInfo
                                                                  ?.playbackPosition,
                                                          uploaderVerified:
                                                              watchInfo
                                                                  .uploaderVerified,
                                                          isSaved: true,
                                                          isLive: watchInfo
                                                              .livestream,
                                                          isHistory: savedState
                                                              .videoInfo
                                                              ?.isHistory),
                                                    ),
                                                  );
                                                } else {
                                                  BlocProvider.of<SavedBloc>(
                                                          context)
                                                      .add(
                                                    SavedEvent.addVideoInfo(
                                                      videoInfo: LocalStoreVideoInfo(
                                                          id: id,
                                                          title:
                                                              watchInfo.title,
                                                          views:
                                                              watchInfo.views,
                                                          thumbnail: watchInfo
                                                              .thumbnailUrl,
                                                          uploadedDate: watchInfo
                                                              .uploadDate,
                                                          uploaderAvatar: watchInfo
                                                              .uploaderAvatar,
                                                          uploaderName:
                                                              watchInfo
                                                                  .uploader,
                                                          uploaderId: watchInfo
                                                              .uploaderUrl!
                                                              .split("/")
                                                              .last,
                                                          uploaderSubscriberCount:
                                                              watchInfo
                                                                  .uploaderSubscriberCount,
                                                          duration: watchInfo
                                                              .duration,
                                                          playbackPosition:
                                                              savedState
                                                                  .videoInfo
                                                                  ?.playbackPosition,
                                                          uploaderVerified:
                                                              watchInfo
                                                                  .uploaderVerified,
                                                          isSaved: false,
                                                          isLive: watchInfo
                                                              .livestream,
                                                          isHistory: savedState
                                                              .videoInfo
                                                              ?.isHistory),
                                                    ),
                                                  );
                                                }
                                              },
                                            );
                                          },
                                        );
                                      },
                                    ),

                                    kHeightBox10,

                                    const Divider(),

                                    // * channel info row
                                    Visibility(
                                      visible: !state.isTapComments,
                                      child: BlocBuilder<SubscribeBloc,
                                          SubscribeState>(
                                        builder: (context, subscribeState) {
                                          final String channelId = watchInfo
                                              .uploaderUrl!
                                              .split("/")
                                              .last;
                                          final bool isSubscribed =
                                              subscribeState.channelInfo?.id ==
                                                  channelId;

                                          return SubscribeRowWidget(
                                            subscribed: isSubscribed,
                                            uploaderUrl:
                                                watchInfo.uploaderAvatar,
                                            subcount: watchInfo
                                                .uploaderSubscriberCount,
                                            uploader: watchInfo.uploader ??
                                                locals.noUploaderName,
                                            isVerified:
                                                watchInfo.uploaderVerified ??
                                                    false,
                                            onSubscribeTap: () {
                                              if (isSubscribed) {
                                                BlocProvider.of<SubscribeBloc>(
                                                        context)
                                                    .add(SubscribeEvent
                                                        .deleteSubscribeInfo(
                                                            id: channelId));
                                              } else {
                                                BlocProvider.of<SubscribeBloc>(
                                                        context)
                                                    .add(SubscribeEvent.addSubscribe(
                                                        channelInfo: Subscribe(
                                                            id: channelId,
                                                            channelName: watchInfo
                                                                    .uploader ??
                                                                locals
                                                                    .noUploaderName,
                                                            isVerified: watchInfo
                                                                    .uploaderVerified ??
                                                                false)));
                                              }
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    if (!state.isTapComments) const Divider(),
                                    kHeightBox10,

                                    // * description
                                    state.isDescriptionTapped
                                        ? SizedBox(
                                            height: _height * 0.40,
                                            child: SingleChildScrollView(
                                              child: RichText(
                                                text: HTML.toTextSpan(
                                                    context,
                                                    watchInfo.description ??
                                                        locals
                                                            .noVideoDescription,
                                                    defaultTextStyle:
                                                        Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium),
                                              ),
                                            ),
                                          )
                                        :
                                        // * related videos
                                        state.isTapComments == false
                                            ? Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    locals.relatedTitle,
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .labelMedium!
                                                            .color,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16),
                                                  ),
                                                  kHeightBox20,
                                                  SizedBox(
                                                    height: 250,
                                                    width: double.infinity,
                                                    child: ListView.separated(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        itemBuilder:
                                                            (context, index) {
                                                          final String videoId =
                                                              watchInfo
                                                                  .relatedStreams![
                                                                      index]
                                                                  .url!
                                                                  .split('=')
                                                                  .last;
                                                          final String
                                                              channelId =
                                                              watchInfo
                                                                  .uploaderUrl!
                                                                  .split("/")
                                                                  .last;
                                                          return GestureDetector(
                                                              onTap: () =>
                                                                  context.go(
                                                                      '/watch/$videoId/$channelId'),
                                                              child:
                                                                  RelatedVideoWidget(
                                                                title: watchInfo
                                                                        .title ??
                                                                    locals
                                                                        .noVideoTitle,
                                                                thumbnailUrl: watchInfo
                                                                    .relatedStreams![
                                                                        index]
                                                                    .thumbnail,
                                                                duration:
                                                                    watchInfo
                                                                        .duration,
                                                              ));
                                                        },
                                                        separatorBuilder:
                                                            (context, index) =>
                                                                kWidthBox10,
                                                        itemCount: watchInfo
                                                                .relatedStreams
                                                                ?.length ??
                                                            0),
                                                  ),
                                                ],
                                              )
                                            //comments section
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 10),
                                                child:
                                                    (state.isCommentsLoading ||
                                                            state
                                                                .isCommentError)
                                                        ? Center(
                                                            child: CupertinoActivityIndicator(
                                                                color: Theme.of(
                                                                        context)
                                                                    .indicatorColor),
                                                          )
                                                        : LimitedBox(
                                                            maxHeight:
                                                                _height * 0.45,
                                                            child: ListView
                                                                .separated(
                                                                    shrinkWrap:
                                                                        true,
                                                                    scrollDirection:
                                                                        Axis
                                                                            .vertical,
                                                                    itemBuilder: (context, index) {
                                                                      final storeComment = state
                                                                          .comments
                                                                          .comments[index];
                                                                      return Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.end,
                                                                        children: [
                                                                          CommentWidget(
                                                                            author:
                                                                                storeComment.author ?? locals.commentAuthorNotFound,
                                                                            text:
                                                                                storeComment.commentText ?? '',
                                                                            likes:
                                                                                storeComment.likeCount ?? 0,
                                                                            authorImageUrl:
                                                                                storeComment.thumbnail ?? '',
                                                                          ),
                                                                          if (storeComment.replyCount != null &&
                                                                              storeComment.replyCount != 0)
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(right: 70),
                                                                              child: TextButton(
                                                                                  onPressed: () {
                                                                                    BlocProvider.of<WatchBloc>(context).add(WatchEvent.getCommentRepliesData(id: storeComment.commentId!, nextPage: storeComment.repliesPage!));

                                                                                    commentReplyBottomSheet(context, _height, locals);
                                                                                  },
                                                                                  child: Text("${formatCount(storeComment.replyCount!)} ${locals.repliesPlural(storeComment.replyCount!)}")),
                                                                            )
                                                                        ],
                                                                      );
                                                                    },
                                                                    separatorBuilder:
                                                                        (context,
                                                                                index) =>
                                                                            kHeightBox15,
                                                                    itemCount: state
                                                                        .comments
                                                                        .comments
                                                                        .length),
                                                          ),
                                              ),
                                  ]),
                            ),
                          ])
                        ]),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }

  Future<void> commentReplyBottomSheet(
      BuildContext context, double _height, S locals) {
    return showModalBottomSheet<void>(
        context: context,
        barrierColor: kTransparentColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
        ),
        builder: (BuildContext context) {
          return BlocBuilder<WatchBloc, WatchState>(
            builder: (context, state) {
              if (state.isCommentRepliesLoading ||
                  state.isCommentRepliesError) {
                return SizedBox(
                  height: _height * 0.48,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 5,
                        right: 0,
                        left: 0,
                        child: Center(
                          child: Container(
                            margin: const EdgeInsets.only(top: 15),
                            width: 40.0,
                            height: 4.0,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(2.0),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      const Center(
                        child: CupertinoActivityIndicator(),
                      ),
                    ],
                  ),
                );
              } else {
                return SizedBox(
                  height: _height * 0.48,
                  child: Column(
                    children: [
                      // Top indicator line
                      SizedBox(
                        height: 45,
                        child: Stack(
                          children: [
                            Positioned(
                              top: 5,
                              right: 0,
                              left: 0,
                              child: Center(
                                child: Container(
                                  margin: const EdgeInsets.only(top: 15),
                                  width: 40.0,
                                  height: 4.0,
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(2.0),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 12, left: 20, right: 20),
                        child: SizedBox(
                          height: _height * 0.38,
                          child: ListView.separated(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemBuilder: (context, index) {
                                final storeComment =
                                    state.commentReplies.comments[index];
                                return CommentWidget(
                                  author: storeComment.author ??
                                      locals.commentAuthorNotFound,
                                  text: storeComment.commentText ?? '',
                                  likes: storeComment.likeCount ?? 0,
                                  authorImageUrl: storeComment.thumbnail ?? '',
                                );
                              },
                              separatorBuilder: (context, index) =>
                                  kHeightBox15,
                              itemCount: state.commentReplies.comments.length),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          );
        });
  }
}
