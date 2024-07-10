import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/watch/watch_bloc.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/core/operations/math_operations.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/presentation/watch/widgets/html_text.dart';
import 'package:fluxtube/widgets/indicator.dart';

class CommentSection extends StatelessWidget {
  CommentSection(
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
          !state.isMoreCommetsFetchLoading &&
          !state.isMoreCommetsFetchCompleted) {
        BlocProvider.of<WatchBloc>(context).add(WatchEvent.getMoreCommentsData(
            id: videoId, nextPage: state.comments.nextpage));
      }
    });

    // for comment replies
    _scrollControllerReply.addListener(() {
      if (_scrollControllerReply.position.pixels ==
              _scrollControllerReply.position.maxScrollExtent &&
          !state.isMoreReplyCommetsFetchLoading &&
          !state.isMoreReplyCommetsFetchCompleted) {
        BlocProvider.of<WatchBloc>(context).add(
            WatchEvent.getMoreReplyCommentsData(
                id: videoId, nextPage: state.commentReplies.nextpage));
      }
    });

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: (state.isCommentsLoading || state.isCommentError)
          ? cIndicator(context)
          : LimitedBox(
              maxHeight: height * 0.45,
              child: ListView.separated(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  controller: _scrollController,
                  itemBuilder: (context, index) {
                    if (index < state.comments.comments.length) {
                      final storeComment = state.comments.comments[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          CommentWidget(
                            author: storeComment.author ??
                                locals.commentAuthorNotFound,
                            text: storeComment.commentText ?? '',
                            likes: storeComment.likeCount ?? 0,
                            authorImageUrl: storeComment.thumbnail ?? '',
                          ),
                          if (storeComment.replyCount != null &&
                              storeComment.replyCount != 0)
                            Padding(
                              padding: const EdgeInsets.only(right: 70),
                              child: TextButton(
                                  onPressed: () {
                                    BlocProvider.of<WatchBloc>(context).add(
                                        WatchEvent.getCommentRepliesData(
                                            id: storeComment.commentId!,
                                            nextPage:
                                                storeComment.repliesPage!));

                                    commentReplyBottomSheet(context, height,
                                        locals, storeComment.replyCount ?? 0);
                                  },
                                  child: Text(
                                      "${formatCount(storeComment.replyCount!)} ${locals.repliesPlural(storeComment.replyCount!)}")),
                            )
                        ],
                      );
                    } else {
                      if (state.isMoreCommetsFetchCompleted) {
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

  Future<void> commentReplyBottomSheet(
      BuildContext context, double _height, S locals, int commentCount) {
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
                      cIndicator(context)
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
                              controller: _scrollControllerReply,
                              itemBuilder: (context, index) {
                                if (index <
                                    state.commentReplies.comments.length) {
                                  final storeComment =
                                      state.commentReplies.comments[index];
                                  return CommentWidget(
                                    author: storeComment.author ??
                                        locals.commentAuthorNotFound,
                                    text: storeComment.commentText ?? '',
                                    likes: storeComment.likeCount ?? 0,
                                    authorImageUrl:
                                        storeComment.thumbnail ?? '',
                                  );
                                } else {
                                  if (state.isMoreReplyCommetsFetchCompleted ||
                                      (index == commentCount)) {
                                    return const SizedBox();
                                  } else {
                                    return cIndicator(context);
                                  }
                                }
                              },
                              separatorBuilder: (context, index) =>
                                  kHeightBox15,
                              itemCount:
                                  state.commentReplies.comments.length + 1),
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
  });

  final String authorImageUrl;
  final String author;
  final String text;
  final int likes;

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    var _formattedLikes = formatCount(likes);
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CircleAvatar(
        radius: 20,
        backgroundImage: (authorImageUrl != "")
            ? NetworkImage(
                authorImageUrl,
              )
            : null,
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
            HTMLText(text: text),
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
