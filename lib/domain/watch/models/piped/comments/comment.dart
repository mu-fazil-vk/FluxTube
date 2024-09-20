import 'package:json_annotation/json_annotation.dart';

part 'comment.g.dart';

@JsonSerializable()
class Comment {
  String? author;
  String? thumbnail;
  String? commentId;
  String? commentText;
  String? commentedTime;
  String? commentorUrl;
  String? repliesPage;
  int? likeCount;
  int? replyCount;
  bool? hearted;
  bool? pinned;
  bool? verified;
  bool? creatorReplied;
  bool? channelOwner;

  Comment({
    this.author,
    this.thumbnail,
    this.commentId,
    this.commentText,
    this.commentedTime,
    this.commentorUrl,
    this.repliesPage,
    this.likeCount,
    this.replyCount,
    this.hearted,
    this.pinned,
    this.verified,
    this.creatorReplied,
    this.channelOwner,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return _$CommentFromJson(json);
  }

  Map<String, dynamic> toJson() => _$CommentToJson(this);
}
