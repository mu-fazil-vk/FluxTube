part of 'settings_bloc.dart';

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState({
    required String defaultLanguage,
    required String defaultQuality,
    required String defaultRegion,
    required bool isDarkTheme,
    required String? version,
    required bool isHistoryVisible,
    required bool isDislikeVisible,
    required bool isHlsPlayer,
  }) = _Initial;

  factory SettingsState.initialize() => const SettingsState(
        defaultLanguage: 'en',
        defaultQuality: '720p',
        defaultRegion: 'IN',
        isDarkTheme: true,
        version: "",
        isHistoryVisible: true,
        isDislikeVisible: false,
        isHlsPlayer: true,
      );
}
