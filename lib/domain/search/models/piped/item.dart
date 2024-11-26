import 'package:json_annotation/json_annotation.dart';

part 'item.g.dart';

@JsonSerializable()
class Item {
  String? url;
  String? type;
  String? name;
  String? thumbnail;
  String? description;
  int? subscribers;
  int? videos;
  bool? verified;
  String? title;
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

  Item({
    this.url,
    this.type,
    this.name,
    this.thumbnail,
    this.description,
    this.subscribers,
    this.videos,
    this.verified,
    this.title,
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

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);

  Map<String, dynamic> toJson() => _$ItemToJson(this);
}
