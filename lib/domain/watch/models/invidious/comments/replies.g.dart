// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'replies.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Replies _$RepliesFromJson(Map<String, dynamic> json) => Replies(
      replyCount: (json['replyCount'] as num?)?.toInt(),
      continuation: json['continuation'] as String?,
    );

Map<String, dynamic> _$RepliesToJson(Replies instance) => <String, dynamic>{
      'replyCount': instance.replyCount,
      'continuation': instance.continuation,
    };
