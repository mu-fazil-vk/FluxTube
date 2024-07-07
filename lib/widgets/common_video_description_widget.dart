import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluxtube/core/operations/math_operations.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:intl/intl.dart';

import '../core/colors.dart';
import '../core/constants.dart';

//caption widget
class CaptionRowWidget extends StatelessWidget {
  const CaptionRowWidget({
    super.key,
    this.icon,
    required this.caption,
    this.onTap,
  });

  final String caption;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            caption,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            overflow: TextOverflow.visible,
          ),
        ),
        if (icon != null)
          IconButton(
            icon: Icon(
              icon,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: onTap,
          ),
      ],
    );
  }
}

//view row widget
class ViewRowWidget extends StatelessWidget {
  const ViewRowWidget({
    super.key,
    this.views,
    this.uploadedDate,
  });

  final int? views;
  final String? uploadedDate;

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;

    var _formattedViews =
        views! > 1000 ? NumberFormat.compact().format(views ?? 0) : views;

    //format date
    String _formattedDate;
    try {
      //for date eg: 2024-05-22T08:51:33-07:00
      // Parse the date string to a DateTime object
      DateTime dateTime = DateTime.parse(uploadedDate ?? '0');

      // Define the desired format
      DateFormat dateFormat = DateFormat('yyyy-MM-dd  hh:mm a');

      // Format the DateTime object to a string
      _formattedDate = dateFormat.format(dateTime);
    } catch (_) {
      //for eg: 1 day ago
      _formattedDate = uploadedDate ?? '';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          '${_formattedViews == '0' ? '' : _formattedViews} ${S.of(context).videoViews(views ?? 0)}',
          style: TextStyle(
              color: kGreyColor, fontWeight: FontWeight.w600, fontSize: 12),
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(
          width: _size.width * 0.1,
        ),
        Text(
          _formattedDate,
          style: TextStyle(
              color: kGreyColor, fontWeight: FontWeight.w600, fontSize: 12),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

//subscribe row widget
class SubscribeRowWidget extends StatelessWidget {
  const SubscribeRowWidget({
    super.key,
    this.subscribed = false,
    this.subcount,
    required this.uploader,
    this.uploaderUrl,
    this.isVerified = false,
    this.onSubscribeTap,
  });

  final bool subscribed;
  final int? subcount;
  final String uploader;
  final String? uploaderUrl;
  final bool isVerified;
  final VoidCallback? onSubscribeTap;

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;

    var _formattedSubCount = formatCount(subcount ?? 0);

    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundImage: (uploaderUrl != null && uploaderUrl != "")
              ? NetworkImage(
                  uploaderUrl!,
                )
              : null,
        ),
        kWidthBox10,
        subcount == null
            ? Row(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        minWidth: 50, maxWidth: _size.width * 0.2),
                    child: Text(
                      uploader,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium!.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ),
                  kWidthBox5,
                  isVerified
                      ? const Padding(
                          padding: EdgeInsets.only(right: 5),
                          child: Icon(
                            Icons.verified,
                            color: kRedColor,
                            size: 20,
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                            minWidth: 50, maxWidth: _size.width * 0.2),
                        child: Text(
                          uploader,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyMedium!.color,
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                        ),
                      ),
                      kWidthBox5,
                      isVerified
                          ? const Icon(
                              Icons.verified,
                              color: kRedColor,
                              size: 20,
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        minWidth: 50, maxWidth: _size.width * 0.37),
                    child: Text(
                      '${_formattedSubCount == '0' ? '' : _formattedSubCount} ${S.of(context).channelSubscribers(subcount ?? 0)}',
                      style: TextStyle(
                          color: kGreyColor,
                          fontSize: 12,
                          overflow: TextOverflow.ellipsis),
                    ),
                  )
                ],
              ),
        const Spacer(),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 40,
          width: subscribed ? 65 : 130,
          child: ElevatedButton(
              style: ButtonStyle(
                  elevation: const WidgetStatePropertyAll(0),
                  backgroundColor: WidgetStatePropertyAll(
                      subscribed ? kGreyOpacityColor : kRedColor),
                  foregroundColor: WidgetStatePropertyAll(
                      subscribed ? kRedColor : kWhiteColor),
                  surfaceTintColor: WidgetStatePropertyAll(
                      subscribed ? kTransparentColor : kRedColor)),
              onPressed: onSubscribeTap,
              child: subscribed
                  ? const Icon(CupertinoIcons.check_mark_circled)
                  : FittedBox(
                      child: Text(
                        S.of(context).subscribe,
                        overflow: TextOverflow.clip,
                        style: const TextStyle(fontSize: 14),
                      ),
                    )),
        )
      ],
    );
  }
}
