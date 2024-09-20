import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/watch/watch_bloc.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/core/enums.dart';
import 'package:fluxtube/core/operations/math_operations.dart';
import 'package:fluxtube/domain/watch/models/invidious/comments/comment.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/presentation/watch/widgets/shimmer_comment_widgets.dart';
import 'package:fluxtube/widgets/indicator.dart';
import 'package:go_router/go_router.dart';
import 'package:rich_readmore/rich_readmore.dart';
import 'package:simple_html_css/simple_html_css.dart';

class InvidiousCommentSection extends StatelessWidget {
  InvidiousCommentSection(
      {super.key,
      required this.state,
      required this.height,
      required this.locals,
      required this.videoId});
  final WatchState state;
  final double height;
  final S locals;
  final String videoId;

  final _scrollController = ScrollController();
  final _scrollControllerReply = ScrollController();

  @override
  Widget build(BuildContext context) {
    // for comments
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !(state.fetchMoreInvidiousCommentRepliesStatus ==
              ApiStatus.loading) &&
          !state.isMoreInvidiousCommetsFetchCompleted) {
        BlocProvider.of<WatchBloc>(context).add(
            WatchEvent.getMoreInvidiousComments(
                id: videoId,
                continuation: state.invidiousComments.continuation));
      }
    });

    // for comment replies
    _scrollControllerReply.addListener(() {
      if (_scrollControllerReply.position.pixels ==
              _scrollControllerReply.position.maxScrollExtent &&
          !(state.fetchMoreInvidiousCommentRepliesStatus ==
              ApiStatus.loading) &&
          !state.isMoreInvidiousReplyCommetsFetchCompleted) {
        BlocProvider.of<WatchBloc>(context).add(
            WatchEvent.getMoreInvidiousReplyComments(
                id: videoId,
                continuation: state.invidiousCommentReplies.continuation));
      }
    });

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: LimitedBox(
        maxHeight: height * 0.45,
        child: (state.fetchInvidiousCommentsStatus == ApiStatus.initial ||
                state.fetchInvidiousCommentsStatus == ApiStatus.loading)
            ? const ShimmerCommentWidget()
            : state.fetchInvidiousCommentsStatus == ApiStatus.error
                ? Center(
                    child: ElevatedButton(
                        onPressed: () {
                          BlocProvider.of<WatchBloc>(context)
                              .add(WatchEvent.getInvidiousComments(
                            id: videoId,
                          ));
                        },
                        child: Text(locals.retry)),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    controller: _scrollController,
                    itemBuilder: (context, index) {
                      if (index <
                          (state.invidiousComments.comments?.length ?? 0)) {
                        final storeComment =
                            state.invidiousComments.comments![index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            CommentWidget(
                              author: storeComment.author ??
                                  locals.commentAuthorNotFound,
                              text: storeComment.content ?? '',
                              likes: storeComment.likeCount ?? 0,
                              authorImageUrl:
                                  storeComment.authorThumbnails!.first.url ??
                                      '',
                              onProfileTap: () =>
                                  context.goNamed('channel', pathParameters: {
                                'channelId': storeComment.authorId!,
                              }, queryParameters: {
                                'avtarUrl':
                                    storeComment.authorThumbnails!.first.url,
                              }),
                            ),
                            if (storeComment.replies != null &&
                                storeComment.replies!.replyCount != 0)
                              Padding(
                                padding: const EdgeInsets.only(right: 70),
                                child: TextButton(
                                    onPressed: () {
                                      BlocProvider.of<WatchBloc>(context).add(
                                          WatchEvent.getInvidiousCommentReplies(
                                              id: storeComment.commentId!,
                                              continuation: storeComment
                                                  .replies!.continuation!));

                                      commentReplyBottomSheet(
                                          context,
                                          storeComment,
                                          height,
                                          locals,
                                          storeComment.replies?.replyCount ??
                                              0);
                                    },
                                    child: Text(
                                        "${formatCount(storeComment.replies!.replyCount.toString())} ${locals.repliesPlural(storeComment.replies?.replyCount ?? 0)}")),
                              )
                          ],
                        );
                      } else {
                        if (state.isMoreInvidiousCommetsFetchCompleted) {
                          return const SizedBox();
                        } else {
                          return cIndicator(context);
                        }
                      }
                    },
                    separatorBuilder: (context, index) => kHeightBox15,
                    itemCount: state.comments.comments.length + 1),
      ),
    );
  }

  Future<void> commentReplyBottomSheet(BuildContext context,
      Comment selectedComment, double _height, S locals, int commentCount) {
    return showModalBottomSheet<void>(
        showDragHandle: true,
        context: context,
        barrierColor: kTransparentColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
        ),
        builder: (BuildContext context) {
          return BlocBuilder<WatchBloc, WatchState>(
            builder: (context, state) {
              if (state.fetchInvidiousCommentRepliesStatus ==
                      ApiStatus.initial ||
                  state.fetchInvidiousCommentRepliesStatus ==
                      ApiStatus.loading) {
                return const ShimmerCommentWidget();
              } else if (state.fetchInvidiousCommentRepliesStatus ==
                  ApiStatus.error) {
                return Center(
                  child: ElevatedButton(
                      onPressed: () {
                        BlocProvider.of<WatchBloc>(context).add(
                            WatchEvent.getInvidiousCommentReplies(
                                id: videoId,
                                continuation:
                                    selectedComment.replies!.continuation!));
                      },
                      child: Text(locals.retry)),
                );
              } else {
                return SizedBox(
                  height: _height * 0.48,
                  child: Column(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 12, left: 20, right: 20),
                        child: SizedBox(
                          height: _height * 0.38,
                          child: ListView.separated(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              controller: _scrollControllerReply,
                              itemBuilder: (context, index) {
                                if (index <
                                    (state.invidiousCommentReplies.comments
                                            ?.length ??
                                        0)) {
                                  final storeComment = state
                                      .invidiousCommentReplies.comments![index];
                                  return CommentWidget(
                                    author: storeComment.author ??
                                        locals.commentAuthorNotFound,
                                    text: storeComment.content ?? '',
                                    likes: storeComment.likeCount ?? 0,
                                    authorImageUrl: storeComment
                                            .authorThumbnails!.first.url ??
                                        '',
                                    onProfileTap: () => context
                                        .goNamed('channel', pathParameters: {
                                      'channelId': storeComment.authorId!,
                                    }, queryParameters: {
                                      'avtarUrl': storeComment
                                          .authorThumbnails!.first.url,
                                    }),
                                  );
                                } else {
                                  if (state
                                          .isMoreInvidiousReplyCommetsFetchCompleted ||
                                      (index == commentCount)) {
                                    return const SizedBox();
                                  } else {
                                    return cIndicator(context);
                                  }
                                }
                              },
                              separatorBuilder: (context, index) =>
                                  kHeightBox15,
                              itemCount: (state.invidiousCommentReplies.comments
                                          ?.length ??
                                      0) +
                                  1),
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

//each comment widget

class CommentWidget extends StatelessWidget {
  const CommentWidget({
    super.key,
    required this.author,
    required this.text,
    required this.likes,
    required this.authorImageUrl,
    this.onProfileTap,
  });

  final String authorImageUrl;
  final String author;
  final String text;
  final int likes;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    final S locals = S.of(context);
    final Size _size = MediaQuery.of(context).size;
    var _formattedLikes = formatCount(likes.toString());
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GestureDetector(
        onTap: onProfileTap,
        child: CircleAvatar(
          radius: 20,
          backgroundImage: (authorImageUrl != "")
              ? NetworkImage(
                  authorImageUrl,
                )
              : null,
        ),
      ),
      kWidthBox20,
      SizedBox(
        width: _size.width * 0.6,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              author,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: kGreyColor, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            RichReadMoreText(
              HTML.toTextSpan(context, text,
                  defaultTextStyle: Theme.of(context).textTheme.bodyMedium),
              settings: LineModeSettings(
                trimLines: 3,
                trimCollapsedText: ' ${locals.readMoreText}',
                trimExpandedText: ' ${locals.showLessText}',
                moreStyle:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                lessStyle:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      const Spacer(),
      Column(
        children: [
          const Icon(CupertinoIcons.hand_thumbsup_fill),
          Text(_formattedLikes)
        ],
      )
    ]);
  }
}
