import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluxtube/widgets/thumbnail_image.dart';
import 'package:fluxtube/core/animations/animations.dart';
import 'package:fluxtube/core/operations/math_operations.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:intl/intl.dart';

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
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            caption,
            style: theme.textTheme.titleMedium?.copyWith(height: 1.3),
            overflow: TextOverflow.visible,
          ),
        ),
        if (icon != null)
          IconButton(
            icon: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
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
    final locals = S.of(context);
    // Extractors report unknown counts as -1 and callers pass the "No date"
    // placeholder for missing dates; neither is worth showing.
    final viewCount = views ?? -1;
    final viewsText = viewCount < 0
        ? ''
        : '${viewCount >= 1000 ? NumberFormat.compact().format(viewCount) : viewCount} ${locals.videoViews(viewCount)}';

    String formattedDate;
    final rawDate = uploadedDate ?? '';
    if (rawDate.isEmpty || rawDate == locals.noUploadDate) {
      formattedDate = '';
    } else {
      try {
        formattedDate =
            DateFormat('yyyy-MM-dd  hh:mm a').format(DateTime.parse(rawDate));
      } catch (_) {
        formattedDate = rawDate;
      }
    }

    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (viewsText.isNotEmpty)
          Flexible(
            child: Text(
              viewsText,
              maxLines: 1,
              style: style,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        if (formattedDate.isNotEmpty) ...[
          if (viewsText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Text('•', style: style),
            ),
          Flexible(
            child: Text(
              formattedDate,
              maxLines: 1,
              style: style,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}

//subscribe row widget
class SubscribeRowWidget extends StatelessWidget {
  const SubscribeRowWidget({
    super.key,
    this.radius = 24,
    this.subTextStyle,
    this.subCountTextStyle,
    this.spacing,
    this.subscribed = false,
    this.subcount,
    required this.uploader,
    this.uploaderUrl,
    this.isVerified = false,
    this.onSubscribeTap,
  });

  //decoration
  final double radius;
  final TextStyle? subTextStyle;
  final TextStyle? subCountTextStyle;
  final Widget? spacing;

// values
  final bool subscribed;
  final String? subcount;
  final String? uploader;
  final String? uploaderUrl;
  final bool? isVerified;
  final VoidCallback? onSubscribeTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final formattedSubCount = formatCount(subcount ?? '0');

    return Row(
      children: [
        if (uploaderUrl != null && uploaderUrl != "")
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            padding: const EdgeInsets.all(1.5),
            child: CircleAvatar(
              radius: radius,
              backgroundImage: cachedAvatarProvider(
                uploaderUrl!,
                logicalDiameter: (radius * 2).toInt(),
              ),
            ),
          ),
        spacing ?? AppSpacing.width12,
        Expanded(
          child: subcount == null || subcount == '-1'
              ? Row(
                  children: [
                    Flexible(
                      child: Text(
                        uploader ?? '',
                        overflow: TextOverflow.ellipsis,
                        style: subTextStyle ??
                            theme.textTheme.titleSmall?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                      ),
                    ),
                    if (isVerified ?? false) ...[
                      AppSpacing.width4,
                      Icon(
                        Icons.verified,
                        color: colorScheme.primary,
                        size: 18,
                      ),
                    ],
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            uploader ?? '',
                            overflow: TextOverflow.ellipsis,
                            style: subTextStyle ??
                                theme.textTheme.titleSmall?.copyWith(
                                  color: colorScheme.onSurface,
                                ),
                          ),
                        ),
                        if (isVerified ?? false) ...[
                          AppSpacing.width4,
                          Icon(
                            Icons.verified,
                            color: colorScheme.primary,
                            size: 18,
                          ),
                        ],
                      ],
                    ),
                    Text(
                      '${formattedSubCount == '0' ? '' : formattedSubCount} ${S.of(context).channelSubscribers(int.tryParse(subcount!) ?? 2)}',
                      overflow: TextOverflow.ellipsis,
                      style: subCountTextStyle ??
                          theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    )
                  ],
                ),
        ),
        AppSpacing.width12,
        _SubscribeButton(
          subscribed: subscribed,
          onTap: onSubscribeTap,
        ),
      ],
    );
  }
}

/// A pill-shaped subscribe/subscribed toggle matching the app's Kinetic
/// design tokens instead of the old hardcoded-color flat [ElevatedButton].
class _SubscribeButton extends StatelessWidget {
  const _SubscribeButton({required this.subscribed, this.onTap});

  final bool subscribed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final locals = S.of(context);

    return ScaleTap(
      enableHaptic: false,
      onTap: onTap ?? () {},
      child: AnimatedContainer(
        duration: AppAnimations.medium,
        curve: AppAnimations.defaultCurve,
        height: 40,
        width: subscribed ? 44 : 118,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: subscribed
              ? colorScheme.surfaceContainerHigh
              : colorScheme.primary,
          borderRadius: AppRadius.borderFull,
        ),
        child: AnimatedSwitcher(
          duration: AppAnimations.fast,
          child: subscribed
              ? Icon(
                  CupertinoIcons.check_mark,
                  key: const ValueKey('subscribed'),
                  color: colorScheme.onSurfaceVariant,
                  size: 18,
                )
              : Text(
                  locals.subscribe,
                  key: const ValueKey('subscribe'),
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
        ),
      ),
    );
  }
}
