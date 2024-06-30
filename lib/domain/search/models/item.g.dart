// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Item _$ItemFromJson(Map<String, dynamic> json) => Item(
      url: json['url'] as String?,
      type: json['type'] as String?,
      name: json['name'] as String?,
      thumbnail: json['thumbnail'] as String?,
      description: json['description'] as String?,
      subscribers: (json['subscribers'] as num?)?.toInt(),
      videos: (json['videos'] as num?)?.toInt(),
      verified: json['verified'] as bool?,
      title: json['title'] as String?,
      uploaderName: json['uploaderName'] as String?,
      uploaderUrl: json['uploaderUrl'] as String?,
      uploaderAvatar: json['uploaderAvatar'] as String?,
      uploadedDate: json['uploadedDate'] as String?,
      shortDescription: json['shortDescription'] as String?,
      duration: (json['duration'] as num?)?.toInt(),
      views: (json['views'] as num?)?.toInt(),
      uploaded: (json['uploaded'] as num?)?.toInt(),
      uploaderVerified: json['uploaderVerified'] as bool?,
      isShort: json['isShort'] as bool?,
    );

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
      'url': instance.url,
      'type': instance.type,
      'name': instance.name,
      'thumbnail': instance.thumbnail,
      'description': instance.description,
      'subscribers': instance.subscribers,
      'videos': instance.videos,
      'verified': instance.verified,
      'title': instance.title,
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
