import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/core/enums.dart';
import 'package:fluxtube/domain/core/failure/main_failure.dart';
import 'package:fluxtube/domain/saved/saved_services.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../core/operations/math_operations.dart';
import '../../domain/saved/models/local_store.dart';

part 'saved_event.dart';
part 'saved_state.dart';
part 'saved_bloc.freezed.dart';

@injectable
class SavedBloc extends Bloc<SavedEvent, SavedState> {
  SavedBloc(
    SavedServices _savedServices,
  ) : super(SavedState.initialize()) {
    // get all videos from local storage
    on<GetAllVideoInfoList>((event, emit) async {
      //initial loading go ui
      emit(state.copyWith(savedVideosFetchStatus: ApiStatus.loading));

      //get video list
      final _result = await _savedServices.getVideoInfoList();
      final _state = _result.fold(
          (MainFailure f) => state.copyWith(savedVideosFetchStatus: ApiStatus.error),
          (List<LocalStoreVideoInfo> resp) {
        final List<LocalStoreVideoInfo> historyVideos =
            resp.where((e) => e.isHistory ?? false).toList();
        final List<LocalStoreVideoInfo> savedVideos =
            resp.where((e) => e.isSaved ?? false).toList();

        return state.copyWith(
            savedVideosFetchStatus: ApiStatus.loaded,
            localSavedVideos: savedVideos,
            localSavedHistoryVideos: historyVideos);
      });

      // update to ui
      emit(_state);
    });

    // add video data to local storage
    on<AddVideoInfo>((event, emit) async {
      //initial loading go ui
      emit(state.copyWith(savedVideosFetchStatus: ApiStatus.loading,));

      //add video info
      final _result =
          await _savedServices.addVideoInfo(videoInfo: event.videoInfo);
      final _state = _result.fold(
          (MainFailure f) => state.copyWith(savedVideosFetchStatus: ApiStatus.error),
          (List<LocalStoreVideoInfo> resp) {
        final List<LocalStoreVideoInfo> historyVideos =
            resp.where((e) => e.isHistory ?? false).toList();
        final List<LocalStoreVideoInfo> savedVideos =
            resp.where((e) => e.isSaved ?? false).toList();

        return state.copyWith(
            savedVideosFetchStatus: ApiStatus.loaded,
            localSavedVideos: savedVideos,
            localSavedHistoryVideos: historyVideos);
      });

      // update to ui
      emit(_state);
      // Add CheckVideoInfo event to verify and update the state
      add(CheckVideoInfo(id: event.videoInfo.id));
    });

    // delete video data from local storage
    on<DeleteVideoInfo>((event, emit) async {
      //initial loading go ui
      emit(state.copyWith(savedVideosFetchStatus: ApiStatus.loading,));

      //delete video info , fast hash for covert string id to int hash
      final _result =
          await _savedServices.deleteVideoInfo(id: fastHash(event.id));
      final _state = _result.fold(
          (MainFailure f) => state.copyWith(savedVideosFetchStatus: ApiStatus.error),
          (List<LocalStoreVideoInfo> resp) {
        final List<LocalStoreVideoInfo> historyVideos =
            resp.where((e) => e.isHistory ?? false).toList();
        final List<LocalStoreVideoInfo> savedVideos =
            resp.where((e) => e.isSaved ?? false).toList();

        return state.copyWith(
            savedVideosFetchStatus: ApiStatus.loaded,
            localSavedVideos: savedVideos,
            localSavedHistoryVideos: historyVideos);
      });

      // update to ui
      emit(_state);
      add(CheckVideoInfo(id: event.id));
    });

    // check the playing video present in the saved video
    // delete video data from local storage
    on<CheckVideoInfo>((event, emit) async {
      //initialize with empty
      emit(state.copyWith(videoInfo: null));

      final _result = await _savedServices.checkVideoInfo(id: event.id);
      final _state = _result.fold(
          (MainFailure f) => state.copyWith(videoInfo: null),
          (LocalStoreVideoInfo resp) => state.copyWith(videoInfo: resp));

      // update to ui
      emit(_state);
    });
  }
}
