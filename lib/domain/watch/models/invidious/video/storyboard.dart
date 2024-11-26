import 'package:json_annotation/json_annotation.dart';

part 'storyboard.g.dart';

@JsonSerializable()
class Storyboard {
  String? url;
  String? templateUrl;
  int? width;
  int? height;
  int? count;
  int? interval;
  int? storyboardWidth;
  int? storyboardHeight;
  int? storyboardCount;

  Storyboard({
    this.url,
    this.templateUrl,
    this.width,
    this.height,
    this.count,
    this.interval,
    this.storyboardWidth,
    this.storyboardHeight,
    this.storyboardCount,
  });

  factory Storyboard.fromJson(Map<String, dynamic> json) {
    return _$StoryboardFromJson(json);
  }

  Map<String, dynamic> toJson() => _$StoryboardToJson(this);
}
