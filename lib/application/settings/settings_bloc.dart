import 'dart:io';
import 'dart:developer';

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
      const knownThemes = {'dark', 'light', 'oled', 'dynamic', 'system'};
      final String defaultThemeMode =
          knownThemes.contains(settingsMap[selectedTheme])
              ? settingsMap[selectedTheme]!
              : 'system';
      final bool defaultHistoryVisibility =
          settingsMap[historyVisibility] == "true";
      final bool defaultDislikeVisibility =
          settingsMap[dislikeVisibility] == "true";
      final bool defaultHlsPlayer = settingsMap[hlsPlayer] == "true";
      final bool isPipDisabled = settingsMap[pipDisabled] == "true";

      var ytService =
          settingsMap[youtubeService] ?? YouTubeServices.newpipe.name;
      final migrated =
          removedYouTubeServices.any((s) => s.name == ytService);
      if (migrated) {
        ytService = Platform.isAndroid
            ? YouTubeServices.newpipe.name
            : YouTubeServices.invidious.name;
        await settingsService.setTYService(
            service: YouTubeServices.values.byName(ytService));
      }

      final String instanceApi;
      log('YT Service: $ytService');
      if (ytService == YouTubeServices.invidious.name) {
        // A migrated user's stored instance belongs to the removed provider.
        instanceApi = migrated
            ? BaseUrl.kInvidiousBaseUrl
            : settingsMap[instanceApiUrl] ?? BaseUrl.kInvidiousBaseUrl;
      } else {
        instanceApi = settingsMap[instanceApiUrl] ?? BaseUrl.kBaseUrl;
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
      // Search history settings
      final bool searchHistoryEnabled =
          settingsMap[searchHistoryEnabledKey] != "false";
      final bool searchHistoryVisible =
          settingsMap[searchHistoryVisibilityKey] != "false";

      // Auto PiP setting (default true)
      final bool autoPipEnabled =
          settingsMap[autoPipEnabledKey] != "false";

      // SponsorBlock settings
      final bool sponsorBlockEnabled =
          settingsMap[sponsorBlockEnabledKey] == "true";
      final List<String> sponsorBlockCats = settingsMap[sponsorBlockCategoriesKey] != null
          ? settingsMap[sponsorBlockCategoriesKey]!.split(',')
          : ['sponsor', 'intro', 'outro', 'selfpromo'];

      // Subtitle size
      final double subtitleSizeValue = double.tryParse(
          settingsMap[subtitleSizeKey] ?? '32.0') ?? 32.0;

      // Comments and Related Videos visibility
      final bool hideComments = settingsMap[commentsVisibility] == "true";
      final bool hideRelated = settingsMap[relatedVideoVisibility] == "true";

      // Home feed mode
      final String homeFeed = settingsMap[homeFeedModeKey] ?? HomeFeedMode.feedOrTrending.name;

      // Video fit mode
      final String videoFit = settingsMap[videoFitModeKey] ?? 'contain';

      // Skip interval
      final int skipIntervalValue = int.tryParse(settingsMap[skipIntervalKey] ?? '10') ?? 10;

      // Open links in browser
      final bool openInBrowser = settingsMap[openLinksInBrowserKey] == "true";

      // Audio focus
      final bool audioFocusEnabled = settingsMap[audioFocusEnabledKey] != "false";

      newState = newState.copyWith(
        version: packageInfo.version,
        themeMode: defaultThemeMode,
        isHistoryVisible: defaultHistoryVisibility,
        isDislikeVisible: defaultDislikeVisibility,
        isHlsPlayer: defaultHlsPlayer,
        initialized: true,
        isPipDisabled: isPipDisabled,
        isSearchHistoryEnabled: searchHistoryEnabled,
        isSearchHistoryVisible: searchHistoryVisible,
        isAutoPipEnabled: autoPipEnabled,
        isSponsorBlockEnabled: sponsorBlockEnabled,
        sponsorBlockCategories: sponsorBlockCats,
        subtitleSize: subtitleSizeValue,
        isHideComments: hideComments,
        isHideRelated: hideRelated,
        homeFeedMode: homeFeed,
        videoFitMode: videoFit,
        skipInterval: skipIntervalValue,
        openLinksInBrowser: openInBrowser,
        isAudioFocusEnabled: audioFocusEnabled,
      );

      if (ytService == YouTubeServices.invidious.name) {
        BaseUrl.updateInvidiousBaseUrl(instanceApi);
      } else {
        BaseUrl.updateBaseUrl(instanceApi);
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
      log('Region: ${event.region}');
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
          (bool isHlsPlayer) {
        return state.copyWith(isHlsPlayer: isHlsPlayer);
      });
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
      if (state.pipedInstances.isNotEmpty && !event.forceRefresh) {
        return emit(state);
      }

      // Store user's preferred instance to check if it fails
      final userPreferredInstance = state.instance;
      String? userPreferredInstanceName;

      emit(state.copyWith(
        pipedInstanceStatus: ApiStatus.loading,
        isTestingConnection: true,
        connectingToInstance: 'Fetching instances...',
        userInstanceFailed: false,
        failedInstanceName: null,
      ));

      final _result = await settingsService.fetchInstances();

      if (_result.isLeft()) {
        emit(state.copyWith(
          pipedInstanceStatus: ApiStatus.error,
          pipedInstances: state.pipedInstances,
          isTestingConnection: false,
          connectingToInstance: null,
        ));
        return;
      }

      final instances = _result.getOrElse(() => []);

      // Find the name of user's preferred instance
      final preferredInst = instances.where((i) => i.api == userPreferredInstance).firstOrNull;
      userPreferredInstanceName = preferredInst?.name;

      if (state.ytService != YouTubeServices.invidious.name) {
        // Try user's preferred instance first, then find other working instances
        final workingInstanceResult = await settingsService.findWorkingPipedInstance(
          instances: instances,
          preferredInstanceApi: userPreferredInstance,
          onTestingInstance: (instanceName) {
            emit(state.copyWith(
              pipedInstanceStatus: ApiStatus.loading,
              pipedInstances: instances,
              isTestingConnection: true,
              connectingToInstance: instanceName,
            ));
          },
        );

        final workingResult = workingInstanceResult.fold(
          (failure) {
            log('No working piped instance found, using first available');
            return (
              api: instances.isNotEmpty ? instances.first.api : state.instance,
              found: false,
              userFailed: true,
            );
          },
          (workingApi) {
            log('Found working piped instance: $workingApi');
            // Check if user's preferred instance failed (working instance is different)
            final userFailed = userPreferredInstance.isNotEmpty &&
                workingApi != userPreferredInstance;
            return (api: workingApi, found: true, userFailed: userFailed);
          },
        );

        BaseUrl.updateBaseUrl(workingResult.api);

        emit(state.copyWith(
          pipedInstanceStatus: workingResult.found ? ApiStatus.loaded : ApiStatus.error,
          pipedInstances: instances,
          instance: workingResult.api,
          isTestingConnection: false,
          connectingToInstance: null,
          userInstanceFailed: workingResult.userFailed,
          failedInstanceName: workingResult.userFailed ? userPreferredInstanceName : null,
        ));
      } else {
        emit(state.copyWith(
          pipedInstanceStatus: ApiStatus.loaded,
          pipedInstances: instances,
          isTestingConnection: false,
          connectingToInstance: null,
        ));
      }

      add(SetInstance(instanceApi: state.instance));
    });

    on<SetInstance>((event, emit) async {
      final _result =
          await settingsService.setInstance(instanceApi: event.instanceApi);
      final _state = _result
          .fold((MainFailure f) => state.copyWith(instance: state.instance),
              (String r) {
        if (state.ytService == YouTubeServices.invidious.name) {
          BaseUrl.updateInvidiousBaseUrl(r);
        } else {
          BaseUrl.updateBaseUrl(r);
        }
        return state.copyWith(instance: r);
      });
      emit(_state);
    });

    on<FetchInvidiousInstances>((event, emit) async {
      if (state.invidiousInstances.isNotEmpty && !event.forceRefresh) {
        return emit(state);
      }

      // Store user's preferred instance to check if it fails
      final userPreferredInstance = state.instance;
      String? userPreferredInstanceName;

      emit(state.copyWith(
        invidiousInstanceStatus: ApiStatus.loading,
        isTestingConnection: true,
        connectingToInstance: 'Fetching instances...',
        userInstanceFailed: false,
        failedInstanceName: null,
      ));

      final _result = await settingsService.fetchInvidiousInstances();

      if (_result.isLeft()) {
        emit(state.copyWith(
          invidiousInstanceStatus: ApiStatus.error,
          invidiousInstances: state.invidiousInstances,
          isTestingConnection: false,
          connectingToInstance: null,
        ));
        return;
      }

      final instances = _result.getOrElse(() => []);

      // Find the name of user's preferred instance
      final preferredInst = instances.where((i) => i.api == userPreferredInstance).firstOrNull;
      userPreferredInstanceName = preferredInst?.name;

      if (state.ytService == YouTubeServices.invidious.name) {
        // Try user's preferred instance first, then find other working instances
        final workingInstanceResult = await settingsService.findWorkingInvidiousInstance(
          instances: instances,
          preferredInstanceApi: userPreferredInstance,
          onTestingInstance: (instanceName) {
            emit(state.copyWith(
              invidiousInstanceStatus: ApiStatus.loading,
              invidiousInstances: instances,
              isTestingConnection: true,
              connectingToInstance: instanceName,
            ));
          },
        );

        final workingResult = workingInstanceResult.fold(
          (failure) {
            log('No working invidious instance found, using first available');
            return (
              api: instances.isNotEmpty ? instances.first.api : state.instance,
              found: false,
              userFailed: true,
            );
          },
          (workingApi) {
            log('Found working invidious instance: $workingApi');
            // Check if user's preferred instance failed (working instance is different)
            final userFailed = userPreferredInstance.isNotEmpty &&
                workingApi != userPreferredInstance;
            return (api: workingApi, found: true, userFailed: userFailed);
          },
        );

        BaseUrl.updateInvidiousBaseUrl(workingResult.api);

        emit(state.copyWith(
          invidiousInstanceStatus: workingResult.found ? ApiStatus.loaded : ApiStatus.error,
          invidiousInstances: instances,
          instance: workingResult.api,
          isTestingConnection: false,
          connectingToInstance: null,
          userInstanceFailed: workingResult.userFailed,
          failedInstanceName: workingResult.userFailed ? userPreferredInstanceName : null,
        ));
      } else {
        emit(state.copyWith(
          invidiousInstanceStatus: ApiStatus.loaded,
          invidiousInstances: instances,
          isTestingConnection: false,
          connectingToInstance: null,
        ));
      }

      add(SetInstance(instanceApi: state.instance));
    });

    on<SetYTService>((event, emit) async {
      final _result =
          await settingsService.setTYService(service: event.service);
      final _state = _result.fold(
          (MainFailure f) => state.copyWith(ytService: state.ytService),
          (YouTubeServices r) {
        // state.instance still belongs to the previous provider here; feeding
        // it to the new one made the first load hit the wrong host. Start
        // from the provider's own base URL — instance failover refines it.
        if (r == YouTubeServices.invidious) {
          return state.copyWith(
              ytService: r.name, instance: BaseUrl.kInvidiousBaseUrl);
        }
        if (r.name == state.ytService) return state;
        return state.copyWith(ytService: r.name, instance: BaseUrl.kBaseUrl);
      });
      emit(_state);
    });

    on<TogglePipPlayer>((event, emit) async {
      final _result = await settingsService.togglePipPlayer(
          isPipDisabled: !state.isPipDisabled);
      final _state = _result.fold(
          (MainFailure f) => state.copyWith(isPipDisabled: state.isPipDisabled),
          (bool r) => state.copyWith(isPipDisabled: r));
      emit(_state);
    });

    // New event handlers for additional features

    on<SetSearchFilter>((event, emit) async {
      final _result = await settingsService.setSearchFilter(filter: event.filter);
      final _state = _result.fold(
          (MainFailure f) => state.copyWith(searchFilter: state.searchFilter),
          (String filter) => state.copyWith(searchFilter: filter));
      emit(_state);
    });

    on<SetVideoFitMode>((event, emit) async {
      final _result = await settingsService.setVideoFitMode(fitMode: event.fitMode);
      final _state = _result.fold(
          (MainFailure f) => state.copyWith(videoFitMode: state.videoFitMode),
          (String fitMode) => state.copyWith(videoFitMode: fitMode));
      emit(_state);
    });

    on<SetSkipInterval>((event, emit) async {
      final _result = await settingsService.setSkipInterval(seconds: event.seconds);
      final _state = _result.fold(
          (MainFailure f) => state.copyWith(skipInterval: state.skipInterval),
          (int seconds) => state.copyWith(skipInterval: seconds));
      emit(_state);
    });

    on<ToggleSponsorBlock>((event, emit) async {
      final _result = await settingsService.toggleSponsorBlock(
          isEnabled: !state.isSponsorBlockEnabled);
      final _state = _result.fold(
          (MainFailure f) => state.copyWith(isSponsorBlockEnabled: state.isSponsorBlockEnabled),
          (bool isEnabled) => state.copyWith(isSponsorBlockEnabled: isEnabled));
      emit(_state);
    });

    on<SetSponsorBlockCategories>((event, emit) async {
      final _result = await settingsService.setSponsorBlockCategories(
          categories: event.categories);
      final _state = _result.fold(
          (MainFailure f) => state.copyWith(sponsorBlockCategories: state.sponsorBlockCategories),
          (List<String> categories) => state.copyWith(sponsorBlockCategories: categories));
      emit(_state);
    });

    on<ToggleOpenLinksInBrowser>((event, emit) async {
      final _result = await settingsService.toggleOpenLinksInBrowser(
          openInBrowser: !state.openLinksInBrowser);
      final _state = _result.fold(
          (MainFailure f) => state.copyWith(openLinksInBrowser: state.openLinksInBrowser),
          (bool openInBrowser) => state.copyWith(openLinksInBrowser: openInBrowser));
      emit(_state);
    });

    on<SetHomeFeedMode>((event, emit) async {
      final _result = await settingsService.setHomeFeedMode(mode: event.mode);
      final _state = _result.fold(
          (MainFailure f) => state.copyWith(homeFeedMode: state.homeFeedMode),
          (String mode) => state.copyWith(homeFeedMode: mode));
      emit(_state);
    });

    on<ToggleAudioFocus>((event, emit) async {
      final _result = await settingsService.toggleAudioFocus(
          isEnabled: !state.isAudioFocusEnabled);
      final _state = _result.fold(
          (MainFailure f) => state.copyWith(isAudioFocusEnabled: state.isAudioFocusEnabled),
          (bool isEnabled) => state.copyWith(isAudioFocusEnabled: isEnabled));
      emit(_state);
    });

    // Profile events
    on<AddProfile>((event, emit) async {
      final _result = await settingsService.addProfile(profileName: event.profileName);
      final _state = _result.fold(
          (MainFailure f) => state.copyWith(profiles: state.profiles),
          (List<String> profiles) => state.copyWith(profiles: profiles));
      emit(_state);
    });

    on<DeleteProfile>((event, emit) async {
      final _result = await settingsService.deleteProfile(profileName: event.profileName);
      final _state = _result.fold(
          (MainFailure f) => state.copyWith(profiles: state.profiles),
          (List<String> profiles) {
        // If the deleted profile was the current one, switch to default
        String currentProfile = state.currentProfile;
        if (!profiles.contains(currentProfile)) {
          currentProfile = 'default';
        }
        return state.copyWith(profiles: profiles, currentProfile: currentProfile);
      });
      emit(_state);
    });

    on<SwitchProfile>((event, emit) async {
      final _result = await settingsService.switchProfile(profileName: event.profileName);
      final _state = _result.fold(
          (MainFailure f) => state.copyWith(currentProfile: state.currentProfile),
          (String profileName) => state.copyWith(currentProfile: profileName));
      emit(_state);
    });

    on<RenameProfile>((event, emit) async {
      final _result = await settingsService.renameProfile(
          oldName: event.oldName, newName: event.newName);
      final _state = _result.fold(
          (MainFailure f) => state.copyWith(profiles: state.profiles),
          (List<String> profiles) {
        // If the renamed profile was the current one, update current profile name
        String currentProfile = state.currentProfile;
        if (currentProfile == event.oldName) {
          currentProfile = event.newName;
        }
        return state.copyWith(profiles: profiles, currentProfile: currentProfile);
      });
      emit(_state);
    });

    // Import/Export events
    on<ExportSubscriptions>((event, emit) async {
      final result = await settingsService.exportSubscriptions(profileName: event.profileName);
      result.fold(
        (failure) => emit(state.copyWith(lastExportedFilePath: null)),
        (filePath) => emit(state.copyWith(lastExportedFilePath: filePath)),
      );
    });

    on<ImportSubscriptions>((event, emit) async {
      // Import happens - handled in UI with file picker
      await settingsService.importSubscriptions(
        filePath: event.filePath,
        profileName: event.profileName,
      );
    });

    on<SetSubtitleSize>((event, emit) async {
      final _result = await settingsService.setSubtitleSize(size: event.size);
      final _state = _result.fold(
          (MainFailure f) => state.copyWith(subtitleSize: state.subtitleSize),
          (double size) => state.copyWith(subtitleSize: size));
      emit(_state);
    });

    // Search history privacy
    on<ToggleSearchHistoryEnabled>((event, emit) async {
      final _result = await settingsService.toggleSearchHistoryEnabled(
          isEnabled: !state.isSearchHistoryEnabled);
      final _state = _result.fold(
          (MainFailure f) => state.copyWith(isSearchHistoryEnabled: state.isSearchHistoryEnabled),
          (bool isEnabled) => state.copyWith(isSearchHistoryEnabled: isEnabled));
      emit(_state);
    });

    on<ToggleSearchHistoryVisibility>((event, emit) async {
      final _result = await settingsService.toggleSearchHistoryVisibility(
          isVisible: !state.isSearchHistoryVisible);
      final _state = _result.fold(
          (MainFailure f) => state.copyWith(isSearchHistoryVisible: state.isSearchHistoryVisible),
          (bool isVisible) => state.copyWith(isSearchHistoryVisible: isVisible));
      emit(_state);
    });

    // Set last exported file path (for ZIP exports from NewPipeDataService)
    on<SetLastExportedFilePath>((event, emit) {
      emit(state.copyWith(lastExportedFilePath: event.filePath));
    });

    // Toggle auto PiP (enter PiP when pressing home while video is playing)
    on<ToggleAutoPip>((event, emit) async {
      final newValue = !state.isAutoPipEnabled;
      final _result = await settingsService.toggleAutoPip(isEnabled: newValue);
      final _state = _result.fold(
          (MainFailure f) => state.copyWith(isAutoPipEnabled: state.isAutoPipEnabled),
          (bool isEnabled) => state.copyWith(isAutoPipEnabled: isEnabled));
      emit(_state);
    });
  }
}
