import 'package:json_annotation/json_annotation.dart';

import 'audio_stream.dart';
import 'preview_frame.dart';
import 'related_stream.dart';
import 'subtitle.dart';
import 'video_stream.dart';

part 'watch_resp.g.dart';

@JsonSerializable()
class WatchResp {
  String? title;
  String? description;
  String? uploadDate;
  String? uploader;
  String? uploaderUrl;
  String? uploaderAvatar;
  String? thumbnailUrl;
  String? hls;
  dynamic dash;
  dynamic lbryId;
  String? category;
  String? license;
  String? visibility;
  List<String>? tags;
  List<dynamic>? metaInfo;
  bool? uploaderVerified;
  int? duration;
  int? views;
  int? likes;
  int? dislikes;
  int? uploaderSubscriberCount;
  List<AudioStream>? audioStreams;
  List<VideoStream> videoStreams;
  List<RelatedStream>? relatedStreams;
  List<Subtitle>? subtitles;
  bool? livestream;
  String? proxyUrl;
  List<dynamic>? chapters;
  List<PreviewFrame>? previewFrames;

  WatchResp({
    this.title = 'fetching...',
    this.description = 'fetching...',
    this.uploadDate = "0",
    this.uploader = 'fetching...',
    this.uploaderUrl = 'fetching...',
    this.uploaderAvatar,
    this.thumbnailUrl,
    this.hls = 'fetching...',
    this.dash,
    this.lbryId,
    this.category,
    this.license,
    this.visibility,
    this.tags,
    this.metaInfo,
    this.uploaderVerified = false,
    this.duration = 0,
    this.views = 0,
    this.likes = 0,
    this.dislikes = 0,
    this.uploaderSubscriberCount = 0,
    this.audioStreams,
    this.videoStreams = const [],
    this.relatedStreams,
    this.subtitles,
    this.livestream,
    this.proxyUrl,
    this.chapters,
    this.previewFrames,
  });

  factory WatchResp.fromJson(Map<String, dynamic> json) {
    return _$WatchRespFromJson(json);
  }

  Map<String, dynamic> toJson() => _$WatchRespToJson(this);
}
