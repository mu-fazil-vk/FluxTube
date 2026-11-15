import 'package:flutter_test/flutter_test.dart';
import 'package:fluxtube/domain/saved/models/local_store.dart';
import 'package:fluxtube/domain/sponsorblock/models/sponsor_segment.dart';
import 'package:fluxtube/presentation/home/widgets/continue_watching_row.dart';

LocalStoreVideoInfo _video(String id,
        {int? position, int? duration, bool live = false, DateTime? time}) =>
    LocalStoreVideoInfo(
      id: id,
      playbackPosition: position,
      duration: duration,
      isLive: live,
      isHistory: true,
      time: time,
    );

void main() {
  group('ContinueWatchingRow.inProgress', () {
    test('keeps only partially watched, non-live videos', () {
      final items = ContinueWatchingRow.inProgress([
        _video('started', position: 120, duration: 600),
        _video('barely', position: 5, duration: 600),
        _video('finished', position: 590, duration: 600),
        _video('live', position: 300, duration: 600, live: true),
        _video('tiny', position: 30, duration: 45),
        _video('unknown'),
      ]);
      expect(items.map((v) => v.id), ['started']);
    });

    test('orders most recently watched first and caps at 12', () {
      final now = DateTime(2026, 10, 2);
      final history = List.generate(
        20,
        (i) => _video('v$i',
            position: 100,
            duration: 1000,
            time: now.subtract(Duration(minutes: i))),
      );
      final items = ContinueWatchingRow.inProgress(history.reversed.toList());
      expect(items, hasLength(12));
      expect(items.first.id, 'v0');
      expect(items.last.id, 'v11');
    });
  });

  group('SponsorSegment', () {
    const segment = SponsorSegment(
        uuid: 'a', startTime: 10, endTime: 20, category: 'sponsor');

    test('contains positions in [start, end)', () {
      expect(segment.containsPosition(9.9), isFalse);
      expect(segment.containsPosition(10), isTrue);
      expect(segment.containsPosition(19.9), isTrue);
      expect(segment.containsPosition(20), isFalse);
    });

    test('parses the SponsorBlock API shape', () {
      final parsed = SponsorSegment.fromJson({
        'UUID': 'x',
        'segment': [0, 4.199],
        'category': 'intro',
        'actionType': 'skip',
      });
      expect(parsed.endTime, 4.199);
      expect(parsed.categoryDisplayName, 'Intro');
    });
  });
}
