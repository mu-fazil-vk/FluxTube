// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SearchEvent {
  String get query => throw _privateConstructorUsedError;
  String get serviceType => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String query, String? filter, String serviceType)
        getSearchResult,
    required TResult Function(
            String query, String? filter, String? nextPage, String serviceType)
        getMoreSearchResult,
    required TResult Function(String query, String serviceType)
        getSearchSuggestion,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String query, String? filter, String serviceType)?
        getSearchResult,
    TResult? Function(
            String query, String? filter, String? nextPage, String serviceType)?
        getMoreSearchResult,
    TResult? Function(String query, String serviceType)? getSearchSuggestion,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String query, String? filter, String serviceType)?
        getSearchResult,
    TResult Function(
            String query, String? filter, String? nextPage, String serviceType)?
        getMoreSearchResult,
    TResult Function(String query, String serviceType)? getSearchSuggestion,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GetSearchResult value) getSearchResult,
    required TResult Function(GetMoreSearchResult value) getMoreSearchResult,
    required TResult Function(GetSearchSuggestion value) getSearchSuggestion,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GetSearchResult value)? getSearchResult,
    TResult? Function(GetMoreSearchResult value)? getMoreSearchResult,
    TResult? Function(GetSearchSuggestion value)? getSearchSuggestion,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GetSearchResult value)? getSearchResult,
    TResult Function(GetMoreSearchResult value)? getMoreSearchResult,
    TResult Function(GetSearchSuggestion value)? getSearchSuggestion,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SearchEventCopyWith<SearchEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchEventCopyWith<$Res> {
  factory $SearchEventCopyWith(
          SearchEvent value, $Res Function(SearchEvent) then) =
      _$SearchEventCopyWithImpl<$Res, SearchEvent>;
  @useResult
  $Res call({String query, String serviceType});
}

/// @nodoc
class _$SearchEventCopyWithImpl<$Res, $Val extends SearchEvent>
    implements $SearchEventCopyWith<$Res> {
  _$SearchEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? serviceType = null,
  }) {
    return _then(_value.copyWith(
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      serviceType: null == serviceType
          ? _value.serviceType
          : serviceType // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GetSearchResultImplCopyWith<$Res>
    implements $SearchEventCopyWith<$Res> {
  factory _$$GetSearchResultImplCopyWith(_$GetSearchResultImpl value,
          $Res Function(_$GetSearchResultImpl) then) =
      __$$GetSearchResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String query, String? filter, String serviceType});
}

/// @nodoc
class __$$GetSearchResultImplCopyWithImpl<$Res>
    extends _$SearchEventCopyWithImpl<$Res, _$GetSearchResultImpl>
    implements _$$GetSearchResultImplCopyWith<$Res> {
  __$$GetSearchResultImplCopyWithImpl(
      _$GetSearchResultImpl _value, $Res Function(_$GetSearchResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? filter = freezed,
    Object? serviceType = null,
  }) {
    return _then(_$GetSearchResultImpl(
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      filter: freezed == filter
          ? _value.filter
          : filter // ignore: cast_nullable_to_non_nullable
              as String?,
      serviceType: null == serviceType
          ? _value.serviceType
          : serviceType // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$GetSearchResultImpl implements GetSearchResult {
  const _$GetSearchResultImpl(
      {required this.query, required this.filter, required this.serviceType});

  @override
  final String query;
  @override
  final String? filter;
  @override
  final String serviceType;

  @override
  String toString() {
    return 'SearchEvent.getSearchResult(query: $query, filter: $filter, serviceType: $serviceType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetSearchResultImpl &&
            (identical(other.query, query) || other.query == query) &&
            (identical(other.filter, filter) || other.filter == filter) &&
            (identical(other.serviceType, serviceType) ||
                other.serviceType == serviceType));
  }

  @override
  int get hashCode => Object.hash(runtimeType, query, filter, serviceType);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetSearchResultImplCopyWith<_$GetSearchResultImpl> get copyWith =>
      __$$GetSearchResultImplCopyWithImpl<_$GetSearchResultImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String query, String? filter, String serviceType)
        getSearchResult,
    required TResult Function(
            String query, String? filter, String? nextPage, String serviceType)
        getMoreSearchResult,
    required TResult Function(String query, String serviceType)
        getSearchSuggestion,
  }) {
    return getSearchResult(query, filter, serviceType);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String query, String? filter, String serviceType)?
        getSearchResult,
    TResult? Function(
            String query, String? filter, String? nextPage, String serviceType)?
        getMoreSearchResult,
    TResult? Function(String query, String serviceType)? getSearchSuggestion,
  }) {
    return getSearchResult?.call(query, filter, serviceType);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String query, String? filter, String serviceType)?
        getSearchResult,
    TResult Function(
            String query, String? filter, String? nextPage, String serviceType)?
        getMoreSearchResult,
    TResult Function(String query, String serviceType)? getSearchSuggestion,
    required TResult orElse(),
  }) {
    if (getSearchResult != null) {
      return getSearchResult(query, filter, serviceType);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GetSearchResult value) getSearchResult,
    required TResult Function(GetMoreSearchResult value) getMoreSearchResult,
    required TResult Function(GetSearchSuggestion value) getSearchSuggestion,
  }) {
    return getSearchResult(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GetSearchResult value)? getSearchResult,
    TResult? Function(GetMoreSearchResult value)? getMoreSearchResult,
    TResult? Function(GetSearchSuggestion value)? getSearchSuggestion,
  }) {
    return getSearchResult?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GetSearchResult value)? getSearchResult,
    TResult Function(GetMoreSearchResult value)? getMoreSearchResult,
    TResult Function(GetSearchSuggestion value)? getSearchSuggestion,
    required TResult orElse(),
  }) {
    if (getSearchResult != null) {
      return getSearchResult(this);
    }
    return orElse();
  }
}

abstract class GetSearchResult implements SearchEvent {
  const factory GetSearchResult(
      {required final String query,
      required final String? filter,
      required final String serviceType}) = _$GetSearchResultImpl;

  @override
  String get query;
  String? get filter;
  @override
  String get serviceType;
  @override
  @JsonKey(ignore: true)
  _$$GetSearchResultImplCopyWith<_$GetSearchResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GetMoreSearchResultImplCopyWith<$Res>
    implements $SearchEventCopyWith<$Res> {
  factory _$$GetMoreSearchResultImplCopyWith(_$GetMoreSearchResultImpl value,
          $Res Function(_$GetMoreSearchResultImpl) then) =
      __$$GetMoreSearchResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String query, String? filter, String? nextPage, String serviceType});
}

/// @nodoc
class __$$GetMoreSearchResultImplCopyWithImpl<$Res>
    extends _$SearchEventCopyWithImpl<$Res, _$GetMoreSearchResultImpl>
    implements _$$GetMoreSearchResultImplCopyWith<$Res> {
  __$$GetMoreSearchResultImplCopyWithImpl(_$GetMoreSearchResultImpl _value,
      $Res Function(_$GetMoreSearchResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? filter = freezed,
    Object? nextPage = freezed,
    Object? serviceType = null,
  }) {
    return _then(_$GetMoreSearchResultImpl(
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      filter: freezed == filter
          ? _value.filter
          : filter // ignore: cast_nullable_to_non_nullable
              as String?,
      nextPage: freezed == nextPage
          ? _value.nextPage
          : nextPage // ignore: cast_nullable_to_non_nullable
              as String?,
      serviceType: null == serviceType
          ? _value.serviceType
          : serviceType // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$GetMoreSearchResultImpl implements GetMoreSearchResult {
  const _$GetMoreSearchResultImpl(
      {required this.query,
      required this.filter,
      required this.nextPage,
      required this.serviceType});

  @override
  final String query;
  @override
  final String? filter;
  @override
  final String? nextPage;
  @override
  final String serviceType;

  @override
  String toString() {
    return 'SearchEvent.getMoreSearchResult(query: $query, filter: $filter, nextPage: $nextPage, serviceType: $serviceType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetMoreSearchResultImpl &&
            (identical(other.query, query) || other.query == query) &&
            (identical(other.filter, filter) || other.filter == filter) &&
            (identical(other.nextPage, nextPage) ||
                other.nextPage == nextPage) &&
            (identical(other.serviceType, serviceType) ||
                other.serviceType == serviceType));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, query, filter, nextPage, serviceType);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetMoreSearchResultImplCopyWith<_$GetMoreSearchResultImpl> get copyWith =>
      __$$GetMoreSearchResultImplCopyWithImpl<_$GetMoreSearchResultImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String query, String? filter, String serviceType)
        getSearchResult,
    required TResult Function(
            String query, String? filter, String? nextPage, String serviceType)
        getMoreSearchResult,
    required TResult Function(String query, String serviceType)
        getSearchSuggestion,
  }) {
    return getMoreSearchResult(query, filter, nextPage, serviceType);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String query, String? filter, String serviceType)?
        getSearchResult,
    TResult? Function(
            String query, String? filter, String? nextPage, String serviceType)?
        getMoreSearchResult,
    TResult? Function(String query, String serviceType)? getSearchSuggestion,
  }) {
    return getMoreSearchResult?.call(query, filter, nextPage, serviceType);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String query, String? filter, String serviceType)?
        getSearchResult,
    TResult Function(
            String query, String? filter, String? nextPage, String serviceType)?
        getMoreSearchResult,
    TResult Function(String query, String serviceType)? getSearchSuggestion,
    required TResult orElse(),
  }) {
    if (getMoreSearchResult != null) {
      return getMoreSearchResult(query, filter, nextPage, serviceType);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GetSearchResult value) getSearchResult,
    required TResult Function(GetMoreSearchResult value) getMoreSearchResult,
    required TResult Function(GetSearchSuggestion value) getSearchSuggestion,
  }) {
    return getMoreSearchResult(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GetSearchResult value)? getSearchResult,
    TResult? Function(GetMoreSearchResult value)? getMoreSearchResult,
    TResult? Function(GetSearchSuggestion value)? getSearchSuggestion,
  }) {
    return getMoreSearchResult?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GetSearchResult value)? getSearchResult,
    TResult Function(GetMoreSearchResult value)? getMoreSearchResult,
    TResult Function(GetSearchSuggestion value)? getSearchSuggestion,
    required TResult orElse(),
  }) {
    if (getMoreSearchResult != null) {
      return getMoreSearchResult(this);
    }
    return orElse();
  }
}

abstract class GetMoreSearchResult implements SearchEvent {
  const factory GetMoreSearchResult(
      {required final String query,
      required final String? filter,
      required final String? nextPage,
      required final String serviceType}) = _$GetMoreSearchResultImpl;

  @override
  String get query;
  String? get filter;
  String? get nextPage;
  @override
  String get serviceType;
  @override
  @JsonKey(ignore: true)
  _$$GetMoreSearchResultImplCopyWith<_$GetMoreSearchResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GetSearchSuggestionImplCopyWith<$Res>
    implements $SearchEventCopyWith<$Res> {
  factory _$$GetSearchSuggestionImplCopyWith(_$GetSearchSuggestionImpl value,
          $Res Function(_$GetSearchSuggestionImpl) then) =
      __$$GetSearchSuggestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String query, String serviceType});
}

/// @nodoc
class __$$GetSearchSuggestionImplCopyWithImpl<$Res>
    extends _$SearchEventCopyWithImpl<$Res, _$GetSearchSuggestionImpl>
    implements _$$GetSearchSuggestionImplCopyWith<$Res> {
  __$$GetSearchSuggestionImplCopyWithImpl(_$GetSearchSuggestionImpl _value,
      $Res Function(_$GetSearchSuggestionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? serviceType = null,
  }) {
    return _then(_$GetSearchSuggestionImpl(
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      serviceType: null == serviceType
          ? _value.serviceType
          : serviceType // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$GetSearchSuggestionImpl implements GetSearchSuggestion {
  const _$GetSearchSuggestionImpl(
      {required this.query, required this.serviceType});

  @override
  final String query;
  @override
  final String serviceType;

  @override
  String toString() {
    return 'SearchEvent.getSearchSuggestion(query: $query, serviceType: $serviceType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetSearchSuggestionImpl &&
            (identical(other.query, query) || other.query == query) &&
            (identical(other.serviceType, serviceType) ||
                other.serviceType == serviceType));
  }

  @override
  int get hashCode => Object.hash(runtimeType, query, serviceType);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetSearchSuggestionImplCopyWith<_$GetSearchSuggestionImpl> get copyWith =>
      __$$GetSearchSuggestionImplCopyWithImpl<_$GetSearchSuggestionImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String query, String? filter, String serviceType)
        getSearchResult,
    required TResult Function(
            String query, String? filter, String? nextPage, String serviceType)
        getMoreSearchResult,
    required TResult Function(String query, String serviceType)
        getSearchSuggestion,
  }) {
    return getSearchSuggestion(query, serviceType);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String query, String? filter, String serviceType)?
        getSearchResult,
    TResult? Function(
            String query, String? filter, String? nextPage, String serviceType)?
        getMoreSearchResult,
    TResult? Function(String query, String serviceType)? getSearchSuggestion,
  }) {
    return getSearchSuggestion?.call(query, serviceType);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String query, String? filter, String serviceType)?
        getSearchResult,
    TResult Function(
            String query, String? filter, String? nextPage, String serviceType)?
        getMoreSearchResult,
    TResult Function(String query, String serviceType)? getSearchSuggestion,
    required TResult orElse(),
  }) {
    if (getSearchSuggestion != null) {
      return getSearchSuggestion(query, serviceType);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GetSearchResult value) getSearchResult,
    required TResult Function(GetMoreSearchResult value) getMoreSearchResult,
    required TResult Function(GetSearchSuggestion value) getSearchSuggestion,
  }) {
    return getSearchSuggestion(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GetSearchResult value)? getSearchResult,
    TResult? Function(GetMoreSearchResult value)? getMoreSearchResult,
    TResult? Function(GetSearchSuggestion value)? getSearchSuggestion,
  }) {
    return getSearchSuggestion?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GetSearchResult value)? getSearchResult,
    TResult Function(GetMoreSearchResult value)? getMoreSearchResult,
    TResult Function(GetSearchSuggestion value)? getSearchSuggestion,
    required TResult orElse(),
  }) {
    if (getSearchSuggestion != null) {
      return getSearchSuggestion(this);
    }
    return orElse();
  }
}

abstract class GetSearchSuggestion implements SearchEvent {
  const factory GetSearchSuggestion(
      {required final String query,
      required final String serviceType}) = _$GetSearchSuggestionImpl;

  @override
  String get query;
  @override
  String get serviceType;
  @override
  @JsonKey(ignore: true)
  _$$GetSearchSuggestionImplCopyWith<_$GetSearchSuggestionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SearchState {
//
  bool get isSuggestionDisplay => throw _privateConstructorUsedError; // PIPED
  ApiStatus get fetchSearchResultStatus => throw _privateConstructorUsedError;
  SearchResp? get result => throw _privateConstructorUsedError;
  ApiStatus get fetchSuggestionStatus => throw _privateConstructorUsedError;
  List<dynamic> get suggestions => throw _privateConstructorUsedError;
  ApiStatus get fetchMoreSearchResultStatus =>
      throw _privateConstructorUsedError;
  bool get isMoreFetchCompleted =>
      throw _privateConstructorUsedError; // INVIDIOUS
  ApiStatus get fetchInvidiousSearchResultStatus =>
      throw _privateConstructorUsedError;
  List<InvidiousSearchResp> get invidiousSearchResult =>
      throw _privateConstructorUsedError;
  ApiStatus get fetchInvidiousSuggestionStatus =>
      throw _privateConstructorUsedError;
  List<dynamic> get invidiousSuggestionResult =>
      throw _privateConstructorUsedError;
  ApiStatus get fetchMoreInvidiousSearchResultStatus =>
      throw _privateConstructorUsedError;
  bool get isMoreInvidiousFetchCompleted => throw _privateConstructorUsedError;
  int? get page => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SearchStateCopyWith<SearchState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchStateCopyWith<$Res> {
  factory $SearchStateCopyWith(
          SearchState value, $Res Function(SearchState) then) =
      _$SearchStateCopyWithImpl<$Res, SearchState>;
  @useResult
  $Res call(
      {bool isSuggestionDisplay,
      ApiStatus fetchSearchResultStatus,
      SearchResp? result,
      ApiStatus fetchSuggestionStatus,
      List<dynamic> suggestions,
      ApiStatus fetchMoreSearchResultStatus,
      bool isMoreFetchCompleted,
      ApiStatus fetchInvidiousSearchResultStatus,
      List<InvidiousSearchResp> invidiousSearchResult,
      ApiStatus fetchInvidiousSuggestionStatus,
      List<dynamic> invidiousSuggestionResult,
      ApiStatus fetchMoreInvidiousSearchResultStatus,
      bool isMoreInvidiousFetchCompleted,
      int? page});
}

/// @nodoc
class _$SearchStateCopyWithImpl<$Res, $Val extends SearchState>
    implements $SearchStateCopyWith<$Res> {
  _$SearchStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isSuggestionDisplay = null,
    Object? fetchSearchResultStatus = null,
    Object? result = freezed,
    Object? fetchSuggestionStatus = null,
    Object? suggestions = null,
    Object? fetchMoreSearchResultStatus = null,
    Object? isMoreFetchCompleted = null,
    Object? fetchInvidiousSearchResultStatus = null,
    Object? invidiousSearchResult = null,
    Object? fetchInvidiousSuggestionStatus = null,
    Object? invidiousSuggestionResult = null,
    Object? fetchMoreInvidiousSearchResultStatus = null,
    Object? isMoreInvidiousFetchCompleted = null,
    Object? page = freezed,
  }) {
    return _then(_value.copyWith(
      isSuggestionDisplay: null == isSuggestionDisplay
          ? _value.isSuggestionDisplay
          : isSuggestionDisplay // ignore: cast_nullable_to_non_nullable
              as bool,
      fetchSearchResultStatus: null == fetchSearchResultStatus
          ? _value.fetchSearchResultStatus
          : fetchSearchResultStatus // ignore: cast_nullable_to_non_nullable
              as ApiStatus,
      result: freezed == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as SearchResp?,
      fetchSuggestionStatus: null == fetchSuggestionStatus
          ? _value.fetchSuggestionStatus
          : fetchSuggestionStatus // ignore: cast_nullable_to_non_nullable
              as ApiStatus,
      suggestions: null == suggestions
          ? _value.suggestions
          : suggestions // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      fetchMoreSearchResultStatus: null == fetchMoreSearchResultStatus
          ? _value.fetchMoreSearchResultStatus
          : fetchMoreSearchResultStatus // ignore: cast_nullable_to_non_nullable
              as ApiStatus,
      isMoreFetchCompleted: null == isMoreFetchCompleted
          ? _value.isMoreFetchCompleted
          : isMoreFetchCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      fetchInvidiousSearchResultStatus: null == fetchInvidiousSearchResultStatus
          ? _value.fetchInvidiousSearchResultStatus
          : fetchInvidiousSearchResultStatus // ignore: cast_nullable_to_non_nullable
              as ApiStatus,
      invidiousSearchResult: null == invidiousSearchResult
          ? _value.invidiousSearchResult
          : invidiousSearchResult // ignore: cast_nullable_to_non_nullable
              as List<InvidiousSearchResp>,
      fetchInvidiousSuggestionStatus: null == fetchInvidiousSuggestionStatus
          ? _value.fetchInvidiousSuggestionStatus
          : fetchInvidiousSuggestionStatus // ignore: cast_nullable_to_non_nullable
              as ApiStatus,
      invidiousSuggestionResult: null == invidiousSuggestionResult
          ? _value.invidiousSuggestionResult
          : invidiousSuggestionResult // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      fetchMoreInvidiousSearchResultStatus: null ==
              fetchMoreInvidiousSearchResultStatus
          ? _value.fetchMoreInvidiousSearchResultStatus
          : fetchMoreInvidiousSearchResultStatus // ignore: cast_nullable_to_non_nullable
              as ApiStatus,
      isMoreInvidiousFetchCompleted: null == isMoreInvidiousFetchCompleted
          ? _value.isMoreInvidiousFetchCompleted
          : isMoreInvidiousFetchCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      page: freezed == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SearchStateImplCopyWith<$Res>
    implements $SearchStateCopyWith<$Res> {
  factory _$$SearchStateImplCopyWith(
          _$SearchStateImpl value, $Res Function(_$SearchStateImpl) then) =
      __$$SearchStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isSuggestionDisplay,
      ApiStatus fetchSearchResultStatus,
      SearchResp? result,
      ApiStatus fetchSuggestionStatus,
      List<dynamic> suggestions,
      ApiStatus fetchMoreSearchResultStatus,
      bool isMoreFetchCompleted,
      ApiStatus fetchInvidiousSearchResultStatus,
      List<InvidiousSearchResp> invidiousSearchResult,
      ApiStatus fetchInvidiousSuggestionStatus,
      List<dynamic> invidiousSuggestionResult,
      ApiStatus fetchMoreInvidiousSearchResultStatus,
      bool isMoreInvidiousFetchCompleted,
      int? page});
}

/// @nodoc
class __$$SearchStateImplCopyWithImpl<$Res>
    extends _$SearchStateCopyWithImpl<$Res, _$SearchStateImpl>
    implements _$$SearchStateImplCopyWith<$Res> {
  __$$SearchStateImplCopyWithImpl(
      _$SearchStateImpl _value, $Res Function(_$SearchStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isSuggestionDisplay = null,
    Object? fetchSearchResultStatus = null,
    Object? result = freezed,
    Object? fetchSuggestionStatus = null,
    Object? suggestions = null,
    Object? fetchMoreSearchResultStatus = null,
    Object? isMoreFetchCompleted = null,
    Object? fetchInvidiousSearchResultStatus = null,
    Object? invidiousSearchResult = null,
    Object? fetchInvidiousSuggestionStatus = null,
    Object? invidiousSuggestionResult = null,
    Object? fetchMoreInvidiousSearchResultStatus = null,
    Object? isMoreInvidiousFetchCompleted = null,
    Object? page = freezed,
  }) {
    return _then(_$SearchStateImpl(
      isSuggestionDisplay: null == isSuggestionDisplay
          ? _value.isSuggestionDisplay
          : isSuggestionDisplay // ignore: cast_nullable_to_non_nullable
              as bool,
      fetchSearchResultStatus: null == fetchSearchResultStatus
          ? _value.fetchSearchResultStatus
          : fetchSearchResultStatus // ignore: cast_nullable_to_non_nullable
              as ApiStatus,
      result: freezed == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as SearchResp?,
      fetchSuggestionStatus: null == fetchSuggestionStatus
          ? _value.fetchSuggestionStatus
          : fetchSuggestionStatus // ignore: cast_nullable_to_non_nullable
              as ApiStatus,
      suggestions: null == suggestions
          ? _value._suggestions
          : suggestions // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      fetchMoreSearchResultStatus: null == fetchMoreSearchResultStatus
          ? _value.fetchMoreSearchResultStatus
          : fetchMoreSearchResultStatus // ignore: cast_nullable_to_non_nullable
              as ApiStatus,
      isMoreFetchCompleted: null == isMoreFetchCompleted
          ? _value.isMoreFetchCompleted
          : isMoreFetchCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      fetchInvidiousSearchResultStatus: null == fetchInvidiousSearchResultStatus
          ? _value.fetchInvidiousSearchResultStatus
          : fetchInvidiousSearchResultStatus // ignore: cast_nullable_to_non_nullable
              as ApiStatus,
      invidiousSearchResult: null == invidiousSearchResult
          ? _value._invidiousSearchResult
          : invidiousSearchResult // ignore: cast_nullable_to_non_nullable
              as List<InvidiousSearchResp>,
      fetchInvidiousSuggestionStatus: null == fetchInvidiousSuggestionStatus
          ? _value.fetchInvidiousSuggestionStatus
          : fetchInvidiousSuggestionStatus // ignore: cast_nullable_to_non_nullable
              as ApiStatus,
      invidiousSuggestionResult: null == invidiousSuggestionResult
          ? _value._invidiousSuggestionResult
          : invidiousSuggestionResult // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      fetchMoreInvidiousSearchResultStatus: null ==
              fetchMoreInvidiousSearchResultStatus
          ? _value.fetchMoreInvidiousSearchResultStatus
          : fetchMoreInvidiousSearchResultStatus // ignore: cast_nullable_to_non_nullable
              as ApiStatus,
      isMoreInvidiousFetchCompleted: null == isMoreInvidiousFetchCompleted
          ? _value.isMoreInvidiousFetchCompleted
          : isMoreInvidiousFetchCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      page: freezed == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$SearchStateImpl implements _SearchState {
  const _$SearchStateImpl(
      {required this.isSuggestionDisplay,
      required this.fetchSearchResultStatus,
      required this.result,
      required this.fetchSuggestionStatus,
      required final List<dynamic> suggestions,
      required this.fetchMoreSearchResultStatus,
      required this.isMoreFetchCompleted,
      required this.fetchInvidiousSearchResultStatus,
      required final List<InvidiousSearchResp> invidiousSearchResult,
      required this.fetchInvidiousSuggestionStatus,
      required final List<dynamic> invidiousSuggestionResult,
      required this.fetchMoreInvidiousSearchResultStatus,
      required this.isMoreInvidiousFetchCompleted,
      this.page})
      : _suggestions = suggestions,
        _invidiousSearchResult = invidiousSearchResult,
        _invidiousSuggestionResult = invidiousSuggestionResult;

//
  @override
  final bool isSuggestionDisplay;
// PIPED
  @override
  final ApiStatus fetchSearchResultStatus;
  @override
  final SearchResp? result;
  @override
  final ApiStatus fetchSuggestionStatus;
  final List<dynamic> _suggestions;
  @override
  List<dynamic> get suggestions {
    if (_suggestions is EqualUnmodifiableListView) return _suggestions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_suggestions);
  }

  @override
  final ApiStatus fetchMoreSearchResultStatus;
  @override
  final bool isMoreFetchCompleted;
// INVIDIOUS
  @override
  final ApiStatus fetchInvidiousSearchResultStatus;
  final List<InvidiousSearchResp> _invidiousSearchResult;
  @override
  List<InvidiousSearchResp> get invidiousSearchResult {
    if (_invidiousSearchResult is EqualUnmodifiableListView)
      return _invidiousSearchResult;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_invidiousSearchResult);
  }

  @override
  final ApiStatus fetchInvidiousSuggestionStatus;
  final List<dynamic> _invidiousSuggestionResult;
  @override
  List<dynamic> get invidiousSuggestionResult {
    if (_invidiousSuggestionResult is EqualUnmodifiableListView)
      return _invidiousSuggestionResult;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_invidiousSuggestionResult);
  }

  @override
  final ApiStatus fetchMoreInvidiousSearchResultStatus;
  @override
  final bool isMoreInvidiousFetchCompleted;
  @override
  final int? page;

  @override
  String toString() {
    return 'SearchState(isSuggestionDisplay: $isSuggestionDisplay, fetchSearchResultStatus: $fetchSearchResultStatus, result: $result, fetchSuggestionStatus: $fetchSuggestionStatus, suggestions: $suggestions, fetchMoreSearchResultStatus: $fetchMoreSearchResultStatus, isMoreFetchCompleted: $isMoreFetchCompleted, fetchInvidiousSearchResultStatus: $fetchInvidiousSearchResultStatus, invidiousSearchResult: $invidiousSearchResult, fetchInvidiousSuggestionStatus: $fetchInvidiousSuggestionStatus, invidiousSuggestionResult: $invidiousSuggestionResult, fetchMoreInvidiousSearchResultStatus: $fetchMoreInvidiousSearchResultStatus, isMoreInvidiousFetchCompleted: $isMoreInvidiousFetchCompleted, page: $page)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchStateImpl &&
            (identical(other.isSuggestionDisplay, isSuggestionDisplay) ||
                other.isSuggestionDisplay == isSuggestionDisplay) &&
            (identical(other.fetchSearchResultStatus, fetchSearchResultStatus) ||
                other.fetchSearchResultStatus == fetchSearchResultStatus) &&
            (identical(other.result, result) || other.result == result) &&
            (identical(other.fetchSuggestionStatus, fetchSuggestionStatus) ||
                other.fetchSuggestionStatus == fetchSuggestionStatus) &&
            const DeepCollectionEquality()
                .equals(other._suggestions, _suggestions) &&
            (identical(other.fetchMoreSearchResultStatus, fetchMoreSearchResultStatus) ||
                other.fetchMoreSearchResultStatus ==
                    fetchMoreSearchResultStatus) &&
            (identical(other.isMoreFetchCompleted, isMoreFetchCompleted) ||
                other.isMoreFetchCompleted == isMoreFetchCompleted) &&
            (identical(other.fetchInvidiousSearchResultStatus,
                    fetchInvidiousSearchResultStatus) ||
                other.fetchInvidiousSearchResultStatus ==
                    fetchInvidiousSearchResultStatus) &&
            const DeepCollectionEquality()
                .equals(other._invidiousSearchResult, _invidiousSearchResult) &&
            (identical(other.fetchInvidiousSuggestionStatus,
                    fetchInvidiousSuggestionStatus) ||
                other.fetchInvidiousSuggestionStatus ==
                    fetchInvidiousSuggestionStatus) &&
            const DeepCollectionEquality().equals(
                other._invidiousSuggestionResult, _invidiousSuggestionResult) &&
            (identical(other.fetchMoreInvidiousSearchResultStatus,
                    fetchMoreInvidiousSearchResultStatus) ||
                other.fetchMoreInvidiousSearchResultStatus ==
                    fetchMoreInvidiousSearchResultStatus) &&
            (identical(other.isMoreInvidiousFetchCompleted, isMoreInvidiousFetchCompleted) ||
                other.isMoreInvidiousFetchCompleted == isMoreInvidiousFetchCompleted) &&
            (identical(other.page, page) || other.page == page));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isSuggestionDisplay,
      fetchSearchResultStatus,
      result,
      fetchSuggestionStatus,
      const DeepCollectionEquality().hash(_suggestions),
      fetchMoreSearchResultStatus,
      isMoreFetchCompleted,
      fetchInvidiousSearchResultStatus,
      const DeepCollectionEquality().hash(_invidiousSearchResult),
      fetchInvidiousSuggestionStatus,
      const DeepCollectionEquality().hash(_invidiousSuggestionResult),
      fetchMoreInvidiousSearchResultStatus,
      isMoreInvidiousFetchCompleted,
      page);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchStateImplCopyWith<_$SearchStateImpl> get copyWith =>
      __$$SearchStateImplCopyWithImpl<_$SearchStateImpl>(this, _$identity);
}

abstract class _SearchState implements SearchState {
  const factory _SearchState(
      {required final bool isSuggestionDisplay,
      required final ApiStatus fetchSearchResultStatus,
      required final SearchResp? result,
      required final ApiStatus fetchSuggestionStatus,
      required final List<dynamic> suggestions,
      required final ApiStatus fetchMoreSearchResultStatus,
      required final bool isMoreFetchCompleted,
      required final ApiStatus fetchInvidiousSearchResultStatus,
      required final List<InvidiousSearchResp> invidiousSearchResult,
      required final ApiStatus fetchInvidiousSuggestionStatus,
      required final List<dynamic> invidiousSuggestionResult,
      required final ApiStatus fetchMoreInvidiousSearchResultStatus,
      required final bool isMoreInvidiousFetchCompleted,
      final int? page}) = _$SearchStateImpl;

  @override //
  bool get isSuggestionDisplay;
  @override // PIPED
  ApiStatus get fetchSearchResultStatus;
  @override
  SearchResp? get result;
  @override
  ApiStatus get fetchSuggestionStatus;
  @override
  List<dynamic> get suggestions;
  @override
  ApiStatus get fetchMoreSearchResultStatus;
  @override
  bool get isMoreFetchCompleted;
  @override // INVIDIOUS
  ApiStatus get fetchInvidiousSearchResultStatus;
  @override
  List<InvidiousSearchResp> get invidiousSearchResult;
  @override
  ApiStatus get fetchInvidiousSuggestionStatus;
  @override
  List<dynamic> get invidiousSuggestionResult;
  @override
  ApiStatus get fetchMoreInvidiousSearchResultStatus;
  @override
  bool get isMoreInvidiousFetchCompleted;
  @override
  int? get page;
  @override
  @JsonKey(ignore: true)
  _$$SearchStateImplCopyWith<_$SearchStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
