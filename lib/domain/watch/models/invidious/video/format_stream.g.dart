// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'format_stream.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FormatStream _$FormatStreamFromJson(Map<String, dynamic> json) => FormatStream(
      url: json['url'] as String?,
      itag: json['itag'] as String?,
      type: json['type'] as String?,
      quality: json['quality'] as String?,
      bitrate: json['bitrate'] as String?,
      fps: (json['fps'] as num?)?.toInt(),
      size: json['size'] as String?,
      resolution: json['resolution'] as String?,
      qualityLabel: json['qualityLabel'] as String?,
      container: json['container'] as String?,
      encoding: json['encoding'] as String?,
    );

Map<String, dynamic> _$FormatStreamToJson(FormatStream instance) =>
    <String, dynamic>{
      'url': instance.url,
      'itag': instance.itag,
      'type': instance.type,
      'quality': instance.quality,
      'bitrate': instance.bitrate,
      'fps': instance.fps,
      'size': instance.size,
      'resolution': instance.resolution,
      'qualityLabel': instance.qualityLabel,
      'container': instance.container,
      'encoding': instance.encoding,
    };
