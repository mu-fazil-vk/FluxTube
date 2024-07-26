//comments
import 'package:flutter/cupertino.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/core/operations/math_operations.dart';

import 'custom_rounded_buttons.dart';

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
    this.onTapYoutube
  });

  final int like;
  final int dislikes;
  final VoidCallback? onTapComment;
  final bool isCommentTapped;
  final VoidCallback? onTapShare;
  final bool isDislikeVisible;
  final VoidCallback? onTapSave;
  final bool isSaveTapped;
  final VoidCallback? onTapYoutube;

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
                thumbColor: kGreyColor!,
                fontColor: kGreyColor!,
                bgcolor: kGreyOpacityColor!,
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
            CustomRoundedSvgButtons(
                onTap: onTapYoutube, iconPath: 'assets/icons/youtube.svg'),
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
      this.fontColor = kWhiteColor,
      this.thumbColor = kWhiteColor,
      this.bgcolor = kBlueColor});
  final String like;
  final IconData icon;
  final Color bgcolor;
  final Color fontColor;
  final Color thumbColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 15),
      decoration: BoxDecoration(
          color: bgcolor, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(
            icon,
            color: thumbColor,
          ),
          kWidthBox10,
          Text(
            like,
            style: TextStyle(color: fontColor, fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}
