// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
      author: json['author'] as String?,
      thumbnail: json['thumbnail'] as String?,
      commentId: json['commentId'] as String?,
      commentText: json['commentText'] as String?,
      commentedTime: json['commentedTime'] as String?,
      commentorUrl: json['commentorUrl'] as String?,
      repliesPage: json['repliesPage'] as String?,
      likeCount: (json['likeCount'] as num?)?.toInt(),
      replyCount: (json['replyCount'] as num?)?.toInt(),
      hearted: json['hearted'] as bool?,
      pinned: json['pinned'] as bool?,
      verified: json['verified'] as bool?,
      creatorReplied: json['creatorReplied'] as bool?,
      channelOwner: json['channelOwner'] as bool?,
    );

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
      'author': instance.author,
      'thumbnail': instance.thumbnail,
      'commentId': instance.commentId,
      'commentText': instance.commentText,
      'commentedTime': instance.commentedTime,
      'commentorUrl': instance.commentorUrl,
      'repliesPage': instance.repliesPage,
      'likeCount': instance.likeCount,
      'replyCount': instance.replyCount,
      'hearted': instance.hearted,
      'pinned': instance.pinned,
      'verified': instance.verified,
      'creatorReplied': instance.creatorReplied,
      'channelOwner': instance.channelOwner,
    };
