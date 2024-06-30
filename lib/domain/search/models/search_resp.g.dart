// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_resp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchResp _$SearchRespFromJson(Map<String, dynamic> json) => SearchResp(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => Item.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      nextpage: json['nextpage'] as String?,
      suggestion: json['suggestion'] as String?,
      corrected: json['corrected'] as bool?,
    );

Map<String, dynamic> _$SearchRespToJson(SearchResp instance) =>
    <String, dynamic>{
      'items': instance.items,
      'nextpage': instance.nextpage,
      'suggestion': instance.suggestion,
      'corrected': instance.corrected,
    };
