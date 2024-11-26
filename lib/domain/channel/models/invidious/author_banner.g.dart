// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'author_banner.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthorBanner _$AuthorBannerFromJson(Map<String, dynamic> json) => AuthorBanner(
      url: json['url'] as String?,
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AuthorBannerToJson(AuthorBanner instance) =>
    <String, dynamic>{
      'url': instance.url,
      'width': instance.width,
      'height': instance.height,
    };
