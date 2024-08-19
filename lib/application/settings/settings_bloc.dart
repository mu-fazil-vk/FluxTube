import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/core/strings.dart';
import 'package:fluxtube/domain/core/failure/main_failure.dart';
import 'package:fluxtube/core/settings.dart';
import 'package:fluxtube/domain/settings/models/instance.dart';
import 'package:fluxtube/domain/settings/settings_service.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'settings_event.dart';
part 'settings_state.dart';
part 'settings_bloc.freezed.dart';

@injectable
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc(
    SettingsService settingsService,
  ) : super(SettingsState.initialize()) {
    // INITIAIZE SETTINGS
    on<InitializeSettings>((event, emit) async {
      emit(state);
      final List<Map<String, String>> _result =
          await settingsService.initializeSettings();

      // Initialize an empty map to collect settings
      final Map<String, String> settingsMap = {};

      // Iterate through the list and collect settings
      for (var setting in _result) {
        settingsMap.addAll(setting);
      }

      // Extract individual settings
      final String? defaultLanguage = settingsMap[selectedDefaultLanguage];
      final String? defaultQuality = settingsMap[selectedDefaultQuality];
      final String? defaultRegion = settingsMap[selectedDefaultRegion];
      final String defaultThemeMode = settingsMap[selectedTheme] == 'dark'
          ? 'dark'
          : settingsMap[selectedTheme] == 'light'
              ? 'light'
              : 'system';
      final bool defaultHistoryVisibility =
          settingsMap[historyVisibility] == "true";
      final bool defaultDislikeVisibility =
          settingsMap[dislikeVisibility] == "true";
      final bool defaultHlsPlayer = settingsMap[hlsPlayer] == "true";

      final String instanceApi =
          settingsMap[instanceApiUrl] ?? BaseUrl.kBaseUrl;

      final String ytService =
          settingsMap[youtubeService] ?? "piped";

      //package info
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      // Update the state with the collected settings
      var newState = state;

      newState = newState.copyWith(version: packageInfo.version);
      newState = newState.copyWith(instance: instanceApi);
      newState = newState.copyWith(ytService: ytService);
      BaseUrl.kBaseUrl = instanceApi;

      if (defaultLanguage != null) {
        newState = newState.copyWith(defaultLanguage: defaultLanguage);
      }

      if (defaultQuality != null) {
        newState = newState.copyWith(defaultQuality: defaultQuality);
      }

      if (defaultRegion != null) {
        newState = newState.copyWith(defaultRegion: defaultRegion);
      }

      newState = newState.copyWith(themeMode: defaultThemeMode);

      newState = newState.copyWith(
          isHistoryVisible: defaultHistoryVisibility,
          isDislikeVisible: defaultDislikeVisibility,
          isHlsPlayer: defaultHlsPlayer);

      // Emit the new state
      emit(newState);
    });

    // UPDATE LANGUAGE
    on<GetDefaultLanguage>((event, emit) async {
      emit(state);
      final _result = await settingsService.selectDefaultLanguage(
          language: event.language ?? 'en');
      final _state = _result.fold(
          (MainFailure f) =>
              state.copyWith(defaultLanguage: state.defaultLanguage),
          (String language) => state.copyWith(defaultLanguage: language));
      emit(_state);
    });

    // UPDATE QUALITY
    on<GetDefaultQuality>((event, emit) async {
      emit(state);
      final _result = await settingsService.selectDefaultQuality(
          quality: event.quality ?? '360');
      final _state = _result.fold(
          (MainFailure f) =>
              state.copyWith(defaultQuality: state.defaultQuality),
          (String quality) => state.copyWith(defaultQuality: quality));
      emit(_state);
    });

    // UPDATE REGION
    on<GetDefaultRegion>((event, emit) async {
      emit(state);
      final _result =
          await settingsService.selectRegion(region: event.region ?? 'IN');
      final _state = _result.fold((MainFailure f) => state,
          (String region) => state.copyWith(defaultRegion: region));
      emit(_state);
    });

    // TOGGLE THE THEME
    on<ChangeTheme>((event, emit) async {
      emit(state);
      final _result =
          await settingsService.setTheme(themeMode: event.themeMode);
      final _state = _result.fold(
          (MainFailure f) => state.copyWith(themeMode: state.themeMode),
          (String themeMode) => state.copyWith(themeMode: themeMode));
      emit(_state);
    });

    // TOGGLE HISTORY VISIBILITY
    on<ToggleHistoryVisibility>((event, emit) async {
      emit(state);
      final _result = await settingsService.toggleHistoryVisibility(
          isHistoryVisible: !state.isHistoryVisible);
      final _state = _result.fold(
          (MainFailure f) =>
              state.copyWith(isHistoryVisible: state.isHistoryVisible),
          (bool isHistoryVisible) =>
              state.copyWith(isHistoryVisible: isHistoryVisible));
      emit(_state);
    });

    // TOGGLE DISLIKE VISIBILITY
    on<ToggleDislikeVisibility>((event, emit) async {
      emit(state);
      final _result = await settingsService.toggleDislikeVisibility(
          isDislikeVisible: !state.isDislikeVisible);
      final _state = _result.fold(
          (MainFailure f) =>
              state.copyWith(isDislikeVisible: state.isDislikeVisible),
          (bool isDislikeVisible) =>
              state.copyWith(isDislikeVisible: isDislikeVisible));
      emit(_state);
    });

    // TOGGLE HLS PLAYER VISIBILITY
    on<ToggleHlsPlayer>((event, emit) async {
      emit(state);
      final _result = await settingsService.toggleHlsPlayer(
          isHlsPlayer: !state.isHlsPlayer);
      final _state = _result.fold(
          (MainFailure f) => state.copyWith(isHlsPlayer: state.isHlsPlayer),
          (bool isHlsPlayer) => state.copyWith(isHlsPlayer: isHlsPlayer));
      emit(_state);
    });

    // TOGGLE COMMENTS VISIBILITY
    on<ToggleCommentVisibility>((event, emit) async {
      emit(state);
      final _result = await settingsService.toggleHideComments(
          isHideComments: !state.isHideComments);
      final _state = _result.fold(
          (MainFailure f) =>
              state.copyWith(isHideComments: state.isHideComments),
          (bool isHideComments) =>
              state.copyWith(isHideComments: isHideComments));
      emit(_state);
    });

    // TOGGLE RELATED VIDEOS VISIBILITY
    on<ToggleRelatedVideoVisibility>((event, emit) async {
      emit(state);
      final _result = await settingsService.toggleHideRelatedVideos(
          isHideRelated: !state.isHideRelated);
      final _state = _result.fold(
          (MainFailure f) => state.copyWith(isHideRelated: state.isHideRelated),
          (bool isHideRelated) => state.copyWith(isHideRelated: isHideRelated));
      emit(_state);
    });

    on<FetchInstances>((event, emit) async {
      emit(state.copyWith(instanceError: false, instanceLoading: true));
      final _result = await settingsService.fetchInstances();
      final _state = _result.fold(
          (MainFailure f) =>
              state.copyWith(instanceError: true, instanceLoading: false),
          (List<Instance> r) =>
              state.copyWith(instanceLoading: false, instances: r));
      emit(_state);
    });

    on<SetInstance>((event, emit) async {
      final _result =
          await settingsService.setInstance(instanceApi: event.instanceApi);
      final _state = _result.fold(
          (MainFailure f) => state.copyWith(instance: state.instance),
          (String r) => state.copyWith(instance: r));
      emit(_state);
    });

    on<SetYTService>((event, emit) async {
      final _result =
          await settingsService.setTYService(service: event.service);
      final _state = _result.fold(
          (MainFailure f) => state.copyWith(ytService: state.ytService),
          (String r) => state.copyWith(
              ytService: r,));
      emit(_state);
    });
  }
}
