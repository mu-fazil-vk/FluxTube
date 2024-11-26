// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invidious_comments_resp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvidiousCommentsResp _$InvidiousCommentsRespFromJson(
        Map<String, dynamic> json) =>
    InvidiousCommentsResp(
      commentCount: (json['commentCount'] as num?)?.toInt(),
      videoId: json['videoId'] as String?,
      comments: (json['comments'] as List<dynamic>?)
          ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList(),
      continuation: json['continuation'] as String?,
    );

Map<String, dynamic> _$InvidiousCommentsRespToJson(
        InvidiousCommentsResp instance) =>
    <String, dynamic>{
      'commentCount': instance.commentCount,
      'videoId': instance.videoId,
      'comments': instance.comments,
      'continuation': instance.continuation,
    };
