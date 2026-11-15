import 'package:flutter/material.dart';
import 'package:fluxtube/domain/sponsorblock/models/sponsor_segment.dart';

/// Official SponsorBlock category colors.
Color sponsorCategoryColor(String category) {
  switch (category) {
    case 'sponsor':
      return const Color(0xFF00D400);
    case 'selfpromo':
      return const Color(0xFFFFFF00);
    case 'interaction':
      return const Color(0xFFCC00FF);
    case 'intro':
      return const Color(0xFF00FFFF);
    case 'outro':
      return const Color(0xFF0202ED);
    case 'preview':
      return const Color(0xFF008FD6);
    case 'music_offtopic':
      return const Color(0xFFFF9900);
    case 'filler':
      return const Color(0xFF7300FF);
    default:
      return const Color(0xFF00D400);
  }
}

/// Paints SponsorBlock segments over a [Slider]'s track. Stack it on top of
/// the slider with the same size; [trackInset] must match the slider's
/// overlay radius, which is where the default track shape starts and ends.
class SponsorSegmentMarkers extends StatelessWidget {
  const SponsorSegmentMarkers({
    super.key,
    required this.segments,
    required this.durationMs,
    this.trackInset = 14,
    this.trackHeight = 3,
  });

  final List<SponsorSegment> segments;
  final int durationMs;
  final double trackInset;
  final double trackHeight;

  @override
  Widget build(BuildContext context) {
    if (segments.isEmpty || durationMs <= 0) return const SizedBox.shrink();
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter:
              _SegmentPainter(segments, durationMs, trackInset, trackHeight),
        ),
      ),
    );
  }
}

class _SegmentPainter extends CustomPainter {
  _SegmentPainter(this.segments, this.durationMs, this.inset, this.height);

  final List<SponsorSegment> segments;
  final int durationMs;
  final double inset;
  final double height;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width - inset * 2;
    if (width <= 0) return;
    final top = (size.height - height) / 2;
    final durationSec = durationMs / 1000;
    final paint = Paint();
    for (final s in segments) {
      final start = (s.startTime / durationSec).clamp(0.0, 1.0);
      final end = (s.endTime / durationSec).clamp(0.0, 1.0);
      if (end <= start) continue;
      paint.color = sponsorCategoryColor(s.category);
      canvas.drawRect(
        Rect.fromLTWH(inset + start * width, top,
            ((end - start) * width).clamp(2.0, width), height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SegmentPainter old) =>
      old.segments != segments || old.durationMs != durationMs;
}
