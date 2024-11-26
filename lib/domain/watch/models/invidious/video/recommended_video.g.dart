// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommended_video.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecommendedVideo _$RecommendedVideoFromJson(Map<String, dynamic> json) =>
    RecommendedVideo(
      videoId: json['videoId'] as String?,
      title: json['title'] as String?,
      videoThumbnails: (json['videoThumbnails'] as List<dynamic>?)
          ?.map((e) => VideoThumbnail.fromJson(e as Map<String, dynamic>))
          .toList(),
      author: json['author'] as String?,
      authorUrl: json['authorUrl'] as String?,
      authorId: json['authorId'] as String?,
      authorVerified: json['authorVerified'] as bool?,
      lengthSeconds: (json['lengthSeconds'] as num?)?.toInt(),
      viewCountText: json['viewCountText'] as String?,
      viewCount: (json['viewCount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$RecommendedVideoToJson(RecommendedVideo instance) =>
    <String, dynamic>{
      'videoId': instance.videoId,
      'title': instance.title,
      'videoThumbnails': instance.videoThumbnails,
      'author': instance.author,
      'authorUrl': instance.authorUrl,
      'authorId': instance.authorId,
      'authorVerified': instance.authorVerified,
      'lengthSeconds': instance.lengthSeconds,
      'viewCountText': instance.viewCountText,
      'viewCount': instance.viewCount,
    };
