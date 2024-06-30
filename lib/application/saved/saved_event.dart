part of 'saved_bloc.dart';

@freezed
class SavedEvent with _$SavedEvent {
  const factory SavedEvent.addVideoInfo({required LocalStoreVideoInfo videoInfo}) = AddVideoInfo;
  const factory SavedEvent.deleteVideoInfo({required String id}) = DeleteVideoInfo;
  const factory SavedEvent.getAllVideoInfoList() = GetAllVideoInfoList;
  const factory SavedEvent.checkVideoInfo({required String id}) = CheckVideoInfo;
}