import 'package:fluxtube/domain/core/invidious_thumbnail.dart';
import 'package:json_annotation/json_annotation.dart';

part 'video_thumbnail.g.dart';

@JsonSerializable()
class VideoThumbnail {
  String? quality;
  String? url;
  int? width;
  int? height;

  VideoThumbnail({this.quality, this.url, this.width, this.height});

  factory VideoThumbnail.fromJson(Map<String, dynamic> json) {
    final thumbnail = _$VideoThumbnailFromJson(json);
    thumbnail.url = directYouTubeThumbnail(thumbnail.url);
    return thumbnail;
  }

  Map<String, dynamic> toJson() => _$VideoThumbnailToJson(this);
}
