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
    required List<Instance> pipedInstances,
    required ApiStatus pipedInstanceStatus,
    required String instance,
    required List<Instance> invidiousInstances,
    required ApiStatus invidiousInstanceStatus,
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
        pipedInstances: [],
        pipedInstanceStatus: ApiStatus.initial,
        // set by home (commom for piped and invidious)
        instance: BaseUrl.kBaseUrl,
        invidiousInstances: [],
        invidiousInstanceStatus: ApiStatus.initial,
        ytService: YouTubeServices.explode.name,
      );
}
