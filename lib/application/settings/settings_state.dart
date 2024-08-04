part of 'settings_bloc.dart';

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState({
    required String defaultLanguage,
    required String defaultQuality,
    required String defaultRegion,
    required String themeMode,
    required String? version,
    required bool isHistoryVisible,
    required bool isDislikeVisible,
    required bool isHlsPlayer,
    required bool isHideComments,
    required bool isHideRelated,
    required List<Instance> instances,
    required bool instanceLoading,
    required bool instanceError,
    required String instance

  }) = _Initial;

  factory SettingsState.initialize() => SettingsState(
        defaultLanguage: 'en',
        defaultQuality: '720p',
        defaultRegion: 'IN',
        themeMode: 'system',
        version: "",
        isHistoryVisible: true,
        isDislikeVisible: false,
        isHlsPlayer: true,
        isHideComments: false,
        isHideRelated: false,
        instances: [],
        instanceLoading: false,
        instanceError: false,
        instance: BaseUrl.kBaseUrl
      );
}
