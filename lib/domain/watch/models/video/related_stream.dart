import 'package:json_annotation/json_annotation.dart';

part 'related_stream.g.dart';

@JsonSerializable()
class RelatedStream {
  String? url;
  String? type;
  String? title;
  String? thumbnail;
  String? uploaderName;
  String? uploaderUrl;
  String? uploaderAvatar;
  String? uploadedDate;
  dynamic shortDescription;
  int? duration;
  int? views;
  int? uploaded;
  bool? uploaderVerified;
  bool? isShort;

  RelatedStream({
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

  factory RelatedStream.fromJson(Map<String, dynamic> json) {
    return _$RelatedStreamFromJson(json);
  }

  Map<String, dynamic> toJson() => _$RelatedStreamToJson(this);
}
