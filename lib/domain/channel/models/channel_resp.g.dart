// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_resp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChannelResp _$ChannelRespFromJson(Map<String, dynamic> json) => ChannelResp(
      id: json['id'] as String?,
      name: json['name'] as String?,
      avatarUrl: json['avatarUrl'],
      bannerUrl: json['bannerUrl'],
      description: json['description'],
      nextpage: json['nextpage'] as String?,
      subscriberCount: (json['subscriberCount'] as num?)?.toInt(),
      verified: json['verified'] as bool?,
      relatedStreams: (json['relatedStreams'] as List<dynamic>?)
          ?.map((e) => RelatedStream.fromJson(e as Map<String, dynamic>))
          .toList(),
      tabs: (json['tabs'] as List<dynamic>?)
          ?.map((e) => Tab.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ChannelRespToJson(ChannelResp instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'avatarUrl': instance.avatarUrl,
      'bannerUrl': instance.bannerUrl,
      'description': instance.description,
      'nextpage': instance.nextpage,
      'subscriberCount': instance.subscriberCount,
      'verified': instance.verified,
      'relatedStreams': instance.relatedStreams,
      'tabs': instance.tabs,
    };
