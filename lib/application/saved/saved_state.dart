part of 'saved_bloc.dart';

@freezed
class SavedState with _$SavedState {
  const factory SavedState({
    required bool isLoading,
    required bool isError,
    required LocalStoreVideoInfo? videoInfo,
    required List<LocalStoreVideoInfo> localSavedVideos,
    required List<LocalStoreVideoInfo> localSavedHistoryVideos,
  }) = _Initial;

   factory SavedState.initialize() => const SavedState(isLoading: false, isError: false, localSavedVideos: [], localSavedHistoryVideos: [], videoInfo: null);
}
