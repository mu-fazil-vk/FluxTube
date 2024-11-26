import 'package:json_annotation/json_annotation.dart';

part 'tab.g.dart';

@JsonSerializable()
class Tab {
  String? name;
  String? data;

  Tab({this.name, this.data});

  factory Tab.fromJson(Map<String, dynamic> json) => _$TabFromJson(json);

  Map<String, dynamic> toJson() => _$TabToJson(this);
}
