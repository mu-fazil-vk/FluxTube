// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adaptive_format.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdaptiveFormat _$AdaptiveFormatFromJson(Map<String, dynamic> json) =>
    AdaptiveFormat(
      init: json['init'] as String?,
      index: json['index'] as String?,
      bitrate: json['bitrate'] as String?,
      url: json['url'] as String?,
      itag: json['itag'] as String?,
      type: json['type'] as String?,
      clen: json['clen'] as String?,
      lmt: json['lmt'] as String?,
      projectionType: json['projectionType'] as String?,
      container: json['container'] as String?,
      encoding: json['encoding'] as String?,
      audioQuality: json['audioQuality'] as String?,
      audioSampleRate: (json['audioSampleRate'] as num?)?.toInt(),
      audioChannels: (json['audioChannels'] as num?)?.toInt(),
      fps: (json['fps'] as num?)?.toInt(),
      size: json['size'] as String?,
      resolution: json['resolution'] as String?,
      qualityLabel: json['qualityLabel'] as String?,
      colorInfo: json['colorInfo'] == null
          ? null
          : ColorInfo.fromJson(json['colorInfo'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AdaptiveFormatToJson(AdaptiveFormat instance) =>
    <String, dynamic>{
      'init': instance.init,
      'index': instance.index,
      'bitrate': instance.bitrate,
      'url': instance.url,
      'itag': instance.itag,
      'type': instance.type,
      'clen': instance.clen,
      'lmt': instance.lmt,
      'projectionType': instance.projectionType,
      'container': instance.container,
      'encoding': instance.encoding,
      'audioQuality': instance.audioQuality,
      'audioSampleRate': instance.audioSampleRate,
      'audioChannels': instance.audioChannels,
      'fps': instance.fps,
      'size': instance.size,
      'resolution': instance.resolution,
      'qualityLabel': instance.qualityLabel,
      'colorInfo': instance.colorInfo,
    };
