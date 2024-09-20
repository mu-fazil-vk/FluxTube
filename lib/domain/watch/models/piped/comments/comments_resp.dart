import 'package:json_annotation/json_annotation.dart';

import 'comment.dart';

part 'comments_resp.g.dart';

//--------MAIN PIPED COMMENTS RESPONSE MODEL--------//
// `flutter pub run build_runner build` to generate file

@JsonSerializable()
class CommentsResp {
  List<Comment> comments;
  String? nextpage;
  bool? disabled;
  int? commentCount;

  CommentsResp({
    this.comments = const [],
    this.nextpage,
    this.disabled,
    this.commentCount,
  });

  factory CommentsResp.fromJson(Map<String, dynamic> json) {
    return _$CommentsRespFromJson(json);
  }

  Map<String, dynamic> toJson() => _$CommentsRespToJson(this);
}
