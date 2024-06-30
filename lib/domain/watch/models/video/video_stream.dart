import 'package:json_annotation/json_annotation.dart';

part 'video_stream.g.dart';

@JsonSerializable()
class VideoStream {
  String? url;
  String? format;
  String? quality;
  String? mimeType;
  String? codec;
  dynamic audioTrackId;
  dynamic audioTrackName;
  dynamic audioTrackType;
  dynamic audioTrackLocale;
  bool? videoOnly;
  int? itag;
  int? bitrate;
  int? initStart;
  int? initEnd;
  int? indexStart;
  int? indexEnd;
  int? width;
  int? height;
  int? fps;
  int? contentLength;

  VideoStream({
    this.url,
    this.format,
    this.quality,
    this.mimeType,
    this.codec,
    this.audioTrackId,
    this.audioTrackName,
    this.audioTrackType,
    this.audioTrackLocale,
    this.videoOnly,
    this.itag,
    this.bitrate,
    this.initStart,
    this.initEnd,
    this.indexStart,
    this.indexEnd,
    this.width,
    this.height,
    this.fps,
    this.contentLength,
  });

  factory VideoStream.fromJson(Map<String, dynamic> json) {
    return _$VideoStreamFromJson(json);
  }

  Map<String, dynamic> toJson() => _$VideoStreamToJson(this);
}
