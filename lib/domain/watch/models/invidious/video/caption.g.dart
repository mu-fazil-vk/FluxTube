// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'caption.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Caption _$CaptionFromJson(Map<String, dynamic> json) => Caption(
      label: json['label'] as String?,
      languageCode: json['language_code'] as String?,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$CaptionToJson(Caption instance) => <String, dynamic>{
      'label': instance.label,
      'language_code': instance.languageCode,
      'url': instance.url,
    };
