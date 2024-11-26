// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
      authorId: json['authorId'] as String?,
      authorUrl: json['authorUrl'] as String?,
      author: json['author'] as String?,
      verified: json['verified'] as bool?,
      authorThumbnails: (json['authorThumbnails'] as List<dynamic>?)
          ?.map((e) => AuthorThumbnail.fromJson(e as Map<String, dynamic>))
          .toList(),
      authorIsChannelOwner: json['authorIsChannelOwner'] as bool?,
      isSponsor: json['isSponsor'] as bool?,
      likeCount: (json['likeCount'] as num?)?.toInt(),
      isPinned: json['isPinned'] as bool?,
      commentId: json['commentId'] as String?,
      content: json['content'] as String?,
      contentHtml: json['contentHtml'] as String?,
      isEdited: json['isEdited'] as bool?,
      published: (json['published'] as num?)?.toInt(),
      publishedText: json['publishedText'] as String?,
      replies: json['replies'] == null
          ? null
          : Replies.fromJson(json['replies'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
      'authorId': instance.authorId,
      'authorUrl': instance.authorUrl,
      'author': instance.author,
      'verified': instance.verified,
      'authorThumbnails': instance.authorThumbnails,
      'authorIsChannelOwner': instance.authorIsChannelOwner,
      'isSponsor': instance.isSponsor,
      'likeCount': instance.likeCount,
      'isPinned': instance.isPinned,
      'commentId': instance.commentId,
      'content': instance.content,
      'contentHtml': instance.contentHtml,
      'isEdited': instance.isEdited,
      'published': instance.published,
      'publishedText': instance.publishedText,
      'replies': instance.replies,
    };
