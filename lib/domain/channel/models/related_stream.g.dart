// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'related_stream.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RelatedStream _$RelatedStreamFromJson(Map<String, dynamic> json) =>
    RelatedStream(
      url: json['url'] as String?,
      type: json['type'] as String?,
      title: json['title'] as String?,
      thumbnail: json['thumbnail'] as String?,
      uploaderName: json['uploaderName'] as String?,
      uploaderUrl: json['uploaderUrl'] as String?,
      uploaderAvatar: json['uploaderAvatar'],
      uploadedDate: json['uploadedDate'] as String?,
      shortDescription: json['shortDescription'] as String?,
      duration: (json['duration'] as num?)?.toInt(),
      views: (json['views'] as num?)?.toInt(),
      uploaded: (json['uploaded'] as num?)?.toInt(),
      uploaderVerified: json['uploaderVerified'] as bool?,
      isShort: json['isShort'] as bool?,
    );

Map<String, dynamic> _$RelatedStreamToJson(RelatedStream instance) =>
    <String, dynamic>{
      'url': instance.url,
      'type': instance.type,
      'title': instance.title,
      'thumbnail': instance.thumbnail,
      'uploaderName': instance.uploaderName,
      'uploaderUrl': instance.uploaderUrl,
      'uploaderAvatar': instance.uploaderAvatar,
      'uploadedDate': instance.uploadedDate,
      'shortDescription': instance.shortDescription,
      'duration': instance.duration,
      'views': instance.views,
      'uploaded': instance.uploaded,
      'uploaderVerified': instance.uploaderVerified,
      'isShort': instance.isShort,
    };
