import 'package:json_annotation/json_annotation.dart';

part 'author_banner.g.dart';

@JsonSerializable()
class AuthorBanner {
  String? url;
  int? width;
  int? height;

  AuthorBanner({this.url, this.width, this.height});

  factory AuthorBanner.fromJson(Map<String, dynamic> json) {
    return _$AuthorBannerFromJson(json);
  }

  Map<String, dynamic> toJson() => _$AuthorBannerToJson(this);
}
