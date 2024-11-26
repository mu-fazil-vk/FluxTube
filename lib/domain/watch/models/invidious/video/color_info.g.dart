// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'color_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ColorInfo _$ColorInfoFromJson(Map<String, dynamic> json) => ColorInfo(
      primaries: json['primaries'] as String?,
      transferCharacteristics: json['transferCharacteristics'] as String?,
      matrixCoefficients: json['matrixCoefficients'] as String?,
    );

Map<String, dynamic> _$ColorInfoToJson(ColorInfo instance) => <String, dynamic>{
      'primaries': instance.primaries,
      'transferCharacteristics': instance.transferCharacteristics,
      'matrixCoefficients': instance.matrixCoefficients,
    };
