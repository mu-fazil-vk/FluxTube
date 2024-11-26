import 'package:flutter/material.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerHomeVideoInfoCard extends StatelessWidget {
  const ShimmerHomeVideoInfoCard({super.key, this.subscribeRowVisible = true});

  final bool subscribeRowVisible;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 20, right: 20, bottom: 10),
      child: Column(
        children: [
          Shimmer(
            gradient: shimmerGradient,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              width: double.infinity,
              height: 230,
              decoration: BoxDecoration(
                color: kGreyColor,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12, left: 12),
            child: Column(
              children: [
                // * caption row
                const ShimmerCaptionWidget(),

                kHeightBox5,

                // * views row
                const ShimmerViewWidget(),

                kHeightBox10,

                // * channel info row
                subscribeRowVisible
                    ? const ShimmerSubscribeWidget()
                    : const SizedBox(),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ShimmerSubscribeWidget extends StatelessWidget {
  const ShimmerSubscribeWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
        Row(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 50, maxWidth: 150),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Shimmer(
                  gradient: shimmerGradient,
                  child: Container(
                    color: Colors.white,
                    width: 180,
                    height: 20,
                  ),
                ),
              ),
            ),
            kWidthBox5,
          ],
        ),
        const Spacer(),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Shimmer(
            gradient: shimmerGradient,
            child: Container(
              color: Colors.white,
              width: 80,
              height: 30,
            ),
          ),
        )
      ],
    );
  }
}

class ShimmerViewWidget extends StatelessWidget {
  const ShimmerViewWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Shimmer(
            gradient: shimmerGradient,
            child: Container(
              color: Colors.white,
              width: 60,
              height: 20,
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Shimmer(
            gradient: shimmerGradient,
            child: Container(
              color: Colors.white,
              width: 60,
              height: 20,
            ),
          ),
        ),
      ],
    );
  }
}

class ShimmerCaptionWidget extends StatelessWidget {
  const ShimmerCaptionWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Shimmer(
              gradient: shimmerGradient,
              child: Container(
                color: Colors.white,
                width: 180,
                height: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ShimmerLikeWidget extends StatelessWidget {
  const ShimmerLikeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Shimmer(
              gradient: shimmerGradient,
              child: Container(
                color: Colors.white,
                width: 80,
                height: 30,
              ),
            ),
          ),
          kWidthBox20,
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Shimmer(
              gradient: shimmerGradient,
              child: Container(
                color: Colors.white,
                width: 80,
                height: 30,
              ),
            ),
          ),
          kWidthBox10,
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Shimmer(
              gradient: shimmerGradient,
              child: Container(
                color: Colors.white,
                width: 80,
                height: 30,
              ),
            ),
          ),
          kWidthBox10,
        ],
      ),
    );
  }
}
