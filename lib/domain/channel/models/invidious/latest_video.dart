import 'package:json_annotation/json_annotation.dart';

import 'video_thumbnail.dart';

part 'latest_video.g.dart';

@JsonSerializable()
class LatestVideo {
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

  LatestVideo({
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

  factory LatestVideo.fromJson(Map<String, dynamic> json) {
    return _$LatestVideoFromJson(json);
  }

  Map<String, dynamic> toJson() => _$LatestVideoToJson(this);
}
