import 'package:json_annotation/json_annotation.dart';

part 'trending_resp.g.dart';

//--------MAIN PIPED TRENDING RESPONSE MODEL--------//
// `flutter pub run build_runner build` to generate file

@JsonSerializable()
class TrendingResp {
  String? url;
  String? type;
  String? title;
  String? thumbnail;
  String? uploaderName;
  String? uploaderUrl;
  String? uploaderAvatar;
  String? uploadedDate;
  String? shortDescription;
  int? duration;
  int? views;
  int? uploaded;
  bool? uploaderVerified;
  bool? isShort;

  TrendingResp({
    this.url,
    this.type,
    this.title,
    this.thumbnail,
    this.uploaderName,
    this.uploaderUrl,
    this.uploaderAvatar,
    this.uploadedDate,
    this.shortDescription,
    this.duration,
    this.views,
    this.uploaded,
    this.uploaderVerified,
    this.isShort,
  });

  factory TrendingResp.fromJson(Map<String, dynamic> json) {
    return _$TrendingRespFromJson(json);
  }

  Map<String, dynamic> toJson() => _$TrendingRespToJson(this);
}
