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
    return _$VideoThumbnailFromJson(json);
  }

  Map<String, dynamic> toJson() => _$VideoThumbnailToJson(this);
}
