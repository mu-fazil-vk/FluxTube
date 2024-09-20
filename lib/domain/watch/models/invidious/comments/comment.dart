import 'package:json_annotation/json_annotation.dart';

import 'author_thumbnail.dart';
import 'replies.dart';

part 'comment.g.dart';

@JsonSerializable()
class Comment {
  String? authorId;
  String? authorUrl;
  String? author;
  bool? verified;
  List<AuthorThumbnail>? authorThumbnails;
  bool? authorIsChannelOwner;
  bool? isSponsor;
  int? likeCount;
  bool? isPinned;
  String? commentId;
  String? content;
  String? contentHtml;
  bool? isEdited;
  int? published;
  String? publishedText;
  Replies? replies;

  Comment({
    this.authorId,
    this.authorUrl,
    this.author,
    this.verified,
    this.authorThumbnails,
    this.authorIsChannelOwner,
    this.isSponsor,
    this.likeCount,
    this.isPinned,
    this.commentId,
    this.content,
    this.contentHtml,
    this.isEdited,
    this.published,
    this.publishedText,
    this.replies,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return _$CommentFromJson(json);
  }

  Map<String, dynamic> toJson() => _$CommentToJson(this);
}
