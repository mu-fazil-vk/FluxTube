import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluxtube/core/operations/math_operations.dart';

import '../core/colors.dart';

class RelatedVideoWidget extends StatelessWidget {
  const RelatedVideoWidget(
      {super.key,
      required this.title,
      required this.thumbnailUrl,
      required this.duration,
      this.isDeleteIcon = false,
      this.onDeleteTap});

  final String title;
  final String? thumbnailUrl;
  final int? duration;
  final bool isDeleteIcon;
  final VoidCallback? onDeleteTap;

  @override
  Widget build(BuildContext context) {
    final String durationStr = formatDuration(duration);
    return SizedBox(
      width: 275,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              margin: const EdgeInsets.only(bottom: 10),
              width: 275,
              height: 175,
              decoration: BoxDecoration(
                color: kGreyColor,
                borderRadius: BorderRadius.circular(20),
                image: thumbnailUrl != null
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(thumbnailUrl!),
                        fit: BoxFit.cover)
                    : null,
              ),
              child: Stack(
                children: [
                  if (isDeleteIcon)
                    Align(
                        alignment: const Alignment(0.90, -0.90),
                        child: IconButton(
                            onPressed: onDeleteTap,
                            style: ButtonStyle(
                                backgroundColor:
                                    WidgetStatePropertyAll(kGreyOpacityColor)),
                            icon: const Icon(
                              CupertinoIcons.delete_solid,
                              color: kRedColor,
                            ))),
                  Align(
                      alignment: const Alignment(0.85, 0.85),
                      child: Container(
                          color:
                              durationStr == "Live" ? kRedColor : kBlackColor,
                          padding: const EdgeInsets.only(right: 5, left: 5),
                          child: Text(
                            durationStr,
                            style: const TextStyle(color: kWhiteColor),
                          ))),
                ],
              )),
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 10),
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15),
            ),
          )
        ],
      ),
    );
  }
}
