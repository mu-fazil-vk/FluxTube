import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/core/enums.dart';
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
      emit(state.copyWith(settingsStatus: ApiStatus.loading));
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

      final String ytService =
          settingsMap[youtubeService] ?? YouTubeServices.explode.name;

      final String instanceApi;
      if (ytService == YouTubeServices.piped.name) {
        instanceApi = settingsMap[instanceApiUrl] ?? BaseUrl.kBaseUrl;
      } else {
        instanceApi = settingsMap[instanceApiUrl] ?? BaseUrl.kInvidiousBaseUrl;
      }

      //package info
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      // Update the state with the collected settings
      var newState = state;

      newState = newState.copyWith(instance: instanceApi);
      newState = newState.copyWith(ytService: ytService);

      if (defaultLanguage != null) {
        newState = newState.copyWith(defaultLanguage: defaultLanguage);
      }

      if (defaultQuality != null) {
        newState = newState.copyWith(defaultQuality: defaultQuality);
      }

      if (defaultRegion != null) {
        newState = newState.copyWith(defaultRegion: defaultRegion);
      }

      newState = newState.copyWith(
          version: packageInfo.version,
          themeMode: defaultThemeMode,
          isHistoryVisible: defaultHistoryVisibility,
          isDislikeVisible: defaultDislikeVisibility,
          isHlsPlayer: defaultHlsPlayer,
          initialized: true);

      if (ytService == YouTubeServices.piped.name) {
        BaseUrl.updateBaseUrl(instanceApi);
      } else {
        BaseUrl.updateInvidiousBaseUrl(instanceApi);
      }

      // Emit the new state
      emit(newState.copyWith(settingsStatus: ApiStatus.loaded));
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

    on<FetchPipedInstances>((event, emit) async {
      if (state.pipedInstances.isNotEmpty) {
        return emit(state);
      }
      emit(state.copyWith(
        pipedInstanceStatus: ApiStatus.loading,
      ));
      final _result = await settingsService.fetchInstances();
      final _state = _result.fold(
          (MainFailure f) => state.copyWith(
              pipedInstanceStatus: ApiStatus.error,
              pipedInstances: state.pipedInstances), (List<Instance> r) {
        if (state.ytService == YouTubeServices.piped.name) {
          final instance = r.firstWhere(
              (element) => element.api == state.instance,
              orElse: () => r.first);

          BaseUrl.updateBaseUrl(instance.api);

          return state.copyWith(
              pipedInstanceStatus: ApiStatus.loaded,
              pipedInstances: r,
              instance: instance.api);
        } else {
          return state.copyWith(
              pipedInstanceStatus: ApiStatus.loaded, pipedInstances: r);
        }
      });
      emit(_state);
      add(SetInstance(instanceApi: state.instance));
    });

    on<SetInstance>((event, emit) async {
      final _result =
          await settingsService.setInstance(instanceApi: event.instanceApi);
      final _state = _result
          .fold((MainFailure f) => state.copyWith(instance: state.instance),
              (String r) {
        if (state.ytService == YouTubeServices.piped.name) {
          BaseUrl.updateBaseUrl(r);
        } else {
          BaseUrl.updateInvidiousBaseUrl(r);
        }
        return state.copyWith(instance: r);
      });
      emit(_state);
    });

    on<FetchInvidiousInstances>((event, emit) async {
      if (state.invidiousInstances.isNotEmpty) {
        return emit(state);
      }
      emit(state.copyWith(
        invidiousInstanceStatus: ApiStatus.loading,
      ));
      final _result = await settingsService.fetchInvidiousInstances();
      final _state = _result.fold(
          (MainFailure f) => state.copyWith(
              invidiousInstanceStatus: ApiStatus.error,
              invidiousInstances: state.invidiousInstances),
          (List<Instance> r) {
        if (state.ytService != YouTubeServices.piped.name) {
          final instance = r.firstWhere(
              (element) => element.api == state.instance,
              orElse: () => r.first);

          BaseUrl.updateInvidiousBaseUrl(instance.api);

          return state.copyWith(
              invidiousInstanceStatus: ApiStatus.loaded,
              invidiousInstances: r,
              instance: instance.api);
        } else {
          return state.copyWith(
              invidiousInstanceStatus: ApiStatus.loaded,
              invidiousInstances: r);
        }
      });
      emit(_state);
      add(SetInstance(instanceApi: state.instance));
    });

    on<SetYTService>((event, emit) async {
      final _result =
          await settingsService.setTYService(service: event.service);
      final _state = _result.fold(
          (MainFailure f) => state.copyWith(ytService: state.ytService),
          (YouTubeServices r) => state.copyWith(
                ytService: r.name,
              ));
      emit(_state);
    });
  }
}
