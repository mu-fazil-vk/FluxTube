import 'package:json_annotation/json_annotation.dart';

import 'video_thumbnail.dart';

part 'recommended_video.g.dart';

@JsonSerializable()
class RecommendedVideo {
  String? videoId;
  String? title;
  List<VideoThumbnail>? videoThumbnails;
  String? author;
  String? authorUrl;
  String? authorId;
  bool? authorVerified;
  int? lengthSeconds;
  String? viewCountText;
  int? viewCount;

  RecommendedVideo({
    this.videoId,
    this.title,
    this.videoThumbnails,
    this.author,
    this.authorUrl,
    this.authorId,
    this.authorVerified,
    this.lengthSeconds,
    this.viewCountText,
    this.viewCount,
  });

  factory RecommendedVideo.fromJson(Map<String, dynamic> json) {
    return _$RecommendedVideoFromJson(json);
  }

  Map<String, dynamic> toJson() => _$RecommendedVideoToJson(this);
}
