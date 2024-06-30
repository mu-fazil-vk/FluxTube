import 'package:json_annotation/json_annotation.dart';

part 'preview_frame.g.dart';

@JsonSerializable()
class PreviewFrame {
  List<String>? urls;
  int? frameWidth;
  int? frameHeight;
  int? totalCount;
  int? durationPerFrame;
  int? framesPerPageX;
  int? framesPerPageY;

  PreviewFrame({
    this.urls,
    this.frameWidth,
    this.frameHeight,
    this.totalCount,
    this.durationPerFrame,
    this.framesPerPageX,
    this.framesPerPageY,
  });

  factory PreviewFrame.fromJson(Map<String, dynamic> json) {
    return _$PreviewFrameFromJson(json);
  }

  Map<String, dynamic> toJson() => _$PreviewFrameToJson(this);
}
