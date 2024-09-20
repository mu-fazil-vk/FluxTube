import 'package:json_annotation/json_annotation.dart';

part 'audio_stream.g.dart';

@JsonSerializable()
class AudioStream {
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

  AudioStream({
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

  factory AudioStream.fromJson(Map<String, dynamic> json) {
    return _$AudioStreamFromJson(json);
  }

  Map<String, dynamic> toJson() => _$AudioStreamToJson(this);
}
