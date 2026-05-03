import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:fluxtube/core/constants.dart';

// Physical-pixel cache widths tuned to typical display sizes.
// Full-width cards (~360dp @ 3× DPR = 1080px): 720px is enough for ≤2× and
// is still reasonable for 3×, cutting memory ~3× vs the raw 1280px JPEG.
const int _kCacheWidthCard = 720;
// Related-video thumbnails (~120dp × 3× = 360px): 320px covers it.
const int _kCacheWidthSmall = 320;

/// Drop-in replacement for CachedNetworkImage that caps the in-memory decode
/// size so we don't store full 1280×720 bitmaps for 100×56 thumbnails.
///
/// Use [ThumbnailImage.small] for related-video / search-result sidebars.
class ThumbnailImage extends StatelessWidget {
  const ThumbnailImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.memCacheWidth = _kCacheWidthCard,
    this.memCacheHeight,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
  });

  /// For related-video / search sidebars, small cards, and avatars.
  const ThumbnailImage.small({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
  })  : memCacheWidth = _kCacheWidthSmall,
        memCacheHeight = null;

  final String url;
  final BoxFit fit;
  final int memCacheWidth;
  final int? memCacheHeight;
  final double? width;
  final double? height;
  final Widget Function(BuildContext, String)? placeholder;
  final Widget Function(BuildContext, String, Object)? errorWidget;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant;

    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      width: width,
      height: height,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      placeholder: placeholder ?? (context, _) => ColoredBox(color: bg),
      errorWidget: errorWidget ??
          (context, _, __) => ColoredBox(
                color: bg,
                child: const Icon(
                  CupertinoIcons.play_rectangle,
                  size: AppIconSize.xxl,
                  color: AppColors.disabled,
                ),
              ),
    );
  }
}

/// Returns a memory-capped [CachedNetworkImageProvider] for use inside
/// [DecorationImage] or [CircleAvatar.backgroundImage].
///
/// [logicalDiameter] is the widget's side length in logical pixels (dp);
/// the provider caches at 3× that to cover high-DPR screens.
CachedNetworkImageProvider cachedAvatarProvider(
  String url, {
  int logicalDiameter = 40,
}) {
  final px = (logicalDiameter * 3).clamp(48, 240);
  return CachedNetworkImageProvider(url, maxWidth: px, maxHeight: px);
}

/// Memory-capped provider for thumbnail images used in [DecorationImage].
CachedNetworkImageProvider cachedThumbnailProvider(
  String url, {
  bool small = false,
}) {
  final w = small ? _kCacheWidthSmall : _kCacheWidthCard;
  return CachedNetworkImageProvider(url, maxWidth: w);
}
