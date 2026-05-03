import 'package:flutter/foundation.dart';
import 'package:fluxtube/domain/watch/models/basic_info.dart';

class PlaybackQueueController extends ChangeNotifier {
  PlaybackQueueController._();

  static final PlaybackQueueController instance = PlaybackQueueController._();

  final List<VideoBasicInfo> _queue = [];

  List<VideoBasicInfo> get queue => List.unmodifiable(_queue);

  void setQueue({
    required String currentVideoId,
    required Iterable<VideoBasicInfo> videos,
  }) {
    final unique = <String, VideoBasicInfo>{};
    for (final video in videos) {
      if (video.id.isEmpty || video.id == currentVideoId) continue;
      unique.putIfAbsent(video.id, () => video);
    }
    _queue
      ..clear()
      ..addAll(unique.values);
    notifyListeners();
  }

  VideoBasicInfo? nextAfter(String? currentVideoId) {
    if (_queue.isEmpty) return null;
    if (currentVideoId == null) return _queue.first;

    final index = _queue.indexWhere((video) => video.id == currentVideoId);
    if (index == -1 || index == _queue.length - 1) {
      return _queue.first;
    }
    return _queue[index + 1];
  }

  void clear() {
    if (_queue.isEmpty) return;
    _queue.clear();
    notifyListeners();
  }
}
