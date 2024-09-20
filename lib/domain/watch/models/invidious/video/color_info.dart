import 'package:json_annotation/json_annotation.dart';

part 'color_info.g.dart';

@JsonSerializable()
class ColorInfo {
  String? primaries;
  String? transferCharacteristics;
  String? matrixCoefficients;

  ColorInfo({
    this.primaries,
    this.transferCharacteristics,
    this.matrixCoefficients,
  });

  factory ColorInfo.fromJson(Map<String, dynamic> json) {
    return _$ColorInfoFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ColorInfoToJson(this);
}
