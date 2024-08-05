import 'package:flutter/material.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerRelatedVideoWidget extends StatelessWidget {
  const ShimmerRelatedVideoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 275,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer(
            gradient: shimmerGradient,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              width: 275,
              height: 175,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Shimmer(
                    gradient: shimmerGradient,
                    child: Container(
                      color: Colors.white,
                      width: 230,
                      height: 15,
                    ),
                  ),
                ),
                kHeightBox10,
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Shimmer(
                    gradient: shimmerGradient,
                    child: Container(
                      color: Colors.white,
                      width: 200,
                      height: 15,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
