// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_store.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLocalStoreVideoInfoCollection on Isar {
  IsarCollection<LocalStoreVideoInfo> get localStoreVideoInfos =>
      this.collection();
}

const LocalStoreVideoInfoSchema = CollectionSchema(
  name: r'LocalStoreVideoInfo',
  id: -1330868695837598751,
  properties: {
    r'duration': PropertySchema(
      id: 0,
      name: r'duration',
      type: IsarType.long,
    ),
    r'id': PropertySchema(
      id: 1,
      name: r'id',
      type: IsarType.string,
    ),
    r'isHistory': PropertySchema(
      id: 2,
      name: r'isHistory',
      type: IsarType.bool,
    ),
    r'isLive': PropertySchema(
      id: 3,
      name: r'isLive',
      type: IsarType.bool,
    ),
    r'isSaved': PropertySchema(
      id: 4,
      name: r'isSaved',
      type: IsarType.bool,
    ),
    r'playbackPosition': PropertySchema(
      id: 5,
      name: r'playbackPosition',
      type: IsarType.long,
    ),
    r'thumbnail': PropertySchema(
      id: 6,
      name: r'thumbnail',
      type: IsarType.string,
    ),
    r'title': PropertySchema(
      id: 7,
      name: r'title',
      type: IsarType.string,
    ),
    r'uploadedDate': PropertySchema(
      id: 8,
      name: r'uploadedDate',
      type: IsarType.string,
    ),
    r'uploaderAvatar': PropertySchema(
      id: 9,
      name: r'uploaderAvatar',
      type: IsarType.string,
    ),
    r'uploaderId': PropertySchema(
      id: 10,
      name: r'uploaderId',
      type: IsarType.string,
    ),
    r'uploaderName': PropertySchema(
      id: 11,
      name: r'uploaderName',
      type: IsarType.string,
    ),
    r'uploaderSubscriberCount': PropertySchema(
      id: 12,
      name: r'uploaderSubscriberCount',
      type: IsarType.long,
    ),
    r'uploaderVerified': PropertySchema(
      id: 13,
      name: r'uploaderVerified',
      type: IsarType.bool,
    ),
    r'views': PropertySchema(
      id: 14,
      name: r'views',
      type: IsarType.long,
    )
  },
  estimateSize: _localStoreVideoInfoEstimateSize,
  serialize: _localStoreVideoInfoSerialize,
  deserialize: _localStoreVideoInfoDeserialize,
  deserializeProp: _localStoreVideoInfoDeserializeProp,
  idName: r'isarId',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _localStoreVideoInfoGetId,
  getLinks: _localStoreVideoInfoGetLinks,
  attach: _localStoreVideoInfoAttach,
  version: '3.1.0+1',
);

int _localStoreVideoInfoEstimateSize(
  LocalStoreVideoInfo object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.id.length * 3;
  {
    final value = object.thumbnail;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.title;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.uploadedDate;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.uploaderAvatar;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.uploaderId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.uploaderName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _localStoreVideoInfoSerialize(
  LocalStoreVideoInfo object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.duration);
  writer.writeString(offsets[1], object.id);
  writer.writeBool(offsets[2], object.isHistory);
  writer.writeBool(offsets[3], object.isLive);
  writer.writeBool(offsets[4], object.isSaved);
  writer.writeLong(offsets[5], object.playbackPosition);
  writer.writeString(offsets[6], object.thumbnail);
  writer.writeString(offsets[7], object.title);
  writer.writeString(offsets[8], object.uploadedDate);
  writer.writeString(offsets[9], object.uploaderAvatar);
  writer.writeString(offsets[10], object.uploaderId);
  writer.writeString(offsets[11], object.uploaderName);
  writer.writeLong(offsets[12], object.uploaderSubscriberCount);
  writer.writeBool(offsets[13], object.uploaderVerified);
  writer.writeLong(offsets[14], object.views);
}

LocalStoreVideoInfo _localStoreVideoInfoDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LocalStoreVideoInfo(
    duration: reader.readLongOrNull(offsets[0]),
    id: reader.readString(offsets[1]),
    isHistory: reader.readBoolOrNull(offsets[2]),
    isLive: reader.readBoolOrNull(offsets[3]),
    isSaved: reader.readBoolOrNull(offsets[4]),
    playbackPosition: reader.readLongOrNull(offsets[5]),
    thumbnail: reader.readStringOrNull(offsets[6]),
    title: reader.readStringOrNull(offsets[7]),
    uploadedDate: reader.readStringOrNull(offsets[8]),
    uploaderAvatar: reader.readStringOrNull(offsets[9]),
    uploaderId: reader.readStringOrNull(offsets[10]),
    uploaderName: reader.readStringOrNull(offsets[11]),
    uploaderSubscriberCount: reader.readLongOrNull(offsets[12]),
    uploaderVerified: reader.readBoolOrNull(offsets[13]),
    views: reader.readLongOrNull(offsets[14]),
  );
  return object;
}

P _localStoreVideoInfoDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readBoolOrNull(offset)) as P;
    case 3:
      return (reader.readBoolOrNull(offset)) as P;
    case 4:
      return (reader.readBoolOrNull(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readLongOrNull(offset)) as P;
    case 13:
      return (reader.readBoolOrNull(offset)) as P;
    case 14:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _localStoreVideoInfoGetId(LocalStoreVideoInfo object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _localStoreVideoInfoGetLinks(
    LocalStoreVideoInfo object) {
  return [];
}

void _localStoreVideoInfoAttach(
    IsarCollection<dynamic> col, Id id, LocalStoreVideoInfo object) {}

extension LocalStoreVideoInfoQueryWhereSort
    on QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QWhere> {
  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterWhere>
      anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LocalStoreVideoInfoQueryWhere
    on QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QWhereClause> {
  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterWhereClause>
      isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterWhereClause>
      isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension LocalStoreVideoInfoQueryFilter on QueryBuilder<LocalStoreVideoInfo,
    LocalStoreVideoInfo, QFilterCondition> {
  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      durationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'duration',
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      durationIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'duration',
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      durationEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'duration',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      durationGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'duration',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      durationLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'duration',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      durationBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'duration',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      idEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      idGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      idLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      idBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      idStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      idEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      idContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      idMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      isHistoryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'isHistory',
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      isHistoryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'isHistory',
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      isHistoryEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isHistory',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      isLiveIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'isLive',
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      isLiveIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'isLive',
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      isLiveEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isLive',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      isSavedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'isSaved',
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      isSavedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'isSaved',
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      isSavedEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSaved',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      playbackPositionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'playbackPosition',
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      playbackPositionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'playbackPosition',
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      playbackPositionEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playbackPosition',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      playbackPositionGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'playbackPosition',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      playbackPositionLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'playbackPosition',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      playbackPositionBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'playbackPosition',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      thumbnailIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'thumbnail',
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      thumbnailIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'thumbnail',
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      thumbnailEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'thumbnail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      thumbnailGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'thumbnail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      thumbnailLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'thumbnail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      thumbnailBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'thumbnail',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      thumbnailStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'thumbnail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      thumbnailEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'thumbnail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      thumbnailContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'thumbnail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      thumbnailMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'thumbnail',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      thumbnailIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'thumbnail',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      thumbnailIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'thumbnail',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      titleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      titleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      titleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      titleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      titleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      titleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploadedDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'uploadedDate',
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploadedDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'uploadedDate',
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploadedDateEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uploadedDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploadedDateGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uploadedDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploadedDateLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uploadedDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploadedDateBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uploadedDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploadedDateStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'uploadedDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploadedDateEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'uploadedDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploadedDateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uploadedDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploadedDateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uploadedDate',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploadedDateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uploadedDate',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploadedDateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uploadedDate',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderAvatarIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'uploaderAvatar',
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderAvatarIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'uploaderAvatar',
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderAvatarEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uploaderAvatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderAvatarGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uploaderAvatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderAvatarLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uploaderAvatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderAvatarBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uploaderAvatar',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderAvatarStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'uploaderAvatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderAvatarEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'uploaderAvatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderAvatarContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uploaderAvatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderAvatarMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uploaderAvatar',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderAvatarIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uploaderAvatar',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderAvatarIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uploaderAvatar',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'uploaderId',
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'uploaderId',
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uploaderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uploaderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uploaderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uploaderId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'uploaderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'uploaderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uploaderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uploaderId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uploaderId',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uploaderId',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'uploaderName',
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'uploaderName',
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uploaderName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uploaderName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uploaderName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uploaderName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'uploaderName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'uploaderName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uploaderName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uploaderName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uploaderName',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uploaderName',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderSubscriberCountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'uploaderSubscriberCount',
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderSubscriberCountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'uploaderSubscriberCount',
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderSubscriberCountEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uploaderSubscriberCount',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderSubscriberCountGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uploaderSubscriberCount',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderSubscriberCountLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uploaderSubscriberCount',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderSubscriberCountBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uploaderSubscriberCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderVerifiedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'uploaderVerified',
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderVerifiedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'uploaderVerified',
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      uploaderVerifiedEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uploaderVerified',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      viewsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'views',
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      viewsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'views',
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      viewsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'views',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      viewsGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'views',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      viewsLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'views',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterFilterCondition>
      viewsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'views',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension LocalStoreVideoInfoQueryObject on QueryBuilder<LocalStoreVideoInfo,
    LocalStoreVideoInfo, QFilterCondition> {}

extension LocalStoreVideoInfoQueryLinks on QueryBuilder<LocalStoreVideoInfo,
    LocalStoreVideoInfo, QFilterCondition> {}

extension LocalStoreVideoInfoQuerySortBy
    on QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QSortBy> {
  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      sortByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.asc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      sortByDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.desc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      sortByIsHistory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isHistory', Sort.asc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      sortByIsHistoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isHistory', Sort.desc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      sortByIsLive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLive', Sort.asc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      sortByIsLiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLive', Sort.desc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      sortByIsSaved() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSaved', Sort.asc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      sortByIsSavedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSaved', Sort.desc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      sortByPlaybackPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playbackPosition', Sort.asc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      sortByPlaybackPositionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playbackPosition', Sort.desc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      sortByThumbnail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnail', Sort.asc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      sortByThumbnailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnail', Sort.desc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      sortByUploadedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploadedDate', Sort.asc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      sortByUploadedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploadedDate', Sort.desc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      sortByUploaderAvatar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploaderAvatar', Sort.asc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      sortByUploaderAvatarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploaderAvatar', Sort.desc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      sortByUploaderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploaderId', Sort.asc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      sortByUploaderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploaderId', Sort.desc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      sortByUploaderName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploaderName', Sort.asc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      sortByUploaderNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploaderName', Sort.desc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      sortByUploaderSubscriberCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploaderSubscriberCount', Sort.asc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      sortByUploaderSubscriberCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploaderSubscriberCount', Sort.desc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      sortByUploaderVerified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploaderVerified', Sort.asc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      sortByUploaderVerifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploaderVerified', Sort.desc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      sortByViews() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'views', Sort.asc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      sortByViewsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'views', Sort.desc);
    });
  }
}

extension LocalStoreVideoInfoQuerySortThenBy
    on QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QSortThenBy> {
  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      thenByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.asc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      thenByDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.desc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      thenByIsHistory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isHistory', Sort.asc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      thenByIsHistoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isHistory', Sort.desc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      thenByIsLive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLive', Sort.asc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      thenByIsLiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLive', Sort.desc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      thenByIsSaved() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSaved', Sort.asc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      thenByIsSavedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSaved', Sort.desc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      thenByPlaybackPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playbackPosition', Sort.asc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      thenByPlaybackPositionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playbackPosition', Sort.desc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      thenByThumbnail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnail', Sort.asc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      thenByThumbnailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnail', Sort.desc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      thenByUploadedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploadedDate', Sort.asc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      thenByUploadedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploadedDate', Sort.desc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      thenByUploaderAvatar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploaderAvatar', Sort.asc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      thenByUploaderAvatarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploaderAvatar', Sort.desc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      thenByUploaderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploaderId', Sort.asc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      thenByUploaderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploaderId', Sort.desc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      thenByUploaderName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploaderName', Sort.asc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      thenByUploaderNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploaderName', Sort.desc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      thenByUploaderSubscriberCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploaderSubscriberCount', Sort.asc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      thenByUploaderSubscriberCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploaderSubscriberCount', Sort.desc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      thenByUploaderVerified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploaderVerified', Sort.asc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      thenByUploaderVerifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploaderVerified', Sort.desc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      thenByViews() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'views', Sort.asc);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QAfterSortBy>
      thenByViewsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'views', Sort.desc);
    });
  }
}

extension LocalStoreVideoInfoQueryWhereDistinct
    on QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QDistinct> {
  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QDistinct>
      distinctByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'duration');
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QDistinct>
      distinctById({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QDistinct>
      distinctByIsHistory() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isHistory');
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QDistinct>
      distinctByIsLive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isLive');
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QDistinct>
      distinctByIsSaved() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSaved');
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QDistinct>
      distinctByPlaybackPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playbackPosition');
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QDistinct>
      distinctByThumbnail({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'thumbnail', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QDistinct>
      distinctByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QDistinct>
      distinctByUploadedDate({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uploadedDate', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QDistinct>
      distinctByUploaderAvatar({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uploaderAvatar',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QDistinct>
      distinctByUploaderId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uploaderId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QDistinct>
      distinctByUploaderName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uploaderName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QDistinct>
      distinctByUploaderSubscriberCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uploaderSubscriberCount');
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QDistinct>
      distinctByUploaderVerified() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uploaderVerified');
    });
  }

  QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QDistinct>
      distinctByViews() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'views');
    });
  }
}

extension LocalStoreVideoInfoQueryProperty
    on QueryBuilder<LocalStoreVideoInfo, LocalStoreVideoInfo, QQueryProperty> {
  QueryBuilder<LocalStoreVideoInfo, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<LocalStoreVideoInfo, int?, QQueryOperations> durationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'duration');
    });
  }

  QueryBuilder<LocalStoreVideoInfo, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LocalStoreVideoInfo, bool?, QQueryOperations>
      isHistoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isHistory');
    });
  }

  QueryBuilder<LocalStoreVideoInfo, bool?, QQueryOperations> isLiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isLive');
    });
  }

  QueryBuilder<LocalStoreVideoInfo, bool?, QQueryOperations> isSavedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSaved');
    });
  }

  QueryBuilder<LocalStoreVideoInfo, int?, QQueryOperations>
      playbackPositionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playbackPosition');
    });
  }

  QueryBuilder<LocalStoreVideoInfo, String?, QQueryOperations>
      thumbnailProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'thumbnail');
    });
  }

  QueryBuilder<LocalStoreVideoInfo, String?, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<LocalStoreVideoInfo, String?, QQueryOperations>
      uploadedDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uploadedDate');
    });
  }

  QueryBuilder<LocalStoreVideoInfo, String?, QQueryOperations>
      uploaderAvatarProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uploaderAvatar');
    });
  }

  QueryBuilder<LocalStoreVideoInfo, String?, QQueryOperations>
      uploaderIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uploaderId');
    });
  }

  QueryBuilder<LocalStoreVideoInfo, String?, QQueryOperations>
      uploaderNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uploaderName');
    });
  }

  QueryBuilder<LocalStoreVideoInfo, int?, QQueryOperations>
      uploaderSubscriberCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uploaderSubscriberCount');
    });
  }

  QueryBuilder<LocalStoreVideoInfo, bool?, QQueryOperations>
      uploaderVerifiedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uploaderVerified');
    });
  }

  QueryBuilder<LocalStoreVideoInfo, int?, QQueryOperations> viewsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'views');
    });
  }
}
