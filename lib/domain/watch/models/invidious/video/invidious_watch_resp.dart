import 'package:json_annotation/json_annotation.dart';

import 'adaptive_format.dart';
import 'author_thumbnail.dart';
import 'caption.dart';
import 'format_stream.dart';
import 'recommended_video.dart';
import 'storyboard.dart';
import 'video_thumbnail.dart';

part 'invidious_watch_resp.g.dart';

//--------MAIN INVIDIOUS WATCH SCREEN VIDEO RESPONSE MODEL--------//
// `flutter pub run build_runner build` to generate file

@JsonSerializable()
class InvidiousWatchResp {
  String? type;
  String? title;
  String? videoId;
  List<VideoThumbnail>? videoThumbnails;
  List<Storyboard>? storyboards;
  String? description;
  String? descriptionHtml;
  int? published;
  String? publishedText;
  List<dynamic>? keywords;
  int? viewCount;
  int? likeCount;
  int? dislikeCount;
  bool? paid;
  bool? premium;
  bool? isFamilyFriendly;
  List<String>? allowedRegions;
  String? genre;
  dynamic genreUrl;
  String? author;
  String? authorId;
  String? authorUrl;
  bool? authorVerified;
  List<AuthorThumbnail>? authorThumbnails;
  String? subCountText;
  int? lengthSeconds;
  bool? allowRatings;
  int? rating;
  bool? isListed;
  bool? liveNow;
  bool? isPostLiveDvr;
  bool? isUpcoming;
  String? dashUrl;
  List<AdaptiveFormat>? adaptiveFormats;
  List<FormatStream>? formatStreams;
  List<Caption>? captions;
  List<RecommendedVideo>? recommendedVideos;

  InvidiousWatchResp({
    this.type,
    this.title,
    this.videoId,
    this.videoThumbnails,
    this.storyboards,
    this.description,
    this.descriptionHtml,
    this.published,
    this.publishedText,
    this.keywords,
    this.viewCount,
    this.likeCount,
    this.dislikeCount,
    this.paid,
    this.premium,
    this.isFamilyFriendly,
    this.allowedRegions,
    this.genre,
    this.genreUrl,
    this.author,
    this.authorId,
    this.authorUrl,
    this.authorVerified,
    this.authorThumbnails,
    this.subCountText,
    this.lengthSeconds,
    this.allowRatings,
    this.rating,
    this.isListed,
    this.liveNow,
    this.isPostLiveDvr,
    this.isUpcoming,
    this.dashUrl,
    this.adaptiveFormats,
    this.formatStreams,
    this.captions,
    this.recommendedVideos,
  });

  factory InvidiousWatchResp.fromJson(Map<String, dynamic> json) {
    return _$InvidiousWatchRespFromJson(json);
  }

  Map<String, dynamic> toJson() => _$InvidiousWatchRespToJson(this);
}
