import 'package:json_annotation/json_annotation.dart';

import 'item.dart';

part 'search_resp.g.dart';

@JsonSerializable()
class SearchResp {
  List<Item> items;
  String? nextpage;
  String? suggestion;
  bool? corrected;

  SearchResp(
      {this.items = const [], this.nextpage, this.suggestion, this.corrected});

  factory SearchResp.fromJson(Map<String, dynamic> json) {
    return _$SearchRespFromJson(json);
  }

  Map<String, dynamic> toJson() => _$SearchRespToJson(this);
}
