// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_stream.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AudioStream _$AudioStreamFromJson(Map<String, dynamic> json) => AudioStream(
      url: json['url'] as String?,
      format: json['format'] as String?,
      quality: json['quality'] as String?,
      mimeType: json['mimeType'] as String?,
      codec: json['codec'] as String?,
      audioTrackId: json['audioTrackId'],
      audioTrackName: json['audioTrackName'],
      audioTrackType: json['audioTrackType'],
      audioTrackLocale: json['audioTrackLocale'],
      videoOnly: json['videoOnly'] as bool?,
      itag: (json['itag'] as num?)?.toInt(),
      bitrate: (json['bitrate'] as num?)?.toInt(),
      initStart: (json['initStart'] as num?)?.toInt(),
      initEnd: (json['initEnd'] as num?)?.toInt(),
      indexStart: (json['indexStart'] as num?)?.toInt(),
      indexEnd: (json['indexEnd'] as num?)?.toInt(),
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      fps: (json['fps'] as num?)?.toInt(),
      contentLength: (json['contentLength'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AudioStreamToJson(AudioStream instance) =>
    <String, dynamic>{
      'url': instance.url,
      'format': instance.format,
      'quality': instance.quality,
      'mimeType': instance.mimeType,
      'codec': instance.codec,
      'audioTrackId': instance.audioTrackId,
      'audioTrackName': instance.audioTrackName,
      'audioTrackType': instance.audioTrackType,
      'audioTrackLocale': instance.audioTrackLocale,
      'videoOnly': instance.videoOnly,
      'itag': instance.itag,
      'bitrate': instance.bitrate,
      'initStart': instance.initStart,
      'initEnd': instance.initEnd,
      'indexStart': instance.indexStart,
      'indexEnd': instance.indexEnd,
      'width': instance.width,
      'height': instance.height,
      'fps': instance.fps,
      'contentLength': instance.contentLength,
    };
