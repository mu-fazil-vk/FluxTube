// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trending_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TrendingEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String serviceType, String region)
        getTrendingData,
    required TResult Function(String serviceType, String region)
        getForcedTrendingData,
    required TResult Function(List<Subscribe> channels) getHomeFeedData,
    required TResult Function(List<Subscribe> channels) getForcedHomeFeedData,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String serviceType, String region)? getTrendingData,
    TResult? Function(String serviceType, String region)? getForcedTrendingData,
    TResult? Function(List<Subscribe> channels)? getHomeFeedData,
    TResult? Function(List<Subscribe> channels)? getForcedHomeFeedData,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String serviceType, String region)? getTrendingData,
    TResult Function(String serviceType, String region)? getForcedTrendingData,
    TResult Function(List<Subscribe> channels)? getHomeFeedData,
    TResult Function(List<Subscribe> channels)? getForcedHomeFeedData,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GetTrendingData value) getTrendingData,
    required TResult Function(GetForcedTrendingData value)
        getForcedTrendingData,
    required TResult Function(GetHomeFeedData value) getHomeFeedData,
    required TResult Function(GetForcedHomeFeedData value)
        getForcedHomeFeedData,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GetTrendingData value)? getTrendingData,
    TResult? Function(GetForcedTrendingData value)? getForcedTrendingData,
    TResult? Function(GetHomeFeedData value)? getHomeFeedData,
    TResult? Function(GetForcedHomeFeedData value)? getForcedHomeFeedData,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GetTrendingData value)? getTrendingData,
    TResult Function(GetForcedTrendingData value)? getForcedTrendingData,
    TResult Function(GetHomeFeedData value)? getHomeFeedData,
    TResult Function(GetForcedHomeFeedData value)? getForcedHomeFeedData,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrendingEventCopyWith<$Res> {
  factory $TrendingEventCopyWith(
          TrendingEvent value, $Res Function(TrendingEvent) then) =
      _$TrendingEventCopyWithImpl<$Res, TrendingEvent>;
}

/// @nodoc
class _$TrendingEventCopyWithImpl<$Res, $Val extends TrendingEvent>
    implements $TrendingEventCopyWith<$Res> {
  _$TrendingEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrendingEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$GetTrendingDataImplCopyWith<$Res> {
  factory _$$GetTrendingDataImplCopyWith(_$GetTrendingDataImpl value,
          $Res Function(_$GetTrendingDataImpl) then) =
      __$$GetTrendingDataImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String serviceType, String region});
}

/// @nodoc
class __$$GetTrendingDataImplCopyWithImpl<$Res>
    extends _$TrendingEventCopyWithImpl<$Res, _$GetTrendingDataImpl>
    implements _$$GetTrendingDataImplCopyWith<$Res> {
  __$$GetTrendingDataImplCopyWithImpl(
      _$GetTrendingDataImpl _value, $Res Function(_$GetTrendingDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of TrendingEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? serviceType = null,
    Object? region = null,
  }) {
    return _then(_$GetTrendingDataImpl(
      serviceType: null == serviceType
          ? _value.serviceType
          : serviceType // ignore: cast_nullable_to_non_nullable
              as String,
      region: null == region
          ? _value.region
          : region // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$GetTrendingDataImpl implements GetTrendingData {
  const _$GetTrendingDataImpl(
      {required this.serviceType, required this.region});

  @override
  final String serviceType;
  @override
  final String region;

  @override
  String toString() {
    return 'TrendingEvent.getTrendingData(serviceType: $serviceType, region: $region)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetTrendingDataImpl &&
            (identical(other.serviceType, serviceType) ||
                other.serviceType == serviceType) &&
            (identical(other.region, region) || other.region == region));
  }

  @override
  int get hashCode => Object.hash(runtimeType, serviceType, region);

  /// Create a copy of TrendingEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GetTrendingDataImplCopyWith<_$GetTrendingDataImpl> get copyWith =>
      __$$GetTrendingDataImplCopyWithImpl<_$GetTrendingDataImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String serviceType, String region)
        getTrendingData,
    required TResult Function(String serviceType, String region)
        getForcedTrendingData,
    required TResult Function(List<Subscribe> channels) getHomeFeedData,
    required TResult Function(List<Subscribe> channels) getForcedHomeFeedData,
  }) {
    return getTrendingData(serviceType, region);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String serviceType, String region)? getTrendingData,
    TResult? Function(String serviceType, String region)? getForcedTrendingData,
    TResult? Function(List<Subscribe> channels)? getHomeFeedData,
    TResult? Function(List<Subscribe> channels)? getForcedHomeFeedData,
  }) {
    return getTrendingData?.call(serviceType, region);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String serviceType, String region)? getTrendingData,
    TResult Function(String serviceType, String region)? getForcedTrendingData,
    TResult Function(List<Subscribe> channels)? getHomeFeedData,
    TResult Function(List<Subscribe> channels)? getForcedHomeFeedData,
    required TResult orElse(),
  }) {
    if (getTrendingData != null) {
      return getTrendingData(serviceType, region);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GetTrendingData value) getTrendingData,
    required TResult Function(GetForcedTrendingData value)
        getForcedTrendingData,
    required TResult Function(GetHomeFeedData value) getHomeFeedData,
    required TResult Function(GetForcedHomeFeedData value)
        getForcedHomeFeedData,
  }) {
    return getTrendingData(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GetTrendingData value)? getTrendingData,
    TResult? Function(GetForcedTrendingData value)? getForcedTrendingData,
    TResult? Function(GetHomeFeedData value)? getHomeFeedData,
    TResult? Function(GetForcedHomeFeedData value)? getForcedHomeFeedData,
  }) {
    return getTrendingData?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GetTrendingData value)? getTrendingData,
    TResult Function(GetForcedTrendingData value)? getForcedTrendingData,
    TResult Function(GetHomeFeedData value)? getHomeFeedData,
    TResult Function(GetForcedHomeFeedData value)? getForcedHomeFeedData,
    required TResult orElse(),
  }) {
    if (getTrendingData != null) {
      return getTrendingData(this);
    }
    return orElse();
  }
}

abstract class GetTrendingData implements TrendingEvent {
  const factory GetTrendingData(
      {required final String serviceType,
      required final String region}) = _$GetTrendingDataImpl;

  String get serviceType;
  String get region;

  /// Create a copy of TrendingEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GetTrendingDataImplCopyWith<_$GetTrendingDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GetForcedTrendingDataImplCopyWith<$Res> {
  factory _$$GetForcedTrendingDataImplCopyWith(
          _$GetForcedTrendingDataImpl value,
          $Res Function(_$GetForcedTrendingDataImpl) then) =
      __$$GetForcedTrendingDataImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String serviceType, String region});
}

/// @nodoc
class __$$GetForcedTrendingDataImplCopyWithImpl<$Res>
    extends _$TrendingEventCopyWithImpl<$Res, _$GetForcedTrendingDataImpl>
    implements _$$GetForcedTrendingDataImplCopyWith<$Res> {
  __$$GetForcedTrendingDataImplCopyWithImpl(_$GetForcedTrendingDataImpl _value,
      $Res Function(_$GetForcedTrendingDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of TrendingEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? serviceType = null,
    Object? region = null,
  }) {
    return _then(_$GetForcedTrendingDataImpl(
      serviceType: null == serviceType
          ? _value.serviceType
          : serviceType // ignore: cast_nullable_to_non_nullable
              as String,
      region: null == region
          ? _value.region
          : region // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$GetForcedTrendingDataImpl implements GetForcedTrendingData {
  const _$GetForcedTrendingDataImpl(
      {required this.serviceType, required this.region});

  @override
  final String serviceType;
  @override
  final String region;

  @override
  String toString() {
    return 'TrendingEvent.getForcedTrendingData(serviceType: $serviceType, region: $region)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetForcedTrendingDataImpl &&
            (identical(other.serviceType, serviceType) ||
                other.serviceType == serviceType) &&
            (identical(other.region, region) || other.region == region));
  }

  @override
  int get hashCode => Object.hash(runtimeType, serviceType, region);

  /// Create a copy of TrendingEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GetForcedTrendingDataImplCopyWith<_$GetForcedTrendingDataImpl>
      get copyWith => __$$GetForcedTrendingDataImplCopyWithImpl<
          _$GetForcedTrendingDataImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String serviceType, String region)
        getTrendingData,
    required TResult Function(String serviceType, String region)
        getForcedTrendingData,
    required TResult Function(List<Subscribe> channels) getHomeFeedData,
    required TResult Function(List<Subscribe> channels) getForcedHomeFeedData,
  }) {
    return getForcedTrendingData(serviceType, region);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String serviceType, String region)? getTrendingData,
    TResult? Function(String serviceType, String region)? getForcedTrendingData,
    TResult? Function(List<Subscribe> channels)? getHomeFeedData,
    TResult? Function(List<Subscribe> channels)? getForcedHomeFeedData,
  }) {
    return getForcedTrendingData?.call(serviceType, region);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String serviceType, String region)? getTrendingData,
    TResult Function(String serviceType, String region)? getForcedTrendingData,
    TResult Function(List<Subscribe> channels)? getHomeFeedData,
    TResult Function(List<Subscribe> channels)? getForcedHomeFeedData,
    required TResult orElse(),
  }) {
    if (getForcedTrendingData != null) {
      return getForcedTrendingData(serviceType, region);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GetTrendingData value) getTrendingData,
    required TResult Function(GetForcedTrendingData value)
        getForcedTrendingData,
    required TResult Function(GetHomeFeedData value) getHomeFeedData,
    required TResult Function(GetForcedHomeFeedData value)
        getForcedHomeFeedData,
  }) {
    return getForcedTrendingData(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GetTrendingData value)? getTrendingData,
    TResult? Function(GetForcedTrendingData value)? getForcedTrendingData,
    TResult? Function(GetHomeFeedData value)? getHomeFeedData,
    TResult? Function(GetForcedHomeFeedData value)? getForcedHomeFeedData,
  }) {
    return getForcedTrendingData?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GetTrendingData value)? getTrendingData,
    TResult Function(GetForcedTrendingData value)? getForcedTrendingData,
    TResult Function(GetHomeFeedData value)? getHomeFeedData,
    TResult Function(GetForcedHomeFeedData value)? getForcedHomeFeedData,
    required TResult orElse(),
  }) {
    if (getForcedTrendingData != null) {
      return getForcedTrendingData(this);
    }
    return orElse();
  }
}

abstract class GetForcedTrendingData implements TrendingEvent {
  const factory GetForcedTrendingData(
      {required final String serviceType,
      required final String region}) = _$GetForcedTrendingDataImpl;

  String get serviceType;
  String get region;

  /// Create a copy of TrendingEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GetForcedTrendingDataImplCopyWith<_$GetForcedTrendingDataImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GetHomeFeedDataImplCopyWith<$Res> {
  factory _$$GetHomeFeedDataImplCopyWith(_$GetHomeFeedDataImpl value,
          $Res Function(_$GetHomeFeedDataImpl) then) =
      __$$GetHomeFeedDataImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<Subscribe> channels});
}

/// @nodoc
class __$$GetHomeFeedDataImplCopyWithImpl<$Res>
    extends _$TrendingEventCopyWithImpl<$Res, _$GetHomeFeedDataImpl>
    implements _$$GetHomeFeedDataImplCopyWith<$Res> {
  __$$GetHomeFeedDataImplCopyWithImpl(
      _$GetHomeFeedDataImpl _value, $Res Function(_$GetHomeFeedDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of TrendingEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? channels = null,
  }) {
    return _then(_$GetHomeFeedDataImpl(
      channels: null == channels
          ? _value._channels
          : channels // ignore: cast_nullable_to_non_nullable
              as List<Subscribe>,
    ));
  }
}

/// @nodoc

class _$GetHomeFeedDataImpl implements GetHomeFeedData {
  const _$GetHomeFeedDataImpl({required final List<Subscribe> channels})
      : _channels = channels;

  final List<Subscribe> _channels;
  @override
  List<Subscribe> get channels {
    if (_channels is EqualUnmodifiableListView) return _channels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_channels);
  }

  @override
  String toString() {
    return 'TrendingEvent.getHomeFeedData(channels: $channels)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetHomeFeedDataImpl &&
            const DeepCollectionEquality().equals(other._channels, _channels));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_channels));

  /// Create a copy of TrendingEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GetHomeFeedDataImplCopyWith<_$GetHomeFeedDataImpl> get copyWith =>
      __$$GetHomeFeedDataImplCopyWithImpl<_$GetHomeFeedDataImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String serviceType, String region)
        getTrendingData,
    required TResult Function(String serviceType, String region)
        getForcedTrendingData,
    required TResult Function(List<Subscribe> channels) getHomeFeedData,
    required TResult Function(List<Subscribe> channels) getForcedHomeFeedData,
  }) {
    return getHomeFeedData(channels);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String serviceType, String region)? getTrendingData,
    TResult? Function(String serviceType, String region)? getForcedTrendingData,
    TResult? Function(List<Subscribe> channels)? getHomeFeedData,
    TResult? Function(List<Subscribe> channels)? getForcedHomeFeedData,
  }) {
    return getHomeFeedData?.call(channels);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String serviceType, String region)? getTrendingData,
    TResult Function(String serviceType, String region)? getForcedTrendingData,
    TResult Function(List<Subscribe> channels)? getHomeFeedData,
    TResult Function(List<Subscribe> channels)? getForcedHomeFeedData,
    required TResult orElse(),
  }) {
    if (getHomeFeedData != null) {
      return getHomeFeedData(channels);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GetTrendingData value) getTrendingData,
    required TResult Function(GetForcedTrendingData value)
        getForcedTrendingData,
    required TResult Function(GetHomeFeedData value) getHomeFeedData,
    required TResult Function(GetForcedHomeFeedData value)
        getForcedHomeFeedData,
  }) {
    return getHomeFeedData(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GetTrendingData value)? getTrendingData,
    TResult? Function(GetForcedTrendingData value)? getForcedTrendingData,
    TResult? Function(GetHomeFeedData value)? getHomeFeedData,
    TResult? Function(GetForcedHomeFeedData value)? getForcedHomeFeedData,
  }) {
    return getHomeFeedData?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GetTrendingData value)? getTrendingData,
    TResult Function(GetForcedTrendingData value)? getForcedTrendingData,
    TResult Function(GetHomeFeedData value)? getHomeFeedData,
    TResult Function(GetForcedHomeFeedData value)? getForcedHomeFeedData,
    required TResult orElse(),
  }) {
    if (getHomeFeedData != null) {
      return getHomeFeedData(this);
    }
    return orElse();
  }
}

abstract class GetHomeFeedData implements TrendingEvent {
  const factory GetHomeFeedData({required final List<Subscribe> channels}) =
      _$GetHomeFeedDataImpl;

  List<Subscribe> get channels;

  /// Create a copy of TrendingEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GetHomeFeedDataImplCopyWith<_$GetHomeFeedDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GetForcedHomeFeedDataImplCopyWith<$Res> {
  factory _$$GetForcedHomeFeedDataImplCopyWith(
          _$GetForcedHomeFeedDataImpl value,
          $Res Function(_$GetForcedHomeFeedDataImpl) then) =
      __$$GetForcedHomeFeedDataImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<Subscribe> channels});
}

/// @nodoc
class __$$GetForcedHomeFeedDataImplCopyWithImpl<$Res>
    extends _$TrendingEventCopyWithImpl<$Res, _$GetForcedHomeFeedDataImpl>
    implements _$$GetForcedHomeFeedDataImplCopyWith<$Res> {
  __$$GetForcedHomeFeedDataImplCopyWithImpl(_$GetForcedHomeFeedDataImpl _value,
      $Res Function(_$GetForcedHomeFeedDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of TrendingEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? channels = null,
  }) {
    return _then(_$GetForcedHomeFeedDataImpl(
      channels: null == channels
          ? _value._channels
          : channels // ignore: cast_nullable_to_non_nullable
              as List<Subscribe>,
    ));
  }
}

/// @nodoc

class _$GetForcedHomeFeedDataImpl implements GetForcedHomeFeedData {
  const _$GetForcedHomeFeedDataImpl({required final List<Subscribe> channels})
      : _channels = channels;

  final List<Subscribe> _channels;
  @override
  List<Subscribe> get channels {
    if (_channels is EqualUnmodifiableListView) return _channels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_channels);
  }

  @override
  String toString() {
    return 'TrendingEvent.getForcedHomeFeedData(channels: $channels)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetForcedHomeFeedDataImpl &&
            const DeepCollectionEquality().equals(other._channels, _channels));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_channels));

  /// Create a copy of TrendingEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GetForcedHomeFeedDataImplCopyWith<_$GetForcedHomeFeedDataImpl>
      get copyWith => __$$GetForcedHomeFeedDataImplCopyWithImpl<
          _$GetForcedHomeFeedDataImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String serviceType, String region)
        getTrendingData,
    required TResult Function(String serviceType, String region)
        getForcedTrendingData,
    required TResult Function(List<Subscribe> channels) getHomeFeedData,
    required TResult Function(List<Subscribe> channels) getForcedHomeFeedData,
  }) {
    return getForcedHomeFeedData(channels);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String serviceType, String region)? getTrendingData,
    TResult? Function(String serviceType, String region)? getForcedTrendingData,
    TResult? Function(List<Subscribe> channels)? getHomeFeedData,
    TResult? Function(List<Subscribe> channels)? getForcedHomeFeedData,
  }) {
    return getForcedHomeFeedData?.call(channels);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String serviceType, String region)? getTrendingData,
    TResult Function(String serviceType, String region)? getForcedTrendingData,
    TResult Function(List<Subscribe> channels)? getHomeFeedData,
    TResult Function(List<Subscribe> channels)? getForcedHomeFeedData,
    required TResult orElse(),
  }) {
    if (getForcedHomeFeedData != null) {
      return getForcedHomeFeedData(channels);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GetTrendingData value) getTrendingData,
    required TResult Function(GetForcedTrendingData value)
        getForcedTrendingData,
    required TResult Function(GetHomeFeedData value) getHomeFeedData,
    required TResult Function(GetForcedHomeFeedData value)
        getForcedHomeFeedData,
  }) {
    return getForcedHomeFeedData(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GetTrendingData value)? getTrendingData,
    TResult? Function(GetForcedTrendingData value)? getForcedTrendingData,
    TResult? Function(GetHomeFeedData value)? getHomeFeedData,
    TResult? Function(GetForcedHomeFeedData value)? getForcedHomeFeedData,
  }) {
    return getForcedHomeFeedData?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GetTrendingData value)? getTrendingData,
    TResult Function(GetForcedTrendingData value)? getForcedTrendingData,
    TResult Function(GetHomeFeedData value)? getHomeFeedData,
    TResult Function(GetForcedHomeFeedData value)? getForcedHomeFeedData,
    required TResult orElse(),
  }) {
    if (getForcedHomeFeedData != null) {
      return getForcedHomeFeedData(this);
    }
    return orElse();
  }
}

abstract class GetForcedHomeFeedData implements TrendingEvent {
  const factory GetForcedHomeFeedData(
      {required final List<Subscribe> channels}) = _$GetForcedHomeFeedDataImpl;

  List<Subscribe> get channels;

  /// Create a copy of TrendingEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GetForcedHomeFeedDataImplCopyWith<_$GetForcedHomeFeedDataImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$TrendingState {
  String get lastUsedRegion => throw _privateConstructorUsedError; // PIPED
  List<TrendingResp> get trendingResult => throw _privateConstructorUsedError;
  List<TrendingResp> get feedResult => throw _privateConstructorUsedError;
  ApiStatus get fetchTrendingStatus => throw _privateConstructorUsedError;
  ApiStatus get fetchFeedStatus =>
      throw _privateConstructorUsedError; // EXPLODE
  ApiStatus get fetchInvidiousTrendingStatus =>
      throw _privateConstructorUsedError;
  List<InvidiousTrendingResp> get invidiousTrendingResult =>
      throw _privateConstructorUsedError;

  /// Create a copy of TrendingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrendingStateCopyWith<TrendingState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrendingStateCopyWith<$Res> {
  factory $TrendingStateCopyWith(
          TrendingState value, $Res Function(TrendingState) then) =
      _$TrendingStateCopyWithImpl<$Res, TrendingState>;
  @useResult
  $Res call(
      {String lastUsedRegion,
      List<TrendingResp> trendingResult,
      List<TrendingResp> feedResult,
      ApiStatus fetchTrendingStatus,
      ApiStatus fetchFeedStatus,
      ApiStatus fetchInvidiousTrendingStatus,
      List<InvidiousTrendingResp> invidiousTrendingResult});
}

/// @nodoc
class _$TrendingStateCopyWithImpl<$Res, $Val extends TrendingState>
    implements $TrendingStateCopyWith<$Res> {
  _$TrendingStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrendingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lastUsedRegion = null,
    Object? trendingResult = null,
    Object? feedResult = null,
    Object? fetchTrendingStatus = null,
    Object? fetchFeedStatus = null,
    Object? fetchInvidiousTrendingStatus = null,
    Object? invidiousTrendingResult = null,
  }) {
    return _then(_value.copyWith(
      lastUsedRegion: null == lastUsedRegion
          ? _value.lastUsedRegion
          : lastUsedRegion // ignore: cast_nullable_to_non_nullable
              as String,
      trendingResult: null == trendingResult
          ? _value.trendingResult
          : trendingResult // ignore: cast_nullable_to_non_nullable
              as List<TrendingResp>,
      feedResult: null == feedResult
          ? _value.feedResult
          : feedResult // ignore: cast_nullable_to_non_nullable
              as List<TrendingResp>,
      fetchTrendingStatus: null == fetchTrendingStatus
          ? _value.fetchTrendingStatus
          : fetchTrendingStatus // ignore: cast_nullable_to_non_nullable
              as ApiStatus,
      fetchFeedStatus: null == fetchFeedStatus
          ? _value.fetchFeedStatus
          : fetchFeedStatus // ignore: cast_nullable_to_non_nullable
              as ApiStatus,
      fetchInvidiousTrendingStatus: null == fetchInvidiousTrendingStatus
          ? _value.fetchInvidiousTrendingStatus
          : fetchInvidiousTrendingStatus // ignore: cast_nullable_to_non_nullable
              as ApiStatus,
      invidiousTrendingResult: null == invidiousTrendingResult
          ? _value.invidiousTrendingResult
          : invidiousTrendingResult // ignore: cast_nullable_to_non_nullable
              as List<InvidiousTrendingResp>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InitialImplCopyWith<$Res>
    implements $TrendingStateCopyWith<$Res> {
  factory _$$InitialImplCopyWith(
          _$InitialImpl value, $Res Function(_$InitialImpl) then) =
      __$$InitialImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String lastUsedRegion,
      List<TrendingResp> trendingResult,
      List<TrendingResp> feedResult,
      ApiStatus fetchTrendingStatus,
      ApiStatus fetchFeedStatus,
      ApiStatus fetchInvidiousTrendingStatus,
      List<InvidiousTrendingResp> invidiousTrendingResult});
}

/// @nodoc
class __$$InitialImplCopyWithImpl<$Res>
    extends _$TrendingStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
      _$InitialImpl _value, $Res Function(_$InitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of TrendingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lastUsedRegion = null,
    Object? trendingResult = null,
    Object? feedResult = null,
    Object? fetchTrendingStatus = null,
    Object? fetchFeedStatus = null,
    Object? fetchInvidiousTrendingStatus = null,
    Object? invidiousTrendingResult = null,
  }) {
    return _then(_$InitialImpl(
      lastUsedRegion: null == lastUsedRegion
          ? _value.lastUsedRegion
          : lastUsedRegion // ignore: cast_nullable_to_non_nullable
              as String,
      trendingResult: null == trendingResult
          ? _value._trendingResult
          : trendingResult // ignore: cast_nullable_to_non_nullable
              as List<TrendingResp>,
      feedResult: null == feedResult
          ? _value._feedResult
          : feedResult // ignore: cast_nullable_to_non_nullable
              as List<TrendingResp>,
      fetchTrendingStatus: null == fetchTrendingStatus
          ? _value.fetchTrendingStatus
          : fetchTrendingStatus // ignore: cast_nullable_to_non_nullable
              as ApiStatus,
      fetchFeedStatus: null == fetchFeedStatus
          ? _value.fetchFeedStatus
          : fetchFeedStatus // ignore: cast_nullable_to_non_nullable
              as ApiStatus,
      fetchInvidiousTrendingStatus: null == fetchInvidiousTrendingStatus
          ? _value.fetchInvidiousTrendingStatus
          : fetchInvidiousTrendingStatus // ignore: cast_nullable_to_non_nullable
              as ApiStatus,
      invidiousTrendingResult: null == invidiousTrendingResult
          ? _value._invidiousTrendingResult
          : invidiousTrendingResult // ignore: cast_nullable_to_non_nullable
              as List<InvidiousTrendingResp>,
    ));
  }
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl(
      {required this.lastUsedRegion,
      required final List<TrendingResp> trendingResult,
      required final List<TrendingResp> feedResult,
      required this.fetchTrendingStatus,
      required this.fetchFeedStatus,
      required this.fetchInvidiousTrendingStatus,
      required final List<InvidiousTrendingResp> invidiousTrendingResult})
      : _trendingResult = trendingResult,
        _feedResult = feedResult,
        _invidiousTrendingResult = invidiousTrendingResult;

  @override
  final String lastUsedRegion;
// PIPED
  final List<TrendingResp> _trendingResult;
// PIPED
  @override
  List<TrendingResp> get trendingResult {
    if (_trendingResult is EqualUnmodifiableListView) return _trendingResult;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_trendingResult);
  }

  final List<TrendingResp> _feedResult;
  @override
  List<TrendingResp> get feedResult {
    if (_feedResult is EqualUnmodifiableListView) return _feedResult;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_feedResult);
  }

  @override
  final ApiStatus fetchTrendingStatus;
  @override
  final ApiStatus fetchFeedStatus;
// EXPLODE
  @override
  final ApiStatus fetchInvidiousTrendingStatus;
  final List<InvidiousTrendingResp> _invidiousTrendingResult;
  @override
  List<InvidiousTrendingResp> get invidiousTrendingResult {
    if (_invidiousTrendingResult is EqualUnmodifiableListView)
      return _invidiousTrendingResult;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_invidiousTrendingResult);
  }

  @override
  String toString() {
    return 'TrendingState(lastUsedRegion: $lastUsedRegion, trendingResult: $trendingResult, feedResult: $feedResult, fetchTrendingStatus: $fetchTrendingStatus, fetchFeedStatus: $fetchFeedStatus, fetchInvidiousTrendingStatus: $fetchInvidiousTrendingStatus, invidiousTrendingResult: $invidiousTrendingResult)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InitialImpl &&
            (identical(other.lastUsedRegion, lastUsedRegion) ||
                other.lastUsedRegion == lastUsedRegion) &&
            const DeepCollectionEquality()
                .equals(other._trendingResult, _trendingResult) &&
            const DeepCollectionEquality()
                .equals(other._feedResult, _feedResult) &&
            (identical(other.fetchTrendingStatus, fetchTrendingStatus) ||
                other.fetchTrendingStatus == fetchTrendingStatus) &&
            (identical(other.fetchFeedStatus, fetchFeedStatus) ||
                other.fetchFeedStatus == fetchFeedStatus) &&
            (identical(other.fetchInvidiousTrendingStatus,
                    fetchInvidiousTrendingStatus) ||
                other.fetchInvidiousTrendingStatus ==
                    fetchInvidiousTrendingStatus) &&
            const DeepCollectionEquality().equals(
                other._invidiousTrendingResult, _invidiousTrendingResult));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      lastUsedRegion,
      const DeepCollectionEquality().hash(_trendingResult),
      const DeepCollectionEquality().hash(_feedResult),
      fetchTrendingStatus,
      fetchFeedStatus,
      fetchInvidiousTrendingStatus,
      const DeepCollectionEquality().hash(_invidiousTrendingResult));

  /// Create a copy of TrendingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InitialImplCopyWith<_$InitialImpl> get copyWith =>
      __$$InitialImplCopyWithImpl<_$InitialImpl>(this, _$identity);
}

abstract class _Initial implements TrendingState {
  const factory _Initial(
          {required final String lastUsedRegion,
          required final List<TrendingResp> trendingResult,
          required final List<TrendingResp> feedResult,
          required final ApiStatus fetchTrendingStatus,
          required final ApiStatus fetchFeedStatus,
          required final ApiStatus fetchInvidiousTrendingStatus,
          required final List<InvidiousTrendingResp> invidiousTrendingResult}) =
      _$InitialImpl;

  @override
  String get lastUsedRegion; // PIPED
  @override
  List<TrendingResp> get trendingResult;
  @override
  List<TrendingResp> get feedResult;
  @override
  ApiStatus get fetchTrendingStatus;
  @override
  ApiStatus get fetchFeedStatus; // EXPLODE
  @override
  ApiStatus get fetchInvidiousTrendingStatus;
  @override
  List<InvidiousTrendingResp> get invidiousTrendingResult;

  /// Create a copy of TrendingState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InitialImplCopyWith<_$InitialImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
