// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscribe_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SubscribeEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Subscribe channelInfo) addSubscribe,
    required TResult Function(String id) deleteSubscribeInfo,
    required TResult Function() getAllSubscribeList,
    required TResult Function(String id) checkSubscribeInfo,
    required TResult Function(List<Subscribe> subscribedChannels)
        updateSubscribeOldList,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Subscribe channelInfo)? addSubscribe,
    TResult? Function(String id)? deleteSubscribeInfo,
    TResult? Function()? getAllSubscribeList,
    TResult? Function(String id)? checkSubscribeInfo,
    TResult? Function(List<Subscribe> subscribedChannels)?
        updateSubscribeOldList,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Subscribe channelInfo)? addSubscribe,
    TResult Function(String id)? deleteSubscribeInfo,
    TResult Function()? getAllSubscribeList,
    TResult Function(String id)? checkSubscribeInfo,
    TResult Function(List<Subscribe> subscribedChannels)?
        updateSubscribeOldList,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AddSubscribe value) addSubscribe,
    required TResult Function(DeleteSubscribeInfo value) deleteSubscribeInfo,
    required TResult Function(GetAllSubscribeList value) getAllSubscribeList,
    required TResult Function(CheckSubscribeInfo value) checkSubscribeInfo,
    required TResult Function(UpdateSubscribeOldList value)
        updateSubscribeOldList,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AddSubscribe value)? addSubscribe,
    TResult? Function(DeleteSubscribeInfo value)? deleteSubscribeInfo,
    TResult? Function(GetAllSubscribeList value)? getAllSubscribeList,
    TResult? Function(CheckSubscribeInfo value)? checkSubscribeInfo,
    TResult? Function(UpdateSubscribeOldList value)? updateSubscribeOldList,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AddSubscribe value)? addSubscribe,
    TResult Function(DeleteSubscribeInfo value)? deleteSubscribeInfo,
    TResult Function(GetAllSubscribeList value)? getAllSubscribeList,
    TResult Function(CheckSubscribeInfo value)? checkSubscribeInfo,
    TResult Function(UpdateSubscribeOldList value)? updateSubscribeOldList,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscribeEventCopyWith<$Res> {
  factory $SubscribeEventCopyWith(
          SubscribeEvent value, $Res Function(SubscribeEvent) then) =
      _$SubscribeEventCopyWithImpl<$Res, SubscribeEvent>;
}

/// @nodoc
class _$SubscribeEventCopyWithImpl<$Res, $Val extends SubscribeEvent>
    implements $SubscribeEventCopyWith<$Res> {
  _$SubscribeEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$AddSubscribeImplCopyWith<$Res> {
  factory _$$AddSubscribeImplCopyWith(
          _$AddSubscribeImpl value, $Res Function(_$AddSubscribeImpl) then) =
      __$$AddSubscribeImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Subscribe channelInfo});
}

/// @nodoc
class __$$AddSubscribeImplCopyWithImpl<$Res>
    extends _$SubscribeEventCopyWithImpl<$Res, _$AddSubscribeImpl>
    implements _$$AddSubscribeImplCopyWith<$Res> {
  __$$AddSubscribeImplCopyWithImpl(
      _$AddSubscribeImpl _value, $Res Function(_$AddSubscribeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? channelInfo = null,
  }) {
    return _then(_$AddSubscribeImpl(
      channelInfo: null == channelInfo
          ? _value.channelInfo
          : channelInfo // ignore: cast_nullable_to_non_nullable
              as Subscribe,
    ));
  }
}

/// @nodoc

class _$AddSubscribeImpl implements AddSubscribe {
  const _$AddSubscribeImpl({required this.channelInfo});

  @override
  final Subscribe channelInfo;

  @override
  String toString() {
    return 'SubscribeEvent.addSubscribe(channelInfo: $channelInfo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddSubscribeImpl &&
            (identical(other.channelInfo, channelInfo) ||
                other.channelInfo == channelInfo));
  }

  @override
  int get hashCode => Object.hash(runtimeType, channelInfo);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AddSubscribeImplCopyWith<_$AddSubscribeImpl> get copyWith =>
      __$$AddSubscribeImplCopyWithImpl<_$AddSubscribeImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Subscribe channelInfo) addSubscribe,
    required TResult Function(String id) deleteSubscribeInfo,
    required TResult Function() getAllSubscribeList,
    required TResult Function(String id) checkSubscribeInfo,
    required TResult Function(List<Subscribe> subscribedChannels)
        updateSubscribeOldList,
  }) {
    return addSubscribe(channelInfo);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Subscribe channelInfo)? addSubscribe,
    TResult? Function(String id)? deleteSubscribeInfo,
    TResult? Function()? getAllSubscribeList,
    TResult? Function(String id)? checkSubscribeInfo,
    TResult? Function(List<Subscribe> subscribedChannels)?
        updateSubscribeOldList,
  }) {
    return addSubscribe?.call(channelInfo);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Subscribe channelInfo)? addSubscribe,
    TResult Function(String id)? deleteSubscribeInfo,
    TResult Function()? getAllSubscribeList,
    TResult Function(String id)? checkSubscribeInfo,
    TResult Function(List<Subscribe> subscribedChannels)?
        updateSubscribeOldList,
    required TResult orElse(),
  }) {
    if (addSubscribe != null) {
      return addSubscribe(channelInfo);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AddSubscribe value) addSubscribe,
    required TResult Function(DeleteSubscribeInfo value) deleteSubscribeInfo,
    required TResult Function(GetAllSubscribeList value) getAllSubscribeList,
    required TResult Function(CheckSubscribeInfo value) checkSubscribeInfo,
    required TResult Function(UpdateSubscribeOldList value)
        updateSubscribeOldList,
  }) {
    return addSubscribe(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AddSubscribe value)? addSubscribe,
    TResult? Function(DeleteSubscribeInfo value)? deleteSubscribeInfo,
    TResult? Function(GetAllSubscribeList value)? getAllSubscribeList,
    TResult? Function(CheckSubscribeInfo value)? checkSubscribeInfo,
    TResult? Function(UpdateSubscribeOldList value)? updateSubscribeOldList,
  }) {
    return addSubscribe?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AddSubscribe value)? addSubscribe,
    TResult Function(DeleteSubscribeInfo value)? deleteSubscribeInfo,
    TResult Function(GetAllSubscribeList value)? getAllSubscribeList,
    TResult Function(CheckSubscribeInfo value)? checkSubscribeInfo,
    TResult Function(UpdateSubscribeOldList value)? updateSubscribeOldList,
    required TResult orElse(),
  }) {
    if (addSubscribe != null) {
      return addSubscribe(this);
    }
    return orElse();
  }
}

abstract class AddSubscribe implements SubscribeEvent {
  const factory AddSubscribe({required final Subscribe channelInfo}) =
      _$AddSubscribeImpl;

  Subscribe get channelInfo;
  @JsonKey(ignore: true)
  _$$AddSubscribeImplCopyWith<_$AddSubscribeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DeleteSubscribeInfoImplCopyWith<$Res> {
  factory _$$DeleteSubscribeInfoImplCopyWith(_$DeleteSubscribeInfoImpl value,
          $Res Function(_$DeleteSubscribeInfoImpl) then) =
      __$$DeleteSubscribeInfoImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String id});
}

/// @nodoc
class __$$DeleteSubscribeInfoImplCopyWithImpl<$Res>
    extends _$SubscribeEventCopyWithImpl<$Res, _$DeleteSubscribeInfoImpl>
    implements _$$DeleteSubscribeInfoImplCopyWith<$Res> {
  __$$DeleteSubscribeInfoImplCopyWithImpl(_$DeleteSubscribeInfoImpl _value,
      $Res Function(_$DeleteSubscribeInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
  }) {
    return _then(_$DeleteSubscribeInfoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$DeleteSubscribeInfoImpl implements DeleteSubscribeInfo {
  const _$DeleteSubscribeInfoImpl({required this.id});

  @override
  final String id;

  @override
  String toString() {
    return 'SubscribeEvent.deleteSubscribeInfo(id: $id)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeleteSubscribeInfoImpl &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DeleteSubscribeInfoImplCopyWith<_$DeleteSubscribeInfoImpl> get copyWith =>
      __$$DeleteSubscribeInfoImplCopyWithImpl<_$DeleteSubscribeInfoImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Subscribe channelInfo) addSubscribe,
    required TResult Function(String id) deleteSubscribeInfo,
    required TResult Function() getAllSubscribeList,
    required TResult Function(String id) checkSubscribeInfo,
    required TResult Function(List<Subscribe> subscribedChannels)
        updateSubscribeOldList,
  }) {
    return deleteSubscribeInfo(id);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Subscribe channelInfo)? addSubscribe,
    TResult? Function(String id)? deleteSubscribeInfo,
    TResult? Function()? getAllSubscribeList,
    TResult? Function(String id)? checkSubscribeInfo,
    TResult? Function(List<Subscribe> subscribedChannels)?
        updateSubscribeOldList,
  }) {
    return deleteSubscribeInfo?.call(id);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Subscribe channelInfo)? addSubscribe,
    TResult Function(String id)? deleteSubscribeInfo,
    TResult Function()? getAllSubscribeList,
    TResult Function(String id)? checkSubscribeInfo,
    TResult Function(List<Subscribe> subscribedChannels)?
        updateSubscribeOldList,
    required TResult orElse(),
  }) {
    if (deleteSubscribeInfo != null) {
      return deleteSubscribeInfo(id);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AddSubscribe value) addSubscribe,
    required TResult Function(DeleteSubscribeInfo value) deleteSubscribeInfo,
    required TResult Function(GetAllSubscribeList value) getAllSubscribeList,
    required TResult Function(CheckSubscribeInfo value) checkSubscribeInfo,
    required TResult Function(UpdateSubscribeOldList value)
        updateSubscribeOldList,
  }) {
    return deleteSubscribeInfo(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AddSubscribe value)? addSubscribe,
    TResult? Function(DeleteSubscribeInfo value)? deleteSubscribeInfo,
    TResult? Function(GetAllSubscribeList value)? getAllSubscribeList,
    TResult? Function(CheckSubscribeInfo value)? checkSubscribeInfo,
    TResult? Function(UpdateSubscribeOldList value)? updateSubscribeOldList,
  }) {
    return deleteSubscribeInfo?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AddSubscribe value)? addSubscribe,
    TResult Function(DeleteSubscribeInfo value)? deleteSubscribeInfo,
    TResult Function(GetAllSubscribeList value)? getAllSubscribeList,
    TResult Function(CheckSubscribeInfo value)? checkSubscribeInfo,
    TResult Function(UpdateSubscribeOldList value)? updateSubscribeOldList,
    required TResult orElse(),
  }) {
    if (deleteSubscribeInfo != null) {
      return deleteSubscribeInfo(this);
    }
    return orElse();
  }
}

abstract class DeleteSubscribeInfo implements SubscribeEvent {
  const factory DeleteSubscribeInfo({required final String id}) =
      _$DeleteSubscribeInfoImpl;

  String get id;
  @JsonKey(ignore: true)
  _$$DeleteSubscribeInfoImplCopyWith<_$DeleteSubscribeInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GetAllSubscribeListImplCopyWith<$Res> {
  factory _$$GetAllSubscribeListImplCopyWith(_$GetAllSubscribeListImpl value,
          $Res Function(_$GetAllSubscribeListImpl) then) =
      __$$GetAllSubscribeListImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$GetAllSubscribeListImplCopyWithImpl<$Res>
    extends _$SubscribeEventCopyWithImpl<$Res, _$GetAllSubscribeListImpl>
    implements _$$GetAllSubscribeListImplCopyWith<$Res> {
  __$$GetAllSubscribeListImplCopyWithImpl(_$GetAllSubscribeListImpl _value,
      $Res Function(_$GetAllSubscribeListImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$GetAllSubscribeListImpl implements GetAllSubscribeList {
  const _$GetAllSubscribeListImpl();

  @override
  String toString() {
    return 'SubscribeEvent.getAllSubscribeList()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetAllSubscribeListImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Subscribe channelInfo) addSubscribe,
    required TResult Function(String id) deleteSubscribeInfo,
    required TResult Function() getAllSubscribeList,
    required TResult Function(String id) checkSubscribeInfo,
    required TResult Function(List<Subscribe> subscribedChannels)
        updateSubscribeOldList,
  }) {
    return getAllSubscribeList();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Subscribe channelInfo)? addSubscribe,
    TResult? Function(String id)? deleteSubscribeInfo,
    TResult? Function()? getAllSubscribeList,
    TResult? Function(String id)? checkSubscribeInfo,
    TResult? Function(List<Subscribe> subscribedChannels)?
        updateSubscribeOldList,
  }) {
    return getAllSubscribeList?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Subscribe channelInfo)? addSubscribe,
    TResult Function(String id)? deleteSubscribeInfo,
    TResult Function()? getAllSubscribeList,
    TResult Function(String id)? checkSubscribeInfo,
    TResult Function(List<Subscribe> subscribedChannels)?
        updateSubscribeOldList,
    required TResult orElse(),
  }) {
    if (getAllSubscribeList != null) {
      return getAllSubscribeList();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AddSubscribe value) addSubscribe,
    required TResult Function(DeleteSubscribeInfo value) deleteSubscribeInfo,
    required TResult Function(GetAllSubscribeList value) getAllSubscribeList,
    required TResult Function(CheckSubscribeInfo value) checkSubscribeInfo,
    required TResult Function(UpdateSubscribeOldList value)
        updateSubscribeOldList,
  }) {
    return getAllSubscribeList(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AddSubscribe value)? addSubscribe,
    TResult? Function(DeleteSubscribeInfo value)? deleteSubscribeInfo,
    TResult? Function(GetAllSubscribeList value)? getAllSubscribeList,
    TResult? Function(CheckSubscribeInfo value)? checkSubscribeInfo,
    TResult? Function(UpdateSubscribeOldList value)? updateSubscribeOldList,
  }) {
    return getAllSubscribeList?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AddSubscribe value)? addSubscribe,
    TResult Function(DeleteSubscribeInfo value)? deleteSubscribeInfo,
    TResult Function(GetAllSubscribeList value)? getAllSubscribeList,
    TResult Function(CheckSubscribeInfo value)? checkSubscribeInfo,
    TResult Function(UpdateSubscribeOldList value)? updateSubscribeOldList,
    required TResult orElse(),
  }) {
    if (getAllSubscribeList != null) {
      return getAllSubscribeList(this);
    }
    return orElse();
  }
}

abstract class GetAllSubscribeList implements SubscribeEvent {
  const factory GetAllSubscribeList() = _$GetAllSubscribeListImpl;
}

/// @nodoc
abstract class _$$CheckSubscribeInfoImplCopyWith<$Res> {
  factory _$$CheckSubscribeInfoImplCopyWith(_$CheckSubscribeInfoImpl value,
          $Res Function(_$CheckSubscribeInfoImpl) then) =
      __$$CheckSubscribeInfoImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String id});
}

/// @nodoc
class __$$CheckSubscribeInfoImplCopyWithImpl<$Res>
    extends _$SubscribeEventCopyWithImpl<$Res, _$CheckSubscribeInfoImpl>
    implements _$$CheckSubscribeInfoImplCopyWith<$Res> {
  __$$CheckSubscribeInfoImplCopyWithImpl(_$CheckSubscribeInfoImpl _value,
      $Res Function(_$CheckSubscribeInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
  }) {
    return _then(_$CheckSubscribeInfoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$CheckSubscribeInfoImpl implements CheckSubscribeInfo {
  const _$CheckSubscribeInfoImpl({required this.id});

  @override
  final String id;

  @override
  String toString() {
    return 'SubscribeEvent.checkSubscribeInfo(id: $id)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CheckSubscribeInfoImpl &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CheckSubscribeInfoImplCopyWith<_$CheckSubscribeInfoImpl> get copyWith =>
      __$$CheckSubscribeInfoImplCopyWithImpl<_$CheckSubscribeInfoImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Subscribe channelInfo) addSubscribe,
    required TResult Function(String id) deleteSubscribeInfo,
    required TResult Function() getAllSubscribeList,
    required TResult Function(String id) checkSubscribeInfo,
    required TResult Function(List<Subscribe> subscribedChannels)
        updateSubscribeOldList,
  }) {
    return checkSubscribeInfo(id);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Subscribe channelInfo)? addSubscribe,
    TResult? Function(String id)? deleteSubscribeInfo,
    TResult? Function()? getAllSubscribeList,
    TResult? Function(String id)? checkSubscribeInfo,
    TResult? Function(List<Subscribe> subscribedChannels)?
        updateSubscribeOldList,
  }) {
    return checkSubscribeInfo?.call(id);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Subscribe channelInfo)? addSubscribe,
    TResult Function(String id)? deleteSubscribeInfo,
    TResult Function()? getAllSubscribeList,
    TResult Function(String id)? checkSubscribeInfo,
    TResult Function(List<Subscribe> subscribedChannels)?
        updateSubscribeOldList,
    required TResult orElse(),
  }) {
    if (checkSubscribeInfo != null) {
      return checkSubscribeInfo(id);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AddSubscribe value) addSubscribe,
    required TResult Function(DeleteSubscribeInfo value) deleteSubscribeInfo,
    required TResult Function(GetAllSubscribeList value) getAllSubscribeList,
    required TResult Function(CheckSubscribeInfo value) checkSubscribeInfo,
    required TResult Function(UpdateSubscribeOldList value)
        updateSubscribeOldList,
  }) {
    return checkSubscribeInfo(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AddSubscribe value)? addSubscribe,
    TResult? Function(DeleteSubscribeInfo value)? deleteSubscribeInfo,
    TResult? Function(GetAllSubscribeList value)? getAllSubscribeList,
    TResult? Function(CheckSubscribeInfo value)? checkSubscribeInfo,
    TResult? Function(UpdateSubscribeOldList value)? updateSubscribeOldList,
  }) {
    return checkSubscribeInfo?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AddSubscribe value)? addSubscribe,
    TResult Function(DeleteSubscribeInfo value)? deleteSubscribeInfo,
    TResult Function(GetAllSubscribeList value)? getAllSubscribeList,
    TResult Function(CheckSubscribeInfo value)? checkSubscribeInfo,
    TResult Function(UpdateSubscribeOldList value)? updateSubscribeOldList,
    required TResult orElse(),
  }) {
    if (checkSubscribeInfo != null) {
      return checkSubscribeInfo(this);
    }
    return orElse();
  }
}

abstract class CheckSubscribeInfo implements SubscribeEvent {
  const factory CheckSubscribeInfo({required final String id}) =
      _$CheckSubscribeInfoImpl;

  String get id;
  @JsonKey(ignore: true)
  _$$CheckSubscribeInfoImplCopyWith<_$CheckSubscribeInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UpdateSubscribeOldListImplCopyWith<$Res> {
  factory _$$UpdateSubscribeOldListImplCopyWith(
          _$UpdateSubscribeOldListImpl value,
          $Res Function(_$UpdateSubscribeOldListImpl) then) =
      __$$UpdateSubscribeOldListImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<Subscribe> subscribedChannels});
}

/// @nodoc
class __$$UpdateSubscribeOldListImplCopyWithImpl<$Res>
    extends _$SubscribeEventCopyWithImpl<$Res, _$UpdateSubscribeOldListImpl>
    implements _$$UpdateSubscribeOldListImplCopyWith<$Res> {
  __$$UpdateSubscribeOldListImplCopyWithImpl(
      _$UpdateSubscribeOldListImpl _value,
      $Res Function(_$UpdateSubscribeOldListImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subscribedChannels = null,
  }) {
    return _then(_$UpdateSubscribeOldListImpl(
      subscribedChannels: null == subscribedChannels
          ? _value._subscribedChannels
          : subscribedChannels // ignore: cast_nullable_to_non_nullable
              as List<Subscribe>,
    ));
  }
}

/// @nodoc

class _$UpdateSubscribeOldListImpl implements UpdateSubscribeOldList {
  const _$UpdateSubscribeOldListImpl(
      {required final List<Subscribe> subscribedChannels})
      : _subscribedChannels = subscribedChannels;

  final List<Subscribe> _subscribedChannels;
  @override
  List<Subscribe> get subscribedChannels {
    if (_subscribedChannels is EqualUnmodifiableListView)
      return _subscribedChannels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subscribedChannels);
  }

  @override
  String toString() {
    return 'SubscribeEvent.updateSubscribeOldList(subscribedChannels: $subscribedChannels)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateSubscribeOldListImpl &&
            const DeepCollectionEquality()
                .equals(other._subscribedChannels, _subscribedChannels));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_subscribedChannels));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateSubscribeOldListImplCopyWith<_$UpdateSubscribeOldListImpl>
      get copyWith => __$$UpdateSubscribeOldListImplCopyWithImpl<
          _$UpdateSubscribeOldListImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Subscribe channelInfo) addSubscribe,
    required TResult Function(String id) deleteSubscribeInfo,
    required TResult Function() getAllSubscribeList,
    required TResult Function(String id) checkSubscribeInfo,
    required TResult Function(List<Subscribe> subscribedChannels)
        updateSubscribeOldList,
  }) {
    return updateSubscribeOldList(subscribedChannels);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Subscribe channelInfo)? addSubscribe,
    TResult? Function(String id)? deleteSubscribeInfo,
    TResult? Function()? getAllSubscribeList,
    TResult? Function(String id)? checkSubscribeInfo,
    TResult? Function(List<Subscribe> subscribedChannels)?
        updateSubscribeOldList,
  }) {
    return updateSubscribeOldList?.call(subscribedChannels);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Subscribe channelInfo)? addSubscribe,
    TResult Function(String id)? deleteSubscribeInfo,
    TResult Function()? getAllSubscribeList,
    TResult Function(String id)? checkSubscribeInfo,
    TResult Function(List<Subscribe> subscribedChannels)?
        updateSubscribeOldList,
    required TResult orElse(),
  }) {
    if (updateSubscribeOldList != null) {
      return updateSubscribeOldList(subscribedChannels);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AddSubscribe value) addSubscribe,
    required TResult Function(DeleteSubscribeInfo value) deleteSubscribeInfo,
    required TResult Function(GetAllSubscribeList value) getAllSubscribeList,
    required TResult Function(CheckSubscribeInfo value) checkSubscribeInfo,
    required TResult Function(UpdateSubscribeOldList value)
        updateSubscribeOldList,
  }) {
    return updateSubscribeOldList(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AddSubscribe value)? addSubscribe,
    TResult? Function(DeleteSubscribeInfo value)? deleteSubscribeInfo,
    TResult? Function(GetAllSubscribeList value)? getAllSubscribeList,
    TResult? Function(CheckSubscribeInfo value)? checkSubscribeInfo,
    TResult? Function(UpdateSubscribeOldList value)? updateSubscribeOldList,
  }) {
    return updateSubscribeOldList?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AddSubscribe value)? addSubscribe,
    TResult Function(DeleteSubscribeInfo value)? deleteSubscribeInfo,
    TResult Function(GetAllSubscribeList value)? getAllSubscribeList,
    TResult Function(CheckSubscribeInfo value)? checkSubscribeInfo,
    TResult Function(UpdateSubscribeOldList value)? updateSubscribeOldList,
    required TResult orElse(),
  }) {
    if (updateSubscribeOldList != null) {
      return updateSubscribeOldList(this);
    }
    return orElse();
  }
}

abstract class UpdateSubscribeOldList implements SubscribeEvent {
  const factory UpdateSubscribeOldList(
          {required final List<Subscribe> subscribedChannels}) =
      _$UpdateSubscribeOldListImpl;

  List<Subscribe> get subscribedChannels;
  @JsonKey(ignore: true)
  _$$UpdateSubscribeOldListImplCopyWith<_$UpdateSubscribeOldListImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SubscribeState {
  ApiStatus get subscribeStatus => throw _privateConstructorUsedError;
  Subscribe? get channelInfo => throw _privateConstructorUsedError;
  List<Subscribe> get subscribedChannels => throw _privateConstructorUsedError;
  List<Subscribe> get oldList => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SubscribeStateCopyWith<SubscribeState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscribeStateCopyWith<$Res> {
  factory $SubscribeStateCopyWith(
          SubscribeState value, $Res Function(SubscribeState) then) =
      _$SubscribeStateCopyWithImpl<$Res, SubscribeState>;
  @useResult
  $Res call(
      {ApiStatus subscribeStatus,
      Subscribe? channelInfo,
      List<Subscribe> subscribedChannels,
      List<Subscribe> oldList});
}

/// @nodoc
class _$SubscribeStateCopyWithImpl<$Res, $Val extends SubscribeState>
    implements $SubscribeStateCopyWith<$Res> {
  _$SubscribeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subscribeStatus = null,
    Object? channelInfo = freezed,
    Object? subscribedChannels = null,
    Object? oldList = null,
  }) {
    return _then(_value.copyWith(
      subscribeStatus: null == subscribeStatus
          ? _value.subscribeStatus
          : subscribeStatus // ignore: cast_nullable_to_non_nullable
              as ApiStatus,
      channelInfo: freezed == channelInfo
          ? _value.channelInfo
          : channelInfo // ignore: cast_nullable_to_non_nullable
              as Subscribe?,
      subscribedChannels: null == subscribedChannels
          ? _value.subscribedChannels
          : subscribedChannels // ignore: cast_nullable_to_non_nullable
              as List<Subscribe>,
      oldList: null == oldList
          ? _value.oldList
          : oldList // ignore: cast_nullable_to_non_nullable
              as List<Subscribe>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InitialImplCopyWith<$Res>
    implements $SubscribeStateCopyWith<$Res> {
  factory _$$InitialImplCopyWith(
          _$InitialImpl value, $Res Function(_$InitialImpl) then) =
      __$$InitialImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {ApiStatus subscribeStatus,
      Subscribe? channelInfo,
      List<Subscribe> subscribedChannels,
      List<Subscribe> oldList});
}

/// @nodoc
class __$$InitialImplCopyWithImpl<$Res>
    extends _$SubscribeStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
      _$InitialImpl _value, $Res Function(_$InitialImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subscribeStatus = null,
    Object? channelInfo = freezed,
    Object? subscribedChannels = null,
    Object? oldList = null,
  }) {
    return _then(_$InitialImpl(
      subscribeStatus: null == subscribeStatus
          ? _value.subscribeStatus
          : subscribeStatus // ignore: cast_nullable_to_non_nullable
              as ApiStatus,
      channelInfo: freezed == channelInfo
          ? _value.channelInfo
          : channelInfo // ignore: cast_nullable_to_non_nullable
              as Subscribe?,
      subscribedChannels: null == subscribedChannels
          ? _value._subscribedChannels
          : subscribedChannels // ignore: cast_nullable_to_non_nullable
              as List<Subscribe>,
      oldList: null == oldList
          ? _value._oldList
          : oldList // ignore: cast_nullable_to_non_nullable
              as List<Subscribe>,
    ));
  }
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl(
      {required this.subscribeStatus,
      required this.channelInfo,
      required final List<Subscribe> subscribedChannels,
      required final List<Subscribe> oldList})
      : _subscribedChannels = subscribedChannels,
        _oldList = oldList;

  @override
  final ApiStatus subscribeStatus;
  @override
  final Subscribe? channelInfo;
  final List<Subscribe> _subscribedChannels;
  @override
  List<Subscribe> get subscribedChannels {
    if (_subscribedChannels is EqualUnmodifiableListView)
      return _subscribedChannels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subscribedChannels);
  }

  final List<Subscribe> _oldList;
  @override
  List<Subscribe> get oldList {
    if (_oldList is EqualUnmodifiableListView) return _oldList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_oldList);
  }

  @override
  String toString() {
    return 'SubscribeState(subscribeStatus: $subscribeStatus, channelInfo: $channelInfo, subscribedChannels: $subscribedChannels, oldList: $oldList)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InitialImpl &&
            (identical(other.subscribeStatus, subscribeStatus) ||
                other.subscribeStatus == subscribeStatus) &&
            (identical(other.channelInfo, channelInfo) ||
                other.channelInfo == channelInfo) &&
            const DeepCollectionEquality()
                .equals(other._subscribedChannels, _subscribedChannels) &&
            const DeepCollectionEquality().equals(other._oldList, _oldList));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      subscribeStatus,
      channelInfo,
      const DeepCollectionEquality().hash(_subscribedChannels),
      const DeepCollectionEquality().hash(_oldList));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$InitialImplCopyWith<_$InitialImpl> get copyWith =>
      __$$InitialImplCopyWithImpl<_$InitialImpl>(this, _$identity);
}

abstract class _Initial implements SubscribeState {
  const factory _Initial(
      {required final ApiStatus subscribeStatus,
      required final Subscribe? channelInfo,
      required final List<Subscribe> subscribedChannels,
      required final List<Subscribe> oldList}) = _$InitialImpl;

  @override
  ApiStatus get subscribeStatus;
  @override
  Subscribe? get channelInfo;
  @override
  List<Subscribe> get subscribedChannels;
  @override
  List<Subscribe> get oldList;
  @override
  @JsonKey(ignore: true)
  _$$InitialImplCopyWith<_$InitialImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
