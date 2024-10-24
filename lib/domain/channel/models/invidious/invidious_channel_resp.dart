import 'package:json_annotation/json_annotation.dart';

import 'author_banner.dart';
import 'author_thumbnail.dart';
import 'latest_video.dart';

part 'invidious_channel_resp.g.dart';

//--------MAIN INVIDIOUS CHANNEL RESPONSE MODEL--------//
// `flutter pub run build_runner build` to generate file

@JsonSerializable()
class InvidiousChannelResp {
  String? author;
  String? authorId;
  String? authorUrl;
  List<AuthorBanner>? authorBanners;
  List<AuthorThumbnail>? authorThumbnails;
  int? subCount;
  int? totalViews;
  int? joined;
  bool? autoGenerated;
  bool? isFamilyFriendly;
  String? description;
  String? descriptionHtml;
  List<String>? allowedRegions;
  List<String>? tabs;
  List<dynamic>? tags;
  bool? authorVerified;
  List<LatestVideo>? latestVideos;
  List<dynamic>? relatedChannels;

  InvidiousChannelResp({
    this.author,
    this.authorId,
    this.authorUrl,
    this.authorBanners,
    this.authorThumbnails,
    this.subCount,
    this.totalViews,
    this.joined,
    this.autoGenerated,
    this.isFamilyFriendly,
    this.description,
    this.descriptionHtml,
    this.allowedRegions,
    this.tabs,
    this.tags,
    this.authorVerified,
    this.latestVideos,
    this.relatedChannels,
  });

  factory InvidiousChannelResp.fromJson(Map<String, dynamic> json) {
    return _$InvidiousChannelRespFromJson(json);
  }

  Map<String, dynamic> toJson() => _$InvidiousChannelRespToJson(this);
}