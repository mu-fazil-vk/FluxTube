part of 'saved_bloc.dart';

@freezed
class SavedState with _$SavedState {
  const factory SavedState({
    required ApiStatus savedVideosFetchStatus,
    required LocalStoreVideoInfo? videoInfo,
    required List<LocalStoreVideoInfo> localSavedVideos,
    required List<LocalStoreVideoInfo> localSavedHistoryVideos,
  }) = _Initial;

  factory SavedState.initialize() => const SavedState(
      savedVideosFetchStatus: ApiStatus.initial,
      localSavedVideos: [],
      localSavedHistoryVideos: [],
      videoInfo: null);
}
