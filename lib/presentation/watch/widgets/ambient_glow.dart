import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fluxtube/widgets/thumbnail_image.dart';

/// "Ambient mode": a soft, blurred wash of the video's thumbnail bleeding out
/// behind the player. Static, small-decode and isolated in a repaint
/// boundary, so it costs one blur at load time and nothing per frame.
class AmbientGlow extends StatelessWidget {
  const AmbientGlow({super.key, required this.thumbnailUrl, required this.height});

  final String? thumbnailUrl;
  final double height;

  @override
  Widget build(BuildContext context) {
    final url = thumbnailUrl;
    if (url == null || url.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final background = theme.scaffoldBackgroundColor;

    return IgnorePointer(
      child: RepaintBoundary(
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Opacity(
                opacity: isDark ? 0.55 : 0.3,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(
                      sigmaX: 48, sigmaY: 48, tileMode: TileMode.decal),
                  child: Transform.scale(
                    scale: 1.25,
                    child: ThumbnailImage(
                      url: url,
                      memCacheWidth: 96,
                      placeholder: (_, __) => const SizedBox.shrink(),
                      errorWidget: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [background.withValues(alpha: 0), background],
                    stops: const [0.45, 1],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
