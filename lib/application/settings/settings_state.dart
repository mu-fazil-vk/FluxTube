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
    required ApiStatus instanceStatus,
    required String instance,
    required String ytService,
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
        instanceStatus: ApiStatus.initial,
        instance: BaseUrl.kBaseUrl,
        ytService: YouTubeServices.piped.name,
      );
}
