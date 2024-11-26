part of 'settings_bloc.dart';

@freezed
class SettingsEvent with _$SettingsEvent {
  factory SettingsEvent.initializeSettings() = InitializeSettings;
  factory SettingsEvent.getDefaultLanguage({required String? language}) =
      GetDefaultLanguage;
  factory SettingsEvent.getDefaultQuality({required String? quality}) =
      GetDefaultQuality;
  factory SettingsEvent.getDefaultRegion({required String? region}) =
      GetDefaultRegion;
  factory SettingsEvent.changeTheme({required String themeMode}) = ChangeTheme;
  factory SettingsEvent.toggleHistoryVisibility() = ToggleHistoryVisibility;
  factory SettingsEvent.toggleDislikeVisibility() = ToggleDislikeVisibility;
  factory SettingsEvent.toggleHlsPlayer() = ToggleHlsPlayer;
  factory SettingsEvent.toggleCommentVisibility() = ToggleCommentVisibility;
  factory SettingsEvent.toggleRelatedVideoVisibility() =
      ToggleRelatedVideoVisibility;
  factory SettingsEvent.fetchPipedInstances() = FetchPipedInstances;
  factory SettingsEvent.fetchInvidiousInstances() = FetchInvidiousInstances;
  factory SettingsEvent.setInstance({required String instanceApi}) =
      SetInstance;
  factory SettingsEvent.setYTService({required YouTubeServices service}) =
      SetYTService;
}
