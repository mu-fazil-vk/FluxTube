// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'watch_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$WatchEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String id) getWatchInfo,
    required TResult Function(String id) getCommentData,
    required TResult Function(String id, String nextPage) getCommentRepliesData,
    required TResult Function() tapDescription,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String id)? getWatchInfo,
    TResult? Function(String id)? getCommentData,
    TResult? Function(String id, String nextPage)? getCommentRepliesData,
    TResult? Function()? tapDescription,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String id)? getWatchInfo,
    TResult Function(String id)? getCommentData,
    TResult Function(String id, String nextPage)? getCommentRepliesData,
    TResult Function()? tapDescription,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GetWatchInfo value) getWatchInfo,
    required TResult Function(GetCommentData value) getCommentData,
    required TResult Function(GetCommentRepliesData value)
        getCommentRepliesData,
    required TResult Function(TapDescription value) tapDescription,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GetWatchInfo value)? getWatchInfo,
    TResult? Function(GetCommentData value)? getCommentData,
    TResult? Function(GetCommentRepliesData value)? getCommentRepliesData,
    TResult? Function(TapDescription value)? tapDescription,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GetWatchInfo value)? getWatchInfo,
    TResult Function(GetCommentData value)? getCommentData,
    TResult Function(GetCommentRepliesData value)? getCommentRepliesData,
    TResult Function(TapDescription value)? tapDescription,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WatchEventCopyWith<$Res> {
  factory $WatchEventCopyWith(
          WatchEvent value, $Res Function(WatchEvent) then) =
      _$WatchEventCopyWithImpl<$Res, WatchEvent>;
}

/// @nodoc
class _$WatchEventCopyWithImpl<$Res, $Val extends WatchEvent>
    implements $WatchEventCopyWith<$Res> {
  _$WatchEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$GetWatchInfoImplCopyWith<$Res> {
  factory _$$GetWatchInfoImplCopyWith(
          _$GetWatchInfoImpl value, $Res Function(_$GetWatchInfoImpl) then) =
      __$$GetWatchInfoImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String id});
}

/// @nodoc
class __$$GetWatchInfoImplCopyWithImpl<$Res>
    extends _$WatchEventCopyWithImpl<$Res, _$GetWatchInfoImpl>
    implements _$$GetWatchInfoImplCopyWith<$Res> {
  __$$GetWatchInfoImplCopyWithImpl(
      _$GetWatchInfoImpl _value, $Res Function(_$GetWatchInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
  }) {
    return _then(_$GetWatchInfoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$GetWatchInfoImpl implements GetWatchInfo {
  _$GetWatchInfoImpl({required this.id});

  @override
  final String id;

  @override
  String toString() {
    return 'WatchEvent.getWatchInfo(id: $id)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetWatchInfoImpl &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetWatchInfoImplCopyWith<_$GetWatchInfoImpl> get copyWith =>
      __$$GetWatchInfoImplCopyWithImpl<_$GetWatchInfoImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String id) getWatchInfo,
    required TResult Function(String id) getCommentData,
    required TResult Function(String id, String nextPage) getCommentRepliesData,
    required TResult Function() tapDescription,
  }) {
    return getWatchInfo(id);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String id)? getWatchInfo,
    TResult? Function(String id)? getCommentData,
    TResult? Function(String id, String nextPage)? getCommentRepliesData,
    TResult? Function()? tapDescription,
  }) {
    return getWatchInfo?.call(id);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String id)? getWatchInfo,
    TResult Function(String id)? getCommentData,
    TResult Function(String id, String nextPage)? getCommentRepliesData,
    TResult Function()? tapDescription,
    required TResult orElse(),
  }) {
    if (getWatchInfo != null) {
      return getWatchInfo(id);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GetWatchInfo value) getWatchInfo,
    required TResult Function(GetCommentData value) getCommentData,
    required TResult Function(GetCommentRepliesData value)
        getCommentRepliesData,
    required TResult Function(TapDescription value) tapDescription,
  }) {
    return getWatchInfo(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GetWatchInfo value)? getWatchInfo,
    TResult? Function(GetCommentData value)? getCommentData,
    TResult? Function(GetCommentRepliesData value)? getCommentRepliesData,
    TResult? Function(TapDescription value)? tapDescription,
  }) {
    return getWatchInfo?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GetWatchInfo value)? getWatchInfo,
    TResult Function(GetCommentData value)? getCommentData,
    TResult Function(GetCommentRepliesData value)? getCommentRepliesData,
    TResult Function(TapDescription value)? tapDescription,
    required TResult orElse(),
  }) {
    if (getWatchInfo != null) {
      return getWatchInfo(this);
    }
    return orElse();
  }
}

abstract class GetWatchInfo implements WatchEvent {
  factory GetWatchInfo({required final String id}) = _$GetWatchInfoImpl;

  String get id;
  @JsonKey(ignore: true)
  _$$GetWatchInfoImplCopyWith<_$GetWatchInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GetCommentDataImplCopyWith<$Res> {
  factory _$$GetCommentDataImplCopyWith(_$GetCommentDataImpl value,
          $Res Function(_$GetCommentDataImpl) then) =
      __$$GetCommentDataImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String id});
}

/// @nodoc
class __$$GetCommentDataImplCopyWithImpl<$Res>
    extends _$WatchEventCopyWithImpl<$Res, _$GetCommentDataImpl>
    implements _$$GetCommentDataImplCopyWith<$Res> {
  __$$GetCommentDataImplCopyWithImpl(
      _$GetCommentDataImpl _value, $Res Function(_$GetCommentDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
  }) {
    return _then(_$GetCommentDataImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$GetCommentDataImpl implements GetCommentData {
  _$GetCommentDataImpl({required this.id});

  @override
  final String id;

  @override
  String toString() {
    return 'WatchEvent.getCommentData(id: $id)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetCommentDataImpl &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetCommentDataImplCopyWith<_$GetCommentDataImpl> get copyWith =>
      __$$GetCommentDataImplCopyWithImpl<_$GetCommentDataImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String id) getWatchInfo,
    required TResult Function(String id) getCommentData,
    required TResult Function(String id, String nextPage) getCommentRepliesData,
    required TResult Function() tapDescription,
  }) {
    return getCommentData(id);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String id)? getWatchInfo,
    TResult? Function(String id)? getCommentData,
    TResult? Function(String id, String nextPage)? getCommentRepliesData,
    TResult? Function()? tapDescription,
  }) {
    return getCommentData?.call(id);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String id)? getWatchInfo,
    TResult Function(String id)? getCommentData,
    TResult Function(String id, String nextPage)? getCommentRepliesData,
    TResult Function()? tapDescription,
    required TResult orElse(),
  }) {
    if (getCommentData != null) {
      return getCommentData(id);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GetWatchInfo value) getWatchInfo,
    required TResult Function(GetCommentData value) getCommentData,
    required TResult Function(GetCommentRepliesData value)
        getCommentRepliesData,
    required TResult Function(TapDescription value) tapDescription,
  }) {
    return getCommentData(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GetWatchInfo value)? getWatchInfo,
    TResult? Function(GetCommentData value)? getCommentData,
    TResult? Function(GetCommentRepliesData value)? getCommentRepliesData,
    TResult? Function(TapDescription value)? tapDescription,
  }) {
    return getCommentData?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GetWatchInfo value)? getWatchInfo,
    TResult Function(GetCommentData value)? getCommentData,
    TResult Function(GetCommentRepliesData value)? getCommentRepliesData,
    TResult Function(TapDescription value)? tapDescription,
    required TResult orElse(),
  }) {
    if (getCommentData != null) {
      return getCommentData(this);
    }
    return orElse();
  }
}

abstract class GetCommentData implements WatchEvent {
  factory GetCommentData({required final String id}) = _$GetCommentDataImpl;

  String get id;
  @JsonKey(ignore: true)
  _$$GetCommentDataImplCopyWith<_$GetCommentDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GetCommentRepliesDataImplCopyWith<$Res> {
  factory _$$GetCommentRepliesDataImplCopyWith(
          _$GetCommentRepliesDataImpl value,
          $Res Function(_$GetCommentRepliesDataImpl) then) =
      __$$GetCommentRepliesDataImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String id, String nextPage});
}

/// @nodoc
class __$$GetCommentRepliesDataImplCopyWithImpl<$Res>
    extends _$WatchEventCopyWithImpl<$Res, _$GetCommentRepliesDataImpl>
    implements _$$GetCommentRepliesDataImplCopyWith<$Res> {
  __$$GetCommentRepliesDataImplCopyWithImpl(_$GetCommentRepliesDataImpl _value,
      $Res Function(_$GetCommentRepliesDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nextPage = null,
  }) {
    return _then(_$GetCommentRepliesDataImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nextPage: null == nextPage
          ? _value.nextPage
          : nextPage // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$GetCommentRepliesDataImpl implements GetCommentRepliesData {
  _$GetCommentRepliesDataImpl({required this.id, required this.nextPage});

  @override
  final String id;
  @override
  final String nextPage;

  @override
  String toString() {
    return 'WatchEvent.getCommentRepliesData(id: $id, nextPage: $nextPage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetCommentRepliesDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nextPage, nextPage) ||
                other.nextPage == nextPage));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, nextPage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetCommentRepliesDataImplCopyWith<_$GetCommentRepliesDataImpl>
      get copyWith => __$$GetCommentRepliesDataImplCopyWithImpl<
          _$GetCommentRepliesDataImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String id) getWatchInfo,
    required TResult Function(String id) getCommentData,
    required TResult Function(String id, String nextPage) getCommentRepliesData,
    required TResult Function() tapDescription,
  }) {
    return getCommentRepliesData(id, nextPage);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String id)? getWatchInfo,
    TResult? Function(String id)? getCommentData,
    TResult? Function(String id, String nextPage)? getCommentRepliesData,
    TResult? Function()? tapDescription,
  }) {
    return getCommentRepliesData?.call(id, nextPage);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String id)? getWatchInfo,
    TResult Function(String id)? getCommentData,
    TResult Function(String id, String nextPage)? getCommentRepliesData,
    TResult Function()? tapDescription,
    required TResult orElse(),
  }) {
    if (getCommentRepliesData != null) {
      return getCommentRepliesData(id, nextPage);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GetWatchInfo value) getWatchInfo,
    required TResult Function(GetCommentData value) getCommentData,
    required TResult Function(GetCommentRepliesData value)
        getCommentRepliesData,
    required TResult Function(TapDescription value) tapDescription,
  }) {
    return getCommentRepliesData(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GetWatchInfo value)? getWatchInfo,
    TResult? Function(GetCommentData value)? getCommentData,
    TResult? Function(GetCommentRepliesData value)? getCommentRepliesData,
    TResult? Function(TapDescription value)? tapDescription,
  }) {
    return getCommentRepliesData?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GetWatchInfo value)? getWatchInfo,
    TResult Function(GetCommentData value)? getCommentData,
    TResult Function(GetCommentRepliesData value)? getCommentRepliesData,
    TResult Function(TapDescription value)? tapDescription,
    required TResult orElse(),
  }) {
    if (getCommentRepliesData != null) {
      return getCommentRepliesData(this);
    }
    return orElse();
  }
}

abstract class GetCommentRepliesData implements WatchEvent {
  factory GetCommentRepliesData(
      {required final String id,
      required final String nextPage}) = _$GetCommentRepliesDataImpl;

  String get id;
  String get nextPage;
  @JsonKey(ignore: true)
  _$$GetCommentRepliesDataImplCopyWith<_$GetCommentRepliesDataImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TapDescriptionImplCopyWith<$Res> {
  factory _$$TapDescriptionImplCopyWith(_$TapDescriptionImpl value,
          $Res Function(_$TapDescriptionImpl) then) =
      __$$TapDescriptionImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$TapDescriptionImplCopyWithImpl<$Res>
    extends _$WatchEventCopyWithImpl<$Res, _$TapDescriptionImpl>
    implements _$$TapDescriptionImplCopyWith<$Res> {
  __$$TapDescriptionImplCopyWithImpl(
      _$TapDescriptionImpl _value, $Res Function(_$TapDescriptionImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$TapDescriptionImpl implements TapDescription {
  _$TapDescriptionImpl();

  @override
  String toString() {
    return 'WatchEvent.tapDescription()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$TapDescriptionImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String id) getWatchInfo,
    required TResult Function(String id) getCommentData,
    required TResult Function(String id, String nextPage) getCommentRepliesData,
    required TResult Function() tapDescription,
  }) {
    return tapDescription();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String id)? getWatchInfo,
    TResult? Function(String id)? getCommentData,
    TResult? Function(String id, String nextPage)? getCommentRepliesData,
    TResult? Function()? tapDescription,
  }) {
    return tapDescription?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String id)? getWatchInfo,
    TResult Function(String id)? getCommentData,
    TResult Function(String id, String nextPage)? getCommentRepliesData,
    TResult Function()? tapDescription,
    required TResult orElse(),
  }) {
    if (tapDescription != null) {
      return tapDescription();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GetWatchInfo value) getWatchInfo,
    required TResult Function(GetCommentData value) getCommentData,
    required TResult Function(GetCommentRepliesData value)
        getCommentRepliesData,
    required TResult Function(TapDescription value) tapDescription,
  }) {
    return tapDescription(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GetWatchInfo value)? getWatchInfo,
    TResult? Function(GetCommentData value)? getCommentData,
    TResult? Function(GetCommentRepliesData value)? getCommentRepliesData,
    TResult? Function(TapDescription value)? tapDescription,
  }) {
    return tapDescription?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GetWatchInfo value)? getWatchInfo,
    TResult Function(GetCommentData value)? getCommentData,
    TResult Function(GetCommentRepliesData value)? getCommentRepliesData,
    TResult Function(TapDescription value)? tapDescription,
    required TResult orElse(),
  }) {
    if (tapDescription != null) {
      return tapDescription(this);
    }
    return orElse();
  }
}

abstract class TapDescription implements WatchEvent {
  factory TapDescription() = _$TapDescriptionImpl;
}

/// @nodoc
mixin _$WatchState {
  WatchResp get watchResp => throw _privateConstructorUsedError;
  CommentsResp get comments => throw _privateConstructorUsedError;
  CommentsResp get commentReplies => throw _privateConstructorUsedError;
  String? get oldId => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isWatchInfoError => throw _privateConstructorUsedError;
  bool get initialVideoPause => throw _privateConstructorUsedError;
  bool get isTapComments => throw _privateConstructorUsedError;
  bool get isCommentsLoading => throw _privateConstructorUsedError;
  bool get isCommentRepliesLoading => throw _privateConstructorUsedError;
  bool get isCommentError => throw _privateConstructorUsedError;
  bool get isCommentRepliesError => throw _privateConstructorUsedError;
  bool get isDescriptionTapped => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $WatchStateCopyWith<WatchState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WatchStateCopyWith<$Res> {
  factory $WatchStateCopyWith(
          WatchState value, $Res Function(WatchState) then) =
      _$WatchStateCopyWithImpl<$Res, WatchState>;
  @useResult
  $Res call(
      {WatchResp watchResp,
      CommentsResp comments,
      CommentsResp commentReplies,
      String? oldId,
      bool isLoading,
      bool isWatchInfoError,
      bool initialVideoPause,
      bool isTapComments,
      bool isCommentsLoading,
      bool isCommentRepliesLoading,
      bool isCommentError,
      bool isCommentRepliesError,
      bool isDescriptionTapped});
}

/// @nodoc
class _$WatchStateCopyWithImpl<$Res, $Val extends WatchState>
    implements $WatchStateCopyWith<$Res> {
  _$WatchStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? watchResp = null,
    Object? comments = null,
    Object? commentReplies = null,
    Object? oldId = freezed,
    Object? isLoading = null,
    Object? isWatchInfoError = null,
    Object? initialVideoPause = null,
    Object? isTapComments = null,
    Object? isCommentsLoading = null,
    Object? isCommentRepliesLoading = null,
    Object? isCommentError = null,
    Object? isCommentRepliesError = null,
    Object? isDescriptionTapped = null,
  }) {
    return _then(_value.copyWith(
      watchResp: null == watchResp
          ? _value.watchResp
          : watchResp // ignore: cast_nullable_to_non_nullable
              as WatchResp,
      comments: null == comments
          ? _value.comments
          : comments // ignore: cast_nullable_to_non_nullable
              as CommentsResp,
      commentReplies: null == commentReplies
          ? _value.commentReplies
          : commentReplies // ignore: cast_nullable_to_non_nullable
              as CommentsResp,
      oldId: freezed == oldId
          ? _value.oldId
          : oldId // ignore: cast_nullable_to_non_nullable
              as String?,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isWatchInfoError: null == isWatchInfoError
          ? _value.isWatchInfoError
          : isWatchInfoError // ignore: cast_nullable_to_non_nullable
              as bool,
      initialVideoPause: null == initialVideoPause
          ? _value.initialVideoPause
          : initialVideoPause // ignore: cast_nullable_to_non_nullable
              as bool,
      isTapComments: null == isTapComments
          ? _value.isTapComments
          : isTapComments // ignore: cast_nullable_to_non_nullable
              as bool,
      isCommentsLoading: null == isCommentsLoading
          ? _value.isCommentsLoading
          : isCommentsLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isCommentRepliesLoading: null == isCommentRepliesLoading
          ? _value.isCommentRepliesLoading
          : isCommentRepliesLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isCommentError: null == isCommentError
          ? _value.isCommentError
          : isCommentError // ignore: cast_nullable_to_non_nullable
              as bool,
      isCommentRepliesError: null == isCommentRepliesError
          ? _value.isCommentRepliesError
          : isCommentRepliesError // ignore: cast_nullable_to_non_nullable
              as bool,
      isDescriptionTapped: null == isDescriptionTapped
          ? _value.isDescriptionTapped
          : isDescriptionTapped // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InitialImplCopyWith<$Res>
    implements $WatchStateCopyWith<$Res> {
  factory _$$InitialImplCopyWith(
          _$InitialImpl value, $Res Function(_$InitialImpl) then) =
      __$$InitialImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {WatchResp watchResp,
      CommentsResp comments,
      CommentsResp commentReplies,
      String? oldId,
      bool isLoading,
      bool isWatchInfoError,
      bool initialVideoPause,
      bool isTapComments,
      bool isCommentsLoading,
      bool isCommentRepliesLoading,
      bool isCommentError,
      bool isCommentRepliesError,
      bool isDescriptionTapped});
}

/// @nodoc
class __$$InitialImplCopyWithImpl<$Res>
    extends _$WatchStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
      _$InitialImpl _value, $Res Function(_$InitialImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? watchResp = null,
    Object? comments = null,
    Object? commentReplies = null,
    Object? oldId = freezed,
    Object? isLoading = null,
    Object? isWatchInfoError = null,
    Object? initialVideoPause = null,
    Object? isTapComments = null,
    Object? isCommentsLoading = null,
    Object? isCommentRepliesLoading = null,
    Object? isCommentError = null,
    Object? isCommentRepliesError = null,
    Object? isDescriptionTapped = null,
  }) {
    return _then(_$InitialImpl(
      watchResp: null == watchResp
          ? _value.watchResp
          : watchResp // ignore: cast_nullable_to_non_nullable
              as WatchResp,
      comments: null == comments
          ? _value.comments
          : comments // ignore: cast_nullable_to_non_nullable
              as CommentsResp,
      commentReplies: null == commentReplies
          ? _value.commentReplies
          : commentReplies // ignore: cast_nullable_to_non_nullable
              as CommentsResp,
      oldId: freezed == oldId
          ? _value.oldId
          : oldId // ignore: cast_nullable_to_non_nullable
              as String?,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isWatchInfoError: null == isWatchInfoError
          ? _value.isWatchInfoError
          : isWatchInfoError // ignore: cast_nullable_to_non_nullable
              as bool,
      initialVideoPause: null == initialVideoPause
          ? _value.initialVideoPause
          : initialVideoPause // ignore: cast_nullable_to_non_nullable
              as bool,
      isTapComments: null == isTapComments
          ? _value.isTapComments
          : isTapComments // ignore: cast_nullable_to_non_nullable
              as bool,
      isCommentsLoading: null == isCommentsLoading
          ? _value.isCommentsLoading
          : isCommentsLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isCommentRepliesLoading: null == isCommentRepliesLoading
          ? _value.isCommentRepliesLoading
          : isCommentRepliesLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isCommentError: null == isCommentError
          ? _value.isCommentError
          : isCommentError // ignore: cast_nullable_to_non_nullable
              as bool,
      isCommentRepliesError: null == isCommentRepliesError
          ? _value.isCommentRepliesError
          : isCommentRepliesError // ignore: cast_nullable_to_non_nullable
              as bool,
      isDescriptionTapped: null == isDescriptionTapped
          ? _value.isDescriptionTapped
          : isDescriptionTapped // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl(
      {required this.watchResp,
      required this.comments,
      required this.commentReplies,
      this.oldId,
      required this.isLoading,
      required this.isWatchInfoError,
      required this.initialVideoPause,
      required this.isTapComments,
      required this.isCommentsLoading,
      required this.isCommentRepliesLoading,
      required this.isCommentError,
      required this.isCommentRepliesError,
      required this.isDescriptionTapped});

  @override
  final WatchResp watchResp;
  @override
  final CommentsResp comments;
  @override
  final CommentsResp commentReplies;
  @override
  final String? oldId;
  @override
  final bool isLoading;
  @override
  final bool isWatchInfoError;
  @override
  final bool initialVideoPause;
  @override
  final bool isTapComments;
  @override
  final bool isCommentsLoading;
  @override
  final bool isCommentRepliesLoading;
  @override
  final bool isCommentError;
  @override
  final bool isCommentRepliesError;
  @override
  final bool isDescriptionTapped;

  @override
  String toString() {
    return 'WatchState(watchResp: $watchResp, comments: $comments, commentReplies: $commentReplies, oldId: $oldId, isLoading: $isLoading, isWatchInfoError: $isWatchInfoError, initialVideoPause: $initialVideoPause, isTapComments: $isTapComments, isCommentsLoading: $isCommentsLoading, isCommentRepliesLoading: $isCommentRepliesLoading, isCommentError: $isCommentError, isCommentRepliesError: $isCommentRepliesError, isDescriptionTapped: $isDescriptionTapped)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InitialImpl &&
            (identical(other.watchResp, watchResp) ||
                other.watchResp == watchResp) &&
            (identical(other.comments, comments) ||
                other.comments == comments) &&
            (identical(other.commentReplies, commentReplies) ||
                other.commentReplies == commentReplies) &&
            (identical(other.oldId, oldId) || other.oldId == oldId) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isWatchInfoError, isWatchInfoError) ||
                other.isWatchInfoError == isWatchInfoError) &&
            (identical(other.initialVideoPause, initialVideoPause) ||
                other.initialVideoPause == initialVideoPause) &&
            (identical(other.isTapComments, isTapComments) ||
                other.isTapComments == isTapComments) &&
            (identical(other.isCommentsLoading, isCommentsLoading) ||
                other.isCommentsLoading == isCommentsLoading) &&
            (identical(
                    other.isCommentRepliesLoading, isCommentRepliesLoading) ||
                other.isCommentRepliesLoading == isCommentRepliesLoading) &&
            (identical(other.isCommentError, isCommentError) ||
                other.isCommentError == isCommentError) &&
            (identical(other.isCommentRepliesError, isCommentRepliesError) ||
                other.isCommentRepliesError == isCommentRepliesError) &&
            (identical(other.isDescriptionTapped, isDescriptionTapped) ||
                other.isDescriptionTapped == isDescriptionTapped));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      watchResp,
      comments,
      commentReplies,
      oldId,
      isLoading,
      isWatchInfoError,
      initialVideoPause,
      isTapComments,
      isCommentsLoading,
      isCommentRepliesLoading,
      isCommentError,
      isCommentRepliesError,
      isDescriptionTapped);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$InitialImplCopyWith<_$InitialImpl> get copyWith =>
      __$$InitialImplCopyWithImpl<_$InitialImpl>(this, _$identity);
}

abstract class _Initial implements WatchState {
  const factory _Initial(
      {required final WatchResp watchResp,
      required final CommentsResp comments,
      required final CommentsResp commentReplies,
      final String? oldId,
      required final bool isLoading,
      required final bool isWatchInfoError,
      required final bool initialVideoPause,
      required final bool isTapComments,
      required final bool isCommentsLoading,
      required final bool isCommentRepliesLoading,
      required final bool isCommentError,
      required final bool isCommentRepliesError,
      required final bool isDescriptionTapped}) = _$InitialImpl;

  @override
  WatchResp get watchResp;
  @override
  CommentsResp get comments;
  @override
  CommentsResp get commentReplies;
  @override
  String? get oldId;
  @override
  bool get isLoading;
  @override
  bool get isWatchInfoError;
  @override
  bool get initialVideoPause;
  @override
  bool get isTapComments;
  @override
  bool get isCommentsLoading;
  @override
  bool get isCommentRepliesLoading;
  @override
  bool get isCommentError;
  @override
  bool get isCommentRepliesError;
  @override
  bool get isDescriptionTapped;
  @override
  @JsonKey(ignore: true)
  _$$InitialImplCopyWith<_$InitialImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
