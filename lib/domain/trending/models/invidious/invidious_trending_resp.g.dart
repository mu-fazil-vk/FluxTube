// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invidious_trending_resp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvidiousTrendingResp _$InvidiousTrendingRespFromJson(
        Map<String, dynamic> json) =>
    InvidiousTrendingResp(
      type: json['type'] as String?,
      title: json['title'] as String?,
      videoId: json['videoId'] as String?,
      author: json['author'] as String?,
      authorId: json['authorId'] as String?,
      authorUrl: json['authorUrl'] as String?,
      authorVerified: json['authorVerified'] as bool?,
      videoThumbnails: (json['videoThumbnails'] as List<dynamic>?)
          ?.map((e) => VideoThumbnail.fromJson(e as Map<String, dynamic>))
          .toList(),
      description: json['description'] as String?,
      descriptionHtml: json['descriptionHtml'] as String?,
      viewCount: (json['viewCount'] as num?)?.toInt(),
      viewCountText: json['viewCountText'] as String?,
      published: (json['published'] as num?)?.toInt(),
      publishedText: json['publishedText'] as String?,
      lengthSeconds: (json['lengthSeconds'] as num?)?.toInt(),
      liveNow: json['liveNow'] as bool?,
      premium: json['premium'] as bool?,
      isUpcoming: json['isUpcoming'] as bool?,
    );

Map<String, dynamic> _$InvidiousTrendingRespToJson(
        InvidiousTrendingResp instance) =>
    <String, dynamic>{
      'type': instance.type,
      'title': instance.title,
      'videoId': instance.videoId,
      'author': instance.author,
      'authorId': instance.authorId,
      'authorUrl': instance.authorUrl,
      'authorVerified': instance.authorVerified,
      'videoThumbnails': instance.videoThumbnails,
      'description': instance.description,
      'descriptionHtml': instance.descriptionHtml,
      'viewCount': instance.viewCount,
      'viewCountText': instance.viewCountText,
      'published': instance.published,
      'publishedText': instance.publishedText,
      'lengthSeconds': instance.lengthSeconds,
      'liveNow': instance.liveNow,
      'premium': instance.premium,
      'isUpcoming': instance.isUpcoming,
    };
