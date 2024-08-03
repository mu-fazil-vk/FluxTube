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
            gradient: LinearGradient(colors: [
              Colors.grey.shade500,
              Colors.grey.shade600,
              Colors.grey,
              Colors.grey.shade700,
            ]),
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
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Shimmer(
                          gradient: LinearGradient(colors: [
                            Colors.grey.shade500,
                            Colors.grey.shade600,
                            Colors.grey,
                            Colors.grey.shade700,
                          ]),
                          child: Container(
                            color: Colors.white,
                            width: 180,
                            height: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                kHeightBox5,

                // * views row
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: Shimmer(
                        gradient: LinearGradient(colors: [
                          Colors.grey.shade500,
                          Colors.grey.shade600,
                          Colors.grey,
                          Colors.grey.shade700,
                        ]),
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
                        gradient: LinearGradient(colors: [
                          Colors.grey.shade500,
                          Colors.grey.shade600,
                          Colors.grey,
                          Colors.grey.shade700,
                        ]),
                        child: Container(
                          color: Colors.white,
                          width: 60,
                          height: 20,
                        ),
                      ),
                    ),
                  ],
                ),

                kHeightBox10,

                // * channel info row
                subscribeRowVisible
                    ? Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Shimmer(
                              gradient: LinearGradient(colors: [
                                Colors.grey.shade500,
                                Colors.grey.shade600,
                                Colors.grey,
                                Colors.grey.shade700,
                              ]),
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
                                constraints: const BoxConstraints(
                                    minWidth: 50, maxWidth: 150),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: Shimmer(
                                    gradient: LinearGradient(colors: [
                                      Colors.grey.shade500,
                                      Colors.grey.shade600,
                                      Colors.grey,
                                      Colors.grey.shade700,
                                    ]),
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
                              gradient: LinearGradient(colors: [
                                Colors.grey.shade500,
                                Colors.grey.shade600,
                                Colors.grey,
                                Colors.grey.shade700,
                              ]),
                              child: Container(
                                color: Colors.white,
                                width: 80,
                                height: 30,
                              ),
                            ),
                          )
                        ],
                      )
                    : const SizedBox(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
