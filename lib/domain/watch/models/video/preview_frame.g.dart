// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preview_frame.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PreviewFrame _$PreviewFrameFromJson(Map<String, dynamic> json) => PreviewFrame(
      urls: (json['urls'] as List<dynamic>?)?.map((e) => e as String).toList(),
      frameWidth: (json['frameWidth'] as num?)?.toInt(),
      frameHeight: (json['frameHeight'] as num?)?.toInt(),
      totalCount: (json['totalCount'] as num?)?.toInt(),
      durationPerFrame: (json['durationPerFrame'] as num?)?.toInt(),
      framesPerPageX: (json['framesPerPageX'] as num?)?.toInt(),
      framesPerPageY: (json['framesPerPageY'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PreviewFrameToJson(PreviewFrame instance) =>
    <String, dynamic>{
      'urls': instance.urls,
      'frameWidth': instance.frameWidth,
      'frameHeight': instance.frameHeight,
      'totalCount': instance.totalCount,
      'durationPerFrame': instance.durationPerFrame,
      'framesPerPageX': instance.framesPerPageX,
      'framesPerPageY': instance.framesPerPageY,
    };
