// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'channel_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ChannelEvent {
  String get serviceType => throw _privateConstructorUsedError;
  String get channelId => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String serviceType, String channelId)
        getChannelData,
    required TResult Function(
            String serviceType, String channelId, String? nextPage)
        getMoreChannelVideos,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String serviceType, String channelId)? getChannelData,
    TResult? Function(String serviceType, String channelId, String? nextPage)?
        getMoreChannelVideos,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String serviceType, String channelId)? getChannelData,
    TResult Function(String serviceType, String channelId, String? nextPage)?
        getMoreChannelVideos,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GetChannelData value) getChannelData,
    required TResult Function(GetMoreChannelVideos value) getMoreChannelVideos,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GetChannelData value)? getChannelData,
    TResult? Function(GetMoreChannelVideos value)? getMoreChannelVideos,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GetChannelData value)? getChannelData,
    TResult Function(GetMoreChannelVideos value)? getMoreChannelVideos,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Create a copy of ChannelEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChannelEventCopyWith<ChannelEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChannelEventCopyWith<$Res> {
  factory $ChannelEventCopyWith(
          ChannelEvent value, $Res Function(ChannelEvent) then) =
      _$ChannelEventCopyWithImpl<$Res, ChannelEvent>;
  @useResult
  $Res call({String serviceType, String channelId});
}

/// @nodoc
class _$ChannelEventCopyWithImpl<$Res, $Val extends ChannelEvent>
    implements $ChannelEventCopyWith<$Res> {
  _$ChannelEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChannelEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? serviceType = null,
    Object? channelId = null,
  }) {
    return _then(_value.copyWith(
      serviceType: null == serviceType
          ? _value.serviceType
          : serviceType // ignore: cast_nullable_to_non_nullable
              as String,
      channelId: null == channelId
          ? _value.channelId
          : channelId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GetChannelDataImplCopyWith<$Res>
    implements $ChannelEventCopyWith<$Res> {
  factory _$$GetChannelDataImplCopyWith(_$GetChannelDataImpl value,
          $Res Function(_$GetChannelDataImpl) then) =
      __$$GetChannelDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String serviceType, String channelId});
}

/// @nodoc
class __$$GetChannelDataImplCopyWithImpl<$Res>
    extends _$ChannelEventCopyWithImpl<$Res, _$GetChannelDataImpl>
    implements _$$GetChannelDataImplCopyWith<$Res> {
  __$$GetChannelDataImplCopyWithImpl(
      _$GetChannelDataImpl _value, $Res Function(_$GetChannelDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChannelEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? serviceType = null,
    Object? channelId = null,
  }) {
    return _then(_$GetChannelDataImpl(
      serviceType: null == serviceType
          ? _value.serviceType
          : serviceType // ignore: cast_nullable_to_non_nullable
              as String,
      channelId: null == channelId
          ? _value.channelId
          : channelId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$GetChannelDataImpl implements GetChannelData {
  const _$GetChannelDataImpl(
      {required this.serviceType, required this.channelId});

  @override
  final String serviceType;
  @override
  final String channelId;

  @override
  String toString() {
    return 'ChannelEvent.getChannelData(serviceType: $serviceType, channelId: $channelId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetChannelDataImpl &&
            (identical(other.serviceType, serviceType) ||
                other.serviceType == serviceType) &&
            (identical(other.channelId, channelId) ||
                other.channelId == channelId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, serviceType, channelId);

  /// Create a copy of ChannelEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GetChannelDataImplCopyWith<_$GetChannelDataImpl> get copyWith =>
      __$$GetChannelDataImplCopyWithImpl<_$GetChannelDataImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String serviceType, String channelId)
        getChannelData,
    required TResult Function(
            String serviceType, String channelId, String? nextPage)
        getMoreChannelVideos,
  }) {
    return getChannelData(serviceType, channelId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String serviceType, String channelId)? getChannelData,
    TResult? Function(String serviceType, String channelId, String? nextPage)?
        getMoreChannelVideos,
  }) {
    return getChannelData?.call(serviceType, channelId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String serviceType, String channelId)? getChannelData,
    TResult Function(String serviceType, String channelId, String? nextPage)?
        getMoreChannelVideos,
    required TResult orElse(),
  }) {
    if (getChannelData != null) {
      return getChannelData(serviceType, channelId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GetChannelData value) getChannelData,
    required TResult Function(GetMoreChannelVideos value) getMoreChannelVideos,
  }) {
    return getChannelData(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GetChannelData value)? getChannelData,
    TResult? Function(GetMoreChannelVideos value)? getMoreChannelVideos,
  }) {
    return getChannelData?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GetChannelData value)? getChannelData,
    TResult Function(GetMoreChannelVideos value)? getMoreChannelVideos,
    required TResult orElse(),
  }) {
    if (getChannelData != null) {
      return getChannelData(this);
    }
    return orElse();
  }
}

abstract class GetChannelData implements ChannelEvent {
  const factory GetChannelData(
      {required final String serviceType,
      required final String channelId}) = _$GetChannelDataImpl;

  @override
  String get serviceType;
  @override
  String get channelId;

  /// Create a copy of ChannelEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GetChannelDataImplCopyWith<_$GetChannelDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GetMoreChannelVideosImplCopyWith<$Res>
    implements $ChannelEventCopyWith<$Res> {
  factory _$$GetMoreChannelVideosImplCopyWith(_$GetMoreChannelVideosImpl value,
          $Res Function(_$GetMoreChannelVideosImpl) then) =
      __$$GetMoreChannelVideosImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String serviceType, String channelId, String? nextPage});
}

/// @nodoc
class __$$GetMoreChannelVideosImplCopyWithImpl<$Res>
    extends _$ChannelEventCopyWithImpl<$Res, _$GetMoreChannelVideosImpl>
    implements _$$GetMoreChannelVideosImplCopyWith<$Res> {
  __$$GetMoreChannelVideosImplCopyWithImpl(_$GetMoreChannelVideosImpl _value,
      $Res Function(_$GetMoreChannelVideosImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChannelEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? serviceType = null,
    Object? channelId = null,
    Object? nextPage = freezed,
  }) {
    return _then(_$GetMoreChannelVideosImpl(
      serviceType: null == serviceType
          ? _value.serviceType
          : serviceType // ignore: cast_nullable_to_non_nullable
              as String,
      channelId: null == channelId
          ? _value.channelId
          : channelId // ignore: cast_nullable_to_non_nullable
              as String,
      nextPage: freezed == nextPage
          ? _value.nextPage
          : nextPage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$GetMoreChannelVideosImpl implements GetMoreChannelVideos {
  const _$GetMoreChannelVideosImpl(
      {required this.serviceType,
      required this.channelId,
      required this.nextPage});

  @override
  final String serviceType;
  @override
  final String channelId;
  @override
  final String? nextPage;

  @override
  String toString() {
    return 'ChannelEvent.getMoreChannelVideos(serviceType: $serviceType, channelId: $channelId, nextPage: $nextPage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetMoreChannelVideosImpl &&
            (identical(other.serviceType, serviceType) ||
                other.serviceType == serviceType) &&
            (identical(other.channelId, channelId) ||
                other.channelId == channelId) &&
            (identical(other.nextPage, nextPage) ||
                other.nextPage == nextPage));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, serviceType, channelId, nextPage);

  /// Create a copy of ChannelEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GetMoreChannelVideosImplCopyWith<_$GetMoreChannelVideosImpl>
      get copyWith =>
          __$$GetMoreChannelVideosImplCopyWithImpl<_$GetMoreChannelVideosImpl>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String serviceType, String channelId)
        getChannelData,
    required TResult Function(
            String serviceType, String channelId, String? nextPage)
        getMoreChannelVideos,
  }) {
    return getMoreChannelVideos(serviceType, channelId, nextPage);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String serviceType, String channelId)? getChannelData,
    TResult? Function(String serviceType, String channelId, String? nextPage)?
        getMoreChannelVideos,
  }) {
    return getMoreChannelVideos?.call(serviceType, channelId, nextPage);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String serviceType, String channelId)? getChannelData,
    TResult Function(String serviceType, String channelId, String? nextPage)?
        getMoreChannelVideos,
    required TResult orElse(),
  }) {
    if (getMoreChannelVideos != null) {
      return getMoreChannelVideos(serviceType, channelId, nextPage);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GetChannelData value) getChannelData,
    required TResult Function(GetMoreChannelVideos value) getMoreChannelVideos,
  }) {
    return getMoreChannelVideos(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GetChannelData value)? getChannelData,
    TResult? Function(GetMoreChannelVideos value)? getMoreChannelVideos,
  }) {
    return getMoreChannelVideos?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GetChannelData value)? getChannelData,
    TResult Function(GetMoreChannelVideos value)? getMoreChannelVideos,
    required TResult orElse(),
  }) {
    if (getMoreChannelVideos != null) {
      return getMoreChannelVideos(this);
    }
    return orElse();
  }
}

abstract class GetMoreChannelVideos implements ChannelEvent {
  const factory GetMoreChannelVideos(
      {required final String serviceType,
      required final String channelId,
      required final String? nextPage}) = _$GetMoreChannelVideosImpl;

  @override
  String get serviceType;
  @override
  String get channelId;
  String? get nextPage;

  /// Create a copy of ChannelEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GetMoreChannelVideosImplCopyWith<_$GetMoreChannelVideosImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ChannelState {
//
  bool get isMoreFetchCompleted => throw _privateConstructorUsedError; // PIPED
  ApiStatus get channelDetailsFetchStatus => throw _privateConstructorUsedError;
  ChannelResp? get pipedChannelResp => throw _privateConstructorUsedError;
  ApiStatus get moreChannelDetailsFetchStatus =>
      throw _privateConstructorUsedError; // INVIDIOUS
  InvidiousChannelResp? get invidiousChannelResp =>
      throw _privateConstructorUsedError;

  /// Create a copy of ChannelState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChannelStateCopyWith<ChannelState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChannelStateCopyWith<$Res> {
  factory $ChannelStateCopyWith(
          ChannelState value, $Res Function(ChannelState) then) =
      _$ChannelStateCopyWithImpl<$Res, ChannelState>;
  @useResult
  $Res call(
      {bool isMoreFetchCompleted,
      ApiStatus channelDetailsFetchStatus,
      ChannelResp? pipedChannelResp,
      ApiStatus moreChannelDetailsFetchStatus,
      InvidiousChannelResp? invidiousChannelResp});
}

/// @nodoc
class _$ChannelStateCopyWithImpl<$Res, $Val extends ChannelState>
    implements $ChannelStateCopyWith<$Res> {
  _$ChannelStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChannelState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isMoreFetchCompleted = null,
    Object? channelDetailsFetchStatus = null,
    Object? pipedChannelResp = freezed,
    Object? moreChannelDetailsFetchStatus = null,
    Object? invidiousChannelResp = freezed,
  }) {
    return _then(_value.copyWith(
      isMoreFetchCompleted: null == isMoreFetchCompleted
          ? _value.isMoreFetchCompleted
          : isMoreFetchCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      channelDetailsFetchStatus: null == channelDetailsFetchStatus
          ? _value.channelDetailsFetchStatus
          : channelDetailsFetchStatus // ignore: cast_nullable_to_non_nullable
              as ApiStatus,
      pipedChannelResp: freezed == pipedChannelResp
          ? _value.pipedChannelResp
          : pipedChannelResp // ignore: cast_nullable_to_non_nullable
              as ChannelResp?,
      moreChannelDetailsFetchStatus: null == moreChannelDetailsFetchStatus
          ? _value.moreChannelDetailsFetchStatus
          : moreChannelDetailsFetchStatus // ignore: cast_nullable_to_non_nullable
              as ApiStatus,
      invidiousChannelResp: freezed == invidiousChannelResp
          ? _value.invidiousChannelResp
          : invidiousChannelResp // ignore: cast_nullable_to_non_nullable
              as InvidiousChannelResp?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChannelStateImplCopyWith<$Res>
    implements $ChannelStateCopyWith<$Res> {
  factory _$$ChannelStateImplCopyWith(
          _$ChannelStateImpl value, $Res Function(_$ChannelStateImpl) then) =
      __$$ChannelStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isMoreFetchCompleted,
      ApiStatus channelDetailsFetchStatus,
      ChannelResp? pipedChannelResp,
      ApiStatus moreChannelDetailsFetchStatus,
      InvidiousChannelResp? invidiousChannelResp});
}

/// @nodoc
class __$$ChannelStateImplCopyWithImpl<$Res>
    extends _$ChannelStateCopyWithImpl<$Res, _$ChannelStateImpl>
    implements _$$ChannelStateImplCopyWith<$Res> {
  __$$ChannelStateImplCopyWithImpl(
      _$ChannelStateImpl _value, $Res Function(_$ChannelStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChannelState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isMoreFetchCompleted = null,
    Object? channelDetailsFetchStatus = null,
    Object? pipedChannelResp = freezed,
    Object? moreChannelDetailsFetchStatus = null,
    Object? invidiousChannelResp = freezed,
  }) {
    return _then(_$ChannelStateImpl(
      isMoreFetchCompleted: null == isMoreFetchCompleted
          ? _value.isMoreFetchCompleted
          : isMoreFetchCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      channelDetailsFetchStatus: null == channelDetailsFetchStatus
          ? _value.channelDetailsFetchStatus
          : channelDetailsFetchStatus // ignore: cast_nullable_to_non_nullable
              as ApiStatus,
      pipedChannelResp: freezed == pipedChannelResp
          ? _value.pipedChannelResp
          : pipedChannelResp // ignore: cast_nullable_to_non_nullable
              as ChannelResp?,
      moreChannelDetailsFetchStatus: null == moreChannelDetailsFetchStatus
          ? _value.moreChannelDetailsFetchStatus
          : moreChannelDetailsFetchStatus // ignore: cast_nullable_to_non_nullable
              as ApiStatus,
      invidiousChannelResp: freezed == invidiousChannelResp
          ? _value.invidiousChannelResp
          : invidiousChannelResp // ignore: cast_nullable_to_non_nullable
              as InvidiousChannelResp?,
    ));
  }
}

/// @nodoc

class _$ChannelStateImpl implements _ChannelState {
  _$ChannelStateImpl(
      {required this.isMoreFetchCompleted,
      required this.channelDetailsFetchStatus,
      required this.pipedChannelResp,
      required this.moreChannelDetailsFetchStatus,
      required this.invidiousChannelResp});

//
  @override
  final bool isMoreFetchCompleted;
// PIPED
  @override
  final ApiStatus channelDetailsFetchStatus;
  @override
  final ChannelResp? pipedChannelResp;
  @override
  final ApiStatus moreChannelDetailsFetchStatus;
// INVIDIOUS
  @override
  final InvidiousChannelResp? invidiousChannelResp;

  @override
  String toString() {
    return 'ChannelState(isMoreFetchCompleted: $isMoreFetchCompleted, channelDetailsFetchStatus: $channelDetailsFetchStatus, pipedChannelResp: $pipedChannelResp, moreChannelDetailsFetchStatus: $moreChannelDetailsFetchStatus, invidiousChannelResp: $invidiousChannelResp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChannelStateImpl &&
            (identical(other.isMoreFetchCompleted, isMoreFetchCompleted) ||
                other.isMoreFetchCompleted == isMoreFetchCompleted) &&
            (identical(other.channelDetailsFetchStatus,
                    channelDetailsFetchStatus) ||
                other.channelDetailsFetchStatus == channelDetailsFetchStatus) &&
            (identical(other.pipedChannelResp, pipedChannelResp) ||
                other.pipedChannelResp == pipedChannelResp) &&
            (identical(other.moreChannelDetailsFetchStatus,
                    moreChannelDetailsFetchStatus) ||
                other.moreChannelDetailsFetchStatus ==
                    moreChannelDetailsFetchStatus) &&
            (identical(other.invidiousChannelResp, invidiousChannelResp) ||
                other.invidiousChannelResp == invidiousChannelResp));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isMoreFetchCompleted,
      channelDetailsFetchStatus,
      pipedChannelResp,
      moreChannelDetailsFetchStatus,
      invidiousChannelResp);

  /// Create a copy of ChannelState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChannelStateImplCopyWith<_$ChannelStateImpl> get copyWith =>
      __$$ChannelStateImplCopyWithImpl<_$ChannelStateImpl>(this, _$identity);
}

abstract class _ChannelState implements ChannelState {
  factory _ChannelState(
          {required final bool isMoreFetchCompleted,
          required final ApiStatus channelDetailsFetchStatus,
          required final ChannelResp? pipedChannelResp,
          required final ApiStatus moreChannelDetailsFetchStatus,
          required final InvidiousChannelResp? invidiousChannelResp}) =
      _$ChannelStateImpl;

//
  @override
  bool get isMoreFetchCompleted; // PIPED
  @override
  ApiStatus get channelDetailsFetchStatus;
  @override
  ChannelResp? get pipedChannelResp;
  @override
  ApiStatus get moreChannelDetailsFetchStatus; // INVIDIOUS
  @override
  InvidiousChannelResp? get invidiousChannelResp;

  /// Create a copy of ChannelState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChannelStateImplCopyWith<_$ChannelStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
