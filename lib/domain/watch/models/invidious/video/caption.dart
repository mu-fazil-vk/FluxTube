import 'package:json_annotation/json_annotation.dart';

part 'caption.g.dart';

@JsonSerializable()
class Caption {
  String? label;
  @JsonKey(name: 'language_code')
  String? languageCode;
  String? url;

  Caption({this.label, this.languageCode, this.url});

  factory Caption.fromJson(Map<String, dynamic> json) {
    return _$CaptionFromJson(json);
  }

  Map<String, dynamic> toJson() => _$CaptionToJson(this);
}
