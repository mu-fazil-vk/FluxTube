import 'package:json_annotation/json_annotation.dart';

part 'replies.g.dart';

@JsonSerializable()
class Replies {
  int? replyCount;
  String? continuation;

  Replies({this.replyCount, this.continuation});

  factory Replies.fromJson(Map<String, dynamic> json) {
    return _$RepliesFromJson(json);
  }

  Map<String, dynamic> toJson() => _$RepliesToJson(this);
}
