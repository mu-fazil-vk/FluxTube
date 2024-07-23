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
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String query, String? filter) getSearchResult,
    required TResult Function(String query, String? filter, String? nextPage)
        getMoreSearchResult,
    required TResult Function(String query) getSearchSuggestion,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String query, String? filter)? getSearchResult,
    TResult? Function(String query, String? filter, String? nextPage)?
        getMoreSearchResult,
    TResult? Function(String query)? getSearchSuggestion,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String query, String? filter)? getSearchResult,
    TResult Function(String query, String? filter, String? nextPage)?
        getMoreSearchResult,
    TResult Function(String query)? getSearchSuggestion,
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
  $Res call({String query});
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
  }) {
    return _then(_value.copyWith(
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
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
  $Res call({String query, String? filter});
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
    ));
  }
}

/// @nodoc

class _$GetSearchResultImpl implements GetSearchResult {
  const _$GetSearchResultImpl({required this.query, required this.filter});

  @override
  final String query;
  @override
  final String? filter;

  @override
  String toString() {
    return 'SearchEvent.getSearchResult(query: $query, filter: $filter)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetSearchResultImpl &&
            (identical(other.query, query) || other.query == query) &&
            (identical(other.filter, filter) || other.filter == filter));
  }

  @override
  int get hashCode => Object.hash(runtimeType, query, filter);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetSearchResultImplCopyWith<_$GetSearchResultImpl> get copyWith =>
      __$$GetSearchResultImplCopyWithImpl<_$GetSearchResultImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String query, String? filter) getSearchResult,
    required TResult Function(String query, String? filter, String? nextPage)
        getMoreSearchResult,
    required TResult Function(String query) getSearchSuggestion,
  }) {
    return getSearchResult(query, filter);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String query, String? filter)? getSearchResult,
    TResult? Function(String query, String? filter, String? nextPage)?
        getMoreSearchResult,
    TResult? Function(String query)? getSearchSuggestion,
  }) {
    return getSearchResult?.call(query, filter);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String query, String? filter)? getSearchResult,
    TResult Function(String query, String? filter, String? nextPage)?
        getMoreSearchResult,
    TResult Function(String query)? getSearchSuggestion,
    required TResult orElse(),
  }) {
    if (getSearchResult != null) {
      return getSearchResult(query, filter);
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
      required final String? filter}) = _$GetSearchResultImpl;

  @override
  String get query;
  String? get filter;
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
  $Res call({String query, String? filter, String? nextPage});
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
    ));
  }
}

/// @nodoc

class _$GetMoreSearchResultImpl implements GetMoreSearchResult {
  const _$GetMoreSearchResultImpl(
      {required this.query, required this.filter, required this.nextPage});

  @override
  final String query;
  @override
  final String? filter;
  @override
  final String? nextPage;

  @override
  String toString() {
    return 'SearchEvent.getMoreSearchResult(query: $query, filter: $filter, nextPage: $nextPage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetMoreSearchResultImpl &&
            (identical(other.query, query) || other.query == query) &&
            (identical(other.filter, filter) || other.filter == filter) &&
            (identical(other.nextPage, nextPage) ||
                other.nextPage == nextPage));
  }

  @override
  int get hashCode => Object.hash(runtimeType, query, filter, nextPage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetMoreSearchResultImplCopyWith<_$GetMoreSearchResultImpl> get copyWith =>
      __$$GetMoreSearchResultImplCopyWithImpl<_$GetMoreSearchResultImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String query, String? filter) getSearchResult,
    required TResult Function(String query, String? filter, String? nextPage)
        getMoreSearchResult,
    required TResult Function(String query) getSearchSuggestion,
  }) {
    return getMoreSearchResult(query, filter, nextPage);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String query, String? filter)? getSearchResult,
    TResult? Function(String query, String? filter, String? nextPage)?
        getMoreSearchResult,
    TResult? Function(String query)? getSearchSuggestion,
  }) {
    return getMoreSearchResult?.call(query, filter, nextPage);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String query, String? filter)? getSearchResult,
    TResult Function(String query, String? filter, String? nextPage)?
        getMoreSearchResult,
    TResult Function(String query)? getSearchSuggestion,
    required TResult orElse(),
  }) {
    if (getMoreSearchResult != null) {
      return getMoreSearchResult(query, filter, nextPage);
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
      required final String? nextPage}) = _$GetMoreSearchResultImpl;

  @override
  String get query;
  String? get filter;
  String? get nextPage;
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
  $Res call({String query});
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
  }) {
    return _then(_$GetSearchSuggestionImpl(
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$GetSearchSuggestionImpl implements GetSearchSuggestion {
  const _$GetSearchSuggestionImpl({required this.query});

  @override
  final String query;

  @override
  String toString() {
    return 'SearchEvent.getSearchSuggestion(query: $query)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetSearchSuggestionImpl &&
            (identical(other.query, query) || other.query == query));
  }

  @override
  int get hashCode => Object.hash(runtimeType, query);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetSearchSuggestionImplCopyWith<_$GetSearchSuggestionImpl> get copyWith =>
      __$$GetSearchSuggestionImplCopyWithImpl<_$GetSearchSuggestionImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String query, String? filter) getSearchResult,
    required TResult Function(String query, String? filter, String? nextPage)
        getMoreSearchResult,
    required TResult Function(String query) getSearchSuggestion,
  }) {
    return getSearchSuggestion(query);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String query, String? filter)? getSearchResult,
    TResult? Function(String query, String? filter, String? nextPage)?
        getMoreSearchResult,
    TResult? Function(String query)? getSearchSuggestion,
  }) {
    return getSearchSuggestion?.call(query);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String query, String? filter)? getSearchResult,
    TResult Function(String query, String? filter, String? nextPage)?
        getMoreSearchResult,
    TResult Function(String query)? getSearchSuggestion,
    required TResult orElse(),
  }) {
    if (getSearchSuggestion != null) {
      return getSearchSuggestion(query);
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
  const factory GetSearchSuggestion({required final String query}) =
      _$GetSearchSuggestionImpl;

  @override
  String get query;
  @override
  @JsonKey(ignore: true)
  _$$GetSearchSuggestionImplCopyWith<_$GetSearchSuggestionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SearchState {
  SearchResp? get result => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isError => throw _privateConstructorUsedError;
  List<dynamic> get suggestions => throw _privateConstructorUsedError;
  bool get isSuggestionError => throw _privateConstructorUsedError;
  bool get isSuggestionDisplay => throw _privateConstructorUsedError;
  bool get isMoreFetchLoading => throw _privateConstructorUsedError;
  bool get isMoreFetchError => throw _privateConstructorUsedError;
  bool get isMoreFetchCompleted => throw _privateConstructorUsedError;

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
      {SearchResp? result,
      bool isLoading,
      bool isError,
      List<dynamic> suggestions,
      bool isSuggestionError,
      bool isSuggestionDisplay,
      bool isMoreFetchLoading,
      bool isMoreFetchError,
      bool isMoreFetchCompleted});
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
    Object? result = freezed,
    Object? isLoading = null,
    Object? isError = null,
    Object? suggestions = null,
    Object? isSuggestionError = null,
    Object? isSuggestionDisplay = null,
    Object? isMoreFetchLoading = null,
    Object? isMoreFetchError = null,
    Object? isMoreFetchCompleted = null,
  }) {
    return _then(_value.copyWith(
      result: freezed == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as SearchResp?,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isError: null == isError
          ? _value.isError
          : isError // ignore: cast_nullable_to_non_nullable
              as bool,
      suggestions: null == suggestions
          ? _value.suggestions
          : suggestions // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      isSuggestionError: null == isSuggestionError
          ? _value.isSuggestionError
          : isSuggestionError // ignore: cast_nullable_to_non_nullable
              as bool,
      isSuggestionDisplay: null == isSuggestionDisplay
          ? _value.isSuggestionDisplay
          : isSuggestionDisplay // ignore: cast_nullable_to_non_nullable
              as bool,
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
abstract class _$$SearchStateImplCopyWith<$Res>
    implements $SearchStateCopyWith<$Res> {
  factory _$$SearchStateImplCopyWith(
          _$SearchStateImpl value, $Res Function(_$SearchStateImpl) then) =
      __$$SearchStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {SearchResp? result,
      bool isLoading,
      bool isError,
      List<dynamic> suggestions,
      bool isSuggestionError,
      bool isSuggestionDisplay,
      bool isMoreFetchLoading,
      bool isMoreFetchError,
      bool isMoreFetchCompleted});
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
    Object? result = freezed,
    Object? isLoading = null,
    Object? isError = null,
    Object? suggestions = null,
    Object? isSuggestionError = null,
    Object? isSuggestionDisplay = null,
    Object? isMoreFetchLoading = null,
    Object? isMoreFetchError = null,
    Object? isMoreFetchCompleted = null,
  }) {
    return _then(_$SearchStateImpl(
      result: freezed == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as SearchResp?,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isError: null == isError
          ? _value.isError
          : isError // ignore: cast_nullable_to_non_nullable
              as bool,
      suggestions: null == suggestions
          ? _value._suggestions
          : suggestions // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      isSuggestionError: null == isSuggestionError
          ? _value.isSuggestionError
          : isSuggestionError // ignore: cast_nullable_to_non_nullable
              as bool,
      isSuggestionDisplay: null == isSuggestionDisplay
          ? _value.isSuggestionDisplay
          : isSuggestionDisplay // ignore: cast_nullable_to_non_nullable
              as bool,
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

class _$SearchStateImpl implements _SearchState {
  const _$SearchStateImpl(
      {required this.result,
      required this.isLoading,
      required this.isError,
      required final List<dynamic> suggestions,
      required this.isSuggestionError,
      required this.isSuggestionDisplay,
      required this.isMoreFetchLoading,
      required this.isMoreFetchError,
      required this.isMoreFetchCompleted})
      : _suggestions = suggestions;

  @override
  final SearchResp? result;
  @override
  final bool isLoading;
  @override
  final bool isError;
  final List<dynamic> _suggestions;
  @override
  List<dynamic> get suggestions {
    if (_suggestions is EqualUnmodifiableListView) return _suggestions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_suggestions);
  }

  @override
  final bool isSuggestionError;
  @override
  final bool isSuggestionDisplay;
  @override
  final bool isMoreFetchLoading;
  @override
  final bool isMoreFetchError;
  @override
  final bool isMoreFetchCompleted;

  @override
  String toString() {
    return 'SearchState(result: $result, isLoading: $isLoading, isError: $isError, suggestions: $suggestions, isSuggestionError: $isSuggestionError, isSuggestionDisplay: $isSuggestionDisplay, isMoreFetchLoading: $isMoreFetchLoading, isMoreFetchError: $isMoreFetchError, isMoreFetchCompleted: $isMoreFetchCompleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchStateImpl &&
            (identical(other.result, result) || other.result == result) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isError, isError) || other.isError == isError) &&
            const DeepCollectionEquality()
                .equals(other._suggestions, _suggestions) &&
            (identical(other.isSuggestionError, isSuggestionError) ||
                other.isSuggestionError == isSuggestionError) &&
            (identical(other.isSuggestionDisplay, isSuggestionDisplay) ||
                other.isSuggestionDisplay == isSuggestionDisplay) &&
            (identical(other.isMoreFetchLoading, isMoreFetchLoading) ||
                other.isMoreFetchLoading == isMoreFetchLoading) &&
            (identical(other.isMoreFetchError, isMoreFetchError) ||
                other.isMoreFetchError == isMoreFetchError) &&
            (identical(other.isMoreFetchCompleted, isMoreFetchCompleted) ||
                other.isMoreFetchCompleted == isMoreFetchCompleted));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      result,
      isLoading,
      isError,
      const DeepCollectionEquality().hash(_suggestions),
      isSuggestionError,
      isSuggestionDisplay,
      isMoreFetchLoading,
      isMoreFetchError,
      isMoreFetchCompleted);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchStateImplCopyWith<_$SearchStateImpl> get copyWith =>
      __$$SearchStateImplCopyWithImpl<_$SearchStateImpl>(this, _$identity);
}

abstract class _SearchState implements SearchState {
  const factory _SearchState(
      {required final SearchResp? result,
      required final bool isLoading,
      required final bool isError,
      required final List<dynamic> suggestions,
      required final bool isSuggestionError,
      required final bool isSuggestionDisplay,
      required final bool isMoreFetchLoading,
      required final bool isMoreFetchError,
      required final bool isMoreFetchCompleted}) = _$SearchStateImpl;

  @override
  SearchResp? get result;
  @override
  bool get isLoading;
  @override
  bool get isError;
  @override
  List<dynamic> get suggestions;
  @override
  bool get isSuggestionError;
  @override
  bool get isSuggestionDisplay;
  @override
  bool get isMoreFetchLoading;
  @override
  bool get isMoreFetchError;
  @override
  bool get isMoreFetchCompleted;
  @override
  @JsonKey(ignore: true)
  _$$SearchStateImplCopyWith<_$SearchStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
