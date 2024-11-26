import 'package:json_annotation/json_annotation.dart';

import 'related_stream.dart';
import 'tab.dart';

part 'channel_resp.g.dart';

//--------MAIN PIPED CHANNEL RESPONSE MODEL--------//
// `flutter pub run build_runner build` to generate file

@JsonSerializable()
class ChannelResp {
  String? id;
  String? name;
  dynamic avatarUrl;
  dynamic bannerUrl;
  dynamic description;
  String? nextpage;
  int? subscriberCount;
  bool? verified;
  List<RelatedStream>? relatedStreams;
  List<Tab>? tabs;

  ChannelResp({
    this.id,
    this.name,
    this.avatarUrl,
    this.bannerUrl,
    this.description,
    this.nextpage,
    this.subscriberCount,
    this.verified,
    this.relatedStreams,
    this.tabs,
  });

  factory ChannelResp.fromJson(Map<String, dynamic> json) {
    return _$ChannelRespFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ChannelRespToJson(this);
}
