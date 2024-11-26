import 'package:json_annotation/json_annotation.dart';

import 'video_thumbnail.dart';

part 'invidious_trending_resp.g.dart';

//--------MAIN INVIDIOUS TRENDING RESPONSE MODEL--------//
// `flutter pub run build_runner build` to generate file

@JsonSerializable()
class InvidiousTrendingResp {
  String? type;
  String? title;
  String? videoId;
  String? author;
  String? authorId;
  String? authorUrl;
  bool? authorVerified;
  List<VideoThumbnail>? videoThumbnails;
  String? description;
  String? descriptionHtml;
  int? viewCount;
  String? viewCountText;
  int? published;
  String? publishedText;
  int? lengthSeconds;
  bool? liveNow;
  bool? premium;
  bool? isUpcoming;

  InvidiousTrendingResp({
    this.type,
    this.title,
    this.videoId,
    this.author,
    this.authorId,
    this.authorUrl,
    this.authorVerified,
    this.videoThumbnails,
    this.description,
    this.descriptionHtml,
    this.viewCount,
    this.viewCountText,
    this.published,
    this.publishedText,
    this.lengthSeconds,
    this.liveNow,
    this.premium,
    this.isUpcoming,
  });

  factory InvidiousTrendingResp.fromJson(Map<String, dynamic> json) {
    return _$InvidiousTrendingRespFromJson(json);
  }

  Map<String, dynamic> toJson() => _$InvidiousTrendingRespToJson(this);
}
