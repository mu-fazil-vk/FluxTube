part of 'subscribe_bloc.dart';

@freezed
class SubscribeEvent with _$SubscribeEvent {
  const factory SubscribeEvent.addSubscribe({required Subscribe channelInfo}) = AddSubscribe;
  const factory SubscribeEvent.deleteSubscribeInfo({required String id}) = DeleteSubscribeInfo;
  const factory SubscribeEvent.getAllSubscribeList() = GetAllSubscribeList;
  const factory SubscribeEvent.checkSubscribeInfo({required String id}) = CheckSubscribeInfo;
}