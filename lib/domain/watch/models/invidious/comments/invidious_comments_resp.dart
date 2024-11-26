import 'package:json_annotation/json_annotation.dart';

import 'comment.dart';

part 'invidious_comments_resp.g.dart';

//--------MAIN INVIDIOUS COMMENTS RESPONSE MODEL--------//
// `flutter pub run build_runner build` to generate file

@JsonSerializable()
class InvidiousCommentsResp {
  int? commentCount;
  String? videoId;
  List<Comment>? comments;
  String? continuation;

  InvidiousCommentsResp({
    this.commentCount,
    this.videoId,
    this.comments,
    this.continuation,
  });

  factory InvidiousCommentsResp.fromJson(Map<String, dynamic> json) {
    return _$InvidiousCommentsRespFromJson(json);
  }

  Map<String, dynamic> toJson() => _$InvidiousCommentsRespToJson(this);
}
