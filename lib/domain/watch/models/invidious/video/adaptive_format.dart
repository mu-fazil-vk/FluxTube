import 'package:json_annotation/json_annotation.dart';

import 'color_info.dart';

part 'adaptive_format.g.dart';

@JsonSerializable()
class AdaptiveFormat {
  String? init;
  String? index;
  String? bitrate;
  String? url;
  String? itag;
  String? type;
  String? clen;
  String? lmt;
  String? projectionType;
  String? container;
  String? encoding;
  String? audioQuality;
  int? audioSampleRate;
  int? audioChannels;
  int? fps;
  String? size;
  String? resolution;
  String? qualityLabel;
  ColorInfo? colorInfo;

  AdaptiveFormat({
    this.init,
    this.index,
    this.bitrate,
    this.url,
    this.itag,
    this.type,
    this.clen,
    this.lmt,
    this.projectionType,
    this.container,
    this.encoding,
    this.audioQuality,
    this.audioSampleRate,
    this.audioChannels,
    this.fps,
    this.size,
    this.resolution,
    this.qualityLabel,
    this.colorInfo,
  });

  factory AdaptiveFormat.fromJson(Map<String, dynamic> json) {
    return _$AdaptiveFormatFromJson(json);
  }

  Map<String, dynamic> toJson() => _$AdaptiveFormatToJson(this);
}
