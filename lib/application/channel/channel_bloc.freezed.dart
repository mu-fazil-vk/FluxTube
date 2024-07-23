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
  String get channelId => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String channelId) getChannelData,
    required TResult Function(String channelId, String? nextPage)
        getMoreChannelVideos,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String channelId)? getChannelData,
    TResult? Function(String channelId, String? nextPage)? getMoreChannelVideos,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String channelId)? getChannelData,
    TResult Function(String channelId, String? nextPage)? getMoreChannelVideos,
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

  @JsonKey(ignore: true)
  $ChannelEventCopyWith<ChannelEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChannelEventCopyWith<$Res> {
  factory $ChannelEventCopyWith(
          ChannelEvent value, $Res Function(ChannelEvent) then) =
      _$ChannelEventCopyWithImpl<$Res, ChannelEvent>;
  @useResult
  $Res call({String channelId});
}

/// @nodoc
class _$ChannelEventCopyWithImpl<$Res, $Val extends ChannelEvent>
    implements $ChannelEventCopyWith<$Res> {
  _$ChannelEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? channelId = null,
  }) {
    return _then(_value.copyWith(
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
  $Res call({String channelId});
}

/// @nodoc
class __$$GetChannelDataImplCopyWithImpl<$Res>
    extends _$ChannelEventCopyWithImpl<$Res, _$GetChannelDataImpl>
    implements _$$GetChannelDataImplCopyWith<$Res> {
  __$$GetChannelDataImplCopyWithImpl(
      _$GetChannelDataImpl _value, $Res Function(_$GetChannelDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? channelId = null,
  }) {
    return _then(_$GetChannelDataImpl(
      channelId: null == channelId
          ? _value.channelId
          : channelId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$GetChannelDataImpl implements GetChannelData {
  const _$GetChannelDataImpl({required this.channelId});

  @override
  final String channelId;

  @override
  String toString() {
    return 'ChannelEvent.getChannelData(channelId: $channelId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetChannelDataImpl &&
            (identical(other.channelId, channelId) ||
                other.channelId == channelId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, channelId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetChannelDataImplCopyWith<_$GetChannelDataImpl> get copyWith =>
      __$$GetChannelDataImplCopyWithImpl<_$GetChannelDataImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String channelId) getChannelData,
    required TResult Function(String channelId, String? nextPage)
        getMoreChannelVideos,
  }) {
    return getChannelData(channelId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String channelId)? getChannelData,
    TResult? Function(String channelId, String? nextPage)? getMoreChannelVideos,
  }) {
    return getChannelData?.call(channelId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String channelId)? getChannelData,
    TResult Function(String channelId, String? nextPage)? getMoreChannelVideos,
    required TResult orElse(),
  }) {
    if (getChannelData != null) {
      return getChannelData(channelId);
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
  const factory GetChannelData({required final String channelId}) =
      _$GetChannelDataImpl;

  @override
  String get channelId;
  @override
  @JsonKey(ignore: true)
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
  $Res call({String channelId, String? nextPage});
}

/// @nodoc
class __$$GetMoreChannelVideosImplCopyWithImpl<$Res>
    extends _$ChannelEventCopyWithImpl<$Res, _$GetMoreChannelVideosImpl>
    implements _$$GetMoreChannelVideosImplCopyWith<$Res> {
  __$$GetMoreChannelVideosImplCopyWithImpl(_$GetMoreChannelVideosImpl _value,
      $Res Function(_$GetMoreChannelVideosImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? channelId = null,
    Object? nextPage = freezed,
  }) {
    return _then(_$GetMoreChannelVideosImpl(
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
      {required this.channelId, required this.nextPage});

  @override
  final String channelId;
  @override
  final String? nextPage;

  @override
  String toString() {
    return 'ChannelEvent.getMoreChannelVideos(channelId: $channelId, nextPage: $nextPage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetMoreChannelVideosImpl &&
            (identical(other.channelId, channelId) ||
                other.channelId == channelId) &&
            (identical(other.nextPage, nextPage) ||
                other.nextPage == nextPage));
  }

  @override
  int get hashCode => Object.hash(runtimeType, channelId, nextPage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetMoreChannelVideosImplCopyWith<_$GetMoreChannelVideosImpl>
      get copyWith =>
          __$$GetMoreChannelVideosImplCopyWithImpl<_$GetMoreChannelVideosImpl>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String channelId) getChannelData,
    required TResult Function(String channelId, String? nextPage)
        getMoreChannelVideos,
  }) {
    return getMoreChannelVideos(channelId, nextPage);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String channelId)? getChannelData,
    TResult? Function(String channelId, String? nextPage)? getMoreChannelVideos,
  }) {
    return getMoreChannelVideos?.call(channelId, nextPage);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String channelId)? getChannelData,
    TResult Function(String channelId, String? nextPage)? getMoreChannelVideos,
    required TResult orElse(),
  }) {
    if (getMoreChannelVideos != null) {
      return getMoreChannelVideos(channelId, nextPage);
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
      {required final String channelId,
      required final String? nextPage}) = _$GetMoreChannelVideosImpl;

  @override
  String get channelId;
  String? get nextPage;
  @override
  @JsonKey(ignore: true)
  _$$GetMoreChannelVideosImplCopyWith<_$GetMoreChannelVideosImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ChannelState {
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isError => throw _privateConstructorUsedError;
  ChannelResp? get result => throw _privateConstructorUsedError;
  bool get isMoreFetchLoading => throw _privateConstructorUsedError;
  bool get isMoreFetchError => throw _privateConstructorUsedError;
  bool get isMoreFetchCompleted => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
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
      {bool isLoading,
      bool isError,
      ChannelResp? result,
      bool isMoreFetchLoading,
      bool isMoreFetchError,
      bool isMoreFetchCompleted});
}

/// @nodoc
class _$ChannelStateCopyWithImpl<$Res, $Val extends ChannelState>
    implements $ChannelStateCopyWith<$Res> {
  _$ChannelStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isError = null,
    Object? result = freezed,
    Object? isMoreFetchLoading = null,
    Object? isMoreFetchError = null,
    Object? isMoreFetchCompleted = null,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isError: null == isError
          ? _value.isError
          : isError // ignore: cast_nullable_to_non_nullable
              as bool,
      result: freezed == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as ChannelResp?,
      isMoreFetchLoading: null == isMoreFetchLoading
          ? _value.isMoreFetchLoading
          : isMoreFetchLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isMoreFetchError: null == isMoreFetchError
          ? _value.isMoreFetchError
          : isMoreFetchError // ignore: cast_nullable_to_non_nullable
              as bool,
      isMoreFetchCompleted: null == isMoreFetchCompleted
          ? _value.isMoreFetchCompleted
          : isMoreFetchCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
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
      {bool isLoading,
      bool isError,
      ChannelResp? result,
      bool isMoreFetchLoading,
      bool isMoreFetchError,
      bool isMoreFetchCompleted});
}

/// @nodoc
class __$$ChannelStateImplCopyWithImpl<$Res>
    extends _$ChannelStateCopyWithImpl<$Res, _$ChannelStateImpl>
    implements _$$ChannelStateImplCopyWith<$Res> {
  __$$ChannelStateImplCopyWithImpl(
      _$ChannelStateImpl _value, $Res Function(_$ChannelStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isError = null,
    Object? result = freezed,
    Object? isMoreFetchLoading = null,
    Object? isMoreFetchError = null,
    Object? isMoreFetchCompleted = null,
  }) {
    return _then(_$ChannelStateImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isError: null == isError
          ? _value.isError
          : isError // ignore: cast_nullable_to_non_nullable
              as bool,
      result: freezed == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as ChannelResp?,
      isMoreFetchLoading: null == isMoreFetchLoading
          ? _value.isMoreFetchLoading
          : isMoreFetchLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isMoreFetchError: null == isMoreFetchError
          ? _value.isMoreFetchError
          : isMoreFetchError // ignore: cast_nullable_to_non_nullable
              as bool,
      isMoreFetchCompleted: null == isMoreFetchCompleted
          ? _value.isMoreFetchCompleted
          : isMoreFetchCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$ChannelStateImpl implements _ChannelState {
  _$ChannelStateImpl(
      {required this.isLoading,
      required this.isError,
      required this.result,
      required this.isMoreFetchLoading,
      required this.isMoreFetchError,
      required this.isMoreFetchCompleted});

  @override
  final bool isLoading;
  @override
  final bool isError;
  @override
  final ChannelResp? result;
  @override
  final bool isMoreFetchLoading;
  @override
  final bool isMoreFetchError;
  @override
  final bool isMoreFetchCompleted;

  @override
  String toString() {
    return 'ChannelState(isLoading: $isLoading, isError: $isError, result: $result, isMoreFetchLoading: $isMoreFetchLoading, isMoreFetchError: $isMoreFetchError, isMoreFetchCompleted: $isMoreFetchCompleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChannelStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isError, isError) || other.isError == isError) &&
            (identical(other.result, result) || other.result == result) &&
            (identical(other.isMoreFetchLoading, isMoreFetchLoading) ||
                other.isMoreFetchLoading == isMoreFetchLoading) &&
            (identical(other.isMoreFetchError, isMoreFetchError) ||
                other.isMoreFetchError == isMoreFetchError) &&
            (identical(other.isMoreFetchCompleted, isMoreFetchCompleted) ||
                other.isMoreFetchCompleted == isMoreFetchCompleted));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isLoading, isError, result,
      isMoreFetchLoading, isMoreFetchError, isMoreFetchCompleted);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ChannelStateImplCopyWith<_$ChannelStateImpl> get copyWith =>
      __$$ChannelStateImplCopyWithImpl<_$ChannelStateImpl>(this, _$identity);
}

abstract class _ChannelState implements ChannelState {
  factory _ChannelState(
      {required final bool isLoading,
      required final bool isError,
      required final ChannelResp? result,
      required final bool isMoreFetchLoading,
      required final bool isMoreFetchError,
      required final bool isMoreFetchCompleted}) = _$ChannelStateImpl;

  @override
  bool get isLoading;
  @override
  bool get isError;
  @override
  ChannelResp? get result;
  @override
  bool get isMoreFetchLoading;
  @override
  bool get isMoreFetchError;
  @override
  bool get isMoreFetchCompleted;
  @override
  @JsonKey(ignore: true)
  _$$ChannelStateImplCopyWith<_$ChannelStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
