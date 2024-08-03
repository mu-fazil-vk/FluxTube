import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerCommentWidget extends StatelessWidget {
  const ShimmerCommentWidget({super.key, this.showReply = true});
  final bool showReply;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        itemBuilder: (context, index) => Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Shimmer(
                    gradient: shimmerGradient,
                    child: Container(
                      color: Colors.white,
                      width: 50,
                      height: 50,
                    ),
                  ),
                ),
                kWidthBox10,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Shimmer(
                        gradient: shimmerGradient,
                        child: Container(
                          color: Colors.white,
                          width: 190,
                          height: 20,
                        ),
                      ),
                    ),
                    kHeightBox5,
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Shimmer(
                        gradient: shimmerGradient,
                        child: Container(
                          color: Colors.white,
                          width: 160,
                          height: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Shimmer(
                      gradient: shimmerGradient,
                      child: const Icon(CupertinoIcons.hand_thumbsup_fill)),
                ),
              ],
            ),
        separatorBuilder: (context, index) => kHeightBox20,
        itemCount: 10);
  }
}
