//comments
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/core/operations/math_operations.dart';

import 'custom_rounded_buttons.dart';
import 'html_text.dart';

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

class LikeRowWidget extends StatelessWidget {
  const LikeRowWidget({
    super.key,
    required this.like,
    this.dislikes = 0,
    this.onTapComment,
    this.isCommentTapped = false,
    this.onTapShare,
    this.isDislikeVisible = false,
    this.onTapSave,
    this.isSaveTapped = false,
  });

  final int like;
  final int dislikes;
  final VoidCallback? onTapComment;
  final bool isCommentTapped;
  final VoidCallback? onTapShare;
  final bool isDislikeVisible;
  final VoidCallback? onTapSave;
  final bool isSaveTapped;

  @override
  Widget build(BuildContext context) {
    String _formattedLikes = formatCount(like);
    String _formattedDislikes = formatCount(dislikes);
    return SizedBox(
      height: 50,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            RoundedLikeButtonWidget(
                icon: CupertinoIcons.hand_thumbsup_fill, like: _formattedLikes),
            if (isDislikeVisible) kWidthBox10,
            if (isDislikeVisible)
              RoundedLikeButtonWidget(
                icon: CupertinoIcons.hand_thumbsdown_fill,
                like: _formattedDislikes,
                color: kGreyOpacityColor!,
              ),
            kWidthBox20,
            CustomRoundedButtons(
              icon: CupertinoIcons.add,
              onTap: onTapSave,
              isTapped: isSaveTapped,
            ),
            kWidthBox10,
            CustomRoundedButtons(
                isTapped: isCommentTapped,
                onTap: onTapComment,
                icon: CupertinoIcons.bubble_left_bubble_right_fill),
            kWidthBox10,
            CustomRoundedButtons(
                onTap: onTapShare,
                icon: CupertinoIcons.arrowshape_turn_up_right_fill),
            kWidthBox10,
          ],
        ),
      ),
    );
  }
}

class RoundedLikeButtonWidget extends StatelessWidget {
  const RoundedLikeButtonWidget(
      {super.key,
      required this.like,
      required this.icon,
      this.color = kBlueColor});
  final String like;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 15),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(
            icon,
            color: kWhiteColor,
          ),
          kWidthBox10,
          Text(
            like,
            style: const TextStyle(
                color: kWhiteColor, fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}