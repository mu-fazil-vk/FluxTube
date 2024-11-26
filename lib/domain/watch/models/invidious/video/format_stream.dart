import 'package:json_annotation/json_annotation.dart';

part 'format_stream.g.dart';

@JsonSerializable()
class FormatStream {
  String? url;
  String? itag;
  String? type;
  String? quality;
  String? bitrate;
  int? fps;
  String? size;
  String? resolution;
  String? qualityLabel;
  String? container;
  String? encoding;

  FormatStream({
    this.url,
    this.itag,
    this.type,
    this.quality,
    this.bitrate,
    this.fps,
    this.size,
    this.resolution,
    this.qualityLabel,
    this.container,
    this.encoding,
  });

  factory FormatStream.fromJson(Map<String, dynamic> json) {
    return _$FormatStreamFromJson(json);
  }

  Map<String, dynamic> toJson() => _$FormatStreamToJson(this);
}
