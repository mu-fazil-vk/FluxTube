import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:fluxtube/core/api_client.dart';
import 'package:fluxtube/core/enums.dart';
import 'package:fluxtube/core/strings.dart';
import 'package:fluxtube/domain/core/failure/main_failure.dart';
import 'package:fluxtube/domain/settings/models/instance.dart';
import 'package:fluxtube/domain/settings/settings_service.dart';
import 'package:fluxtube/infrastructure/database/database.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/settings.dart';

@LazySingleton(as: SettingsService)
class SettingImpl implements SettingsService {
  static AppDatabase get db => AppDatabase.instance;

  // Initialize the database
  static Future<void> initializeDB() async {
    // Drift database is automatically initialized via the singleton
    // Just ensure it's accessed to trigger initialization
    final _ = AppDatabase.instance;
  }

  // Common setting fetch code
  Future<Map<String, String>> _getOrDefault(
      String settingName, String defaultValue) async {
    final setting = await db.getSetting(settingName);

    if (setting == null) {
      await db.setSetting(settingName, defaultValue);
      return {settingName: defaultValue};
    } else {
      return {settingName: setting};
    }
  }

  /// Generic method to set any setting value
  /// Eliminates duplicate code across all setting methods
  Future<Either<MainFailure, T>> _setSetting<T>({
    required String settingName,
    required T value,
    required String Function(T) toStringValue,
  }) async {
    try {
      final stringValue = toStringValue(value);
      await db.setSetting(settingName, stringValue);
      return Right(value);
    } catch (e) {
      return const Left(MainFailure.serverFailure());
    }
  }

  // Initialize settings state during app startup
  @override
  Future<List<Map<String, String>>> initializeSettings() async {
    // Define your settings and their default values
    final settingsDefaults = [
      {"name": selectedDefaultLanguage, "default": "en"},
      {"name": selectedDefaultQuality, "default": "720p"},
      {"name": selectedDefaultRegion, "default": "IN"},
      {"name": selectedTheme, "default": "system"},
      {"name": historyVisibility, "default": "true"},
      {"name": dislikeVisibility, "default": "false"},
      {"name": hlsPlayer, "default": "false"},
      {"name": commentsVisibility, "default": "false"},
      {"name": relatedVideoVisibility, "default": "false"},
      {"name": instanceApiUrl, "default": BaseUrl.kBaseUrl},
      {
        "name": youtubeService,
        "default": Platform.isAndroid
            ? YouTubeServices.newpipe.name
            : YouTubeServices.piped.name
      },
      {"name": pipDisabled, "default": "false"},
      {"name": homeFeedModeKey, "default": HomeFeedMode.feedOrTrending.name},
      {"name": videoFitModeKey, "default": "contain"},
      {"name": skipIntervalKey, "default": "10"},
      {"name": openLinksInBrowserKey, "default": "false"},
      {"name": audioFocusEnabledKey, "default": "true"},
      {"name": sponsorBlockEnabledKey, "default": "false"},
      {"name": subtitleSizeKey, "default": "32.0"},
      {"name": autoPipEnabledKey, "default": "true"},
    ];

    // Initialize settings list
    List<Map<String, String>> settingsList = [];

    // Iterate over settingsDefaults and initialize each setting
    for (var setting in settingsDefaults) {
      settingsList
          .add(await _getOrDefault(setting["name"]!, setting["default"]!));
    }

    return settingsList;
  }

// DEFAULT LANGUAGE SET
  @override
  Future<Either<MainFailure, String>> selectDefaultLanguage(
      {required String language}) async {
    return _setSetting(
      settingName: selectedDefaultLanguage,
      value: language,
      toStringValue: (v) => v,
    );
  }

  // DEFAULT QUALITY SET
  @override
  Future<Either<MainFailure, String>> selectDefaultQuality(
      {required String quality}) async {
    return _setSetting(
      settingName: selectedDefaultQuality,
      value: quality,
      toStringValue: (v) => v,
    );
  }

  // CONTENT REGION SET
  @override
  Future<Either<MainFailure, String>> selectRegion(
      {required String region}) async {
    return _setSetting(
      settingName: selectedDefaultRegion,
      value: region,
      toStringValue: (v) => v,
    );
  }

  // THEME TOGGLE
  @override
  Future<Either<MainFailure, String>> setTheme(
      {required String themeMode}) async {
    return _setSetting(
      settingName: selectedTheme,
      value: themeMode,
      toStringValue: (v) => v,
    );
  }

  // HISTORY VISIBILITY TOGGLE SETTING
  @override
  Future<Either<MainFailure, bool>> toggleHistoryVisibility(
      {required bool isHistoryVisible}) async {
    return _setSetting(
      settingName: historyVisibility,
      value: isHistoryVisible,
      toStringValue: (v) => v.toString(),
    );
  }

  // DISLIKE VISIBILITY TOGGLE SETTING
  @override
  Future<Either<MainFailure, bool>> toggleDislikeVisibility(
      {required bool isDislikeVisible}) async {
    return _setSetting(
      settingName: dislikeVisibility,
      value: isDislikeVisible,
      toStringValue: (v) => v.toString(),
    );
  }

  // HLS PLAYER TOGGLE SETTING
  @override
  Future<Either<MainFailure, bool>> toggleHlsPlayer(
      {required bool isHlsPlayer}) async {
    return _setSetting(
      settingName: hlsPlayer,
      value: isHlsPlayer,
      toStringValue: (v) => v.toString(),
    );
  }

  @override
  Future<Either<MainFailure, bool>> toggleHideComments(
      {required bool isHideComments}) async {
    return _setSetting(
      settingName: commentsVisibility,
      value: isHideComments,
      toStringValue: (v) => v.toString(),
    );
  }

  @override
  Future<Either<MainFailure, bool>> toggleHideRelatedVideos(
      {required bool isHideRelated}) async {
    return _setSetting(
      settingName: relatedVideoVisibility,
      value: isHideRelated,
      toStringValue: (v) => v.toString(),
    );
  }

  @override
  Future<Either<MainFailure, List<Instance>>> fetchInstances() async {
    final List<Instance> instances = [];
    try {
      final response = await ApiClient.dio.get(kInstanceUrl);
      int skipped = 0;
      final lines = response.data.toString().split('\n');
      for (final line in lines) {
        final split = line.split('|');
        if (split.length == 5) {
          if (skipped < 2) {
            skipped++;
            continue;
          }
          instances.add(Instance(
            name: split[0].trim(),
            api: '${split[1].trim()}/',
            locations: split[2].trim(),
          ));
        }
      }
      return Right(instances);
    } catch (_) {
      return const Left(MainFailure.serverFailure());
    }
  }

  @override
  Future<Either<MainFailure, String>> setInstance(
      {required String instanceApi}) async {
    return _setSetting(
      settingName: instanceApiUrl,
      value: instanceApi,
      toStringValue: (v) => v,
    );
  }

  @override
  Future<Either<MainFailure, YouTubeServices>> setTYService(
      {required YouTubeServices service}) async {
    return _setSetting(
      settingName: youtubeService,
      value: service,
      toStringValue: (v) => v.name,
    );
  }

  @override
  Future<Either<MainFailure, List<Instance>>> fetchInvidiousInstances() async {
    try {
      final List<Instance> instances = [];
      final response = await ApiClient.dio.get(kInvidiousInstanceUrl);
      final data = response.data as List<dynamic>;

      for (final instanceData in data) {
        final instanceInfo = instanceData[1] as Map<String, dynamic>;

        // Only include instances with API enabled and HTTPS type
        final apiEnabled = instanceInfo['api'] == true;
        final isHttps = instanceInfo['type'] == 'https';

        if (isHttps) {
          instances.add(Instance(
            name:
                '${instanceData[0] as String}${apiEnabled ? '' : ' (API disabled)'}',
            api: instanceInfo['uri'] as String,
            locations: instanceInfo['region'] as String? ?? 'Unknown',
          ));
        }
      }

      return Right(instances);
    } catch (_) {
      return const Left(MainFailure.serverFailure());
    }
  }

  @override
  Future<Either<MainFailure, bool>> togglePipPlayer(
      {required bool isPipDisabled}) async {
    return _setSetting(
      settingName: pipDisabled,
      value: isPipDisabled,
      toStringValue: (v) => v.toString(),
    );
  }

  @override
  Future<Either<MainFailure, String>> findWorkingPipedInstance({
    required List<Instance> instances,
    String? preferredInstanceApi,
    void Function(String instanceName)? onTestingInstance,
  }) async {
    // If user has a preferred instance, test it first
    if (preferredInstanceApi != null && preferredInstanceApi.isNotEmpty) {
      final preferredInstance = instances.firstWhere(
        (i) => i.api == preferredInstanceApi,
        orElse: () => Instance(
            name: 'Preferred', api: preferredInstanceApi, locations: ''),
      );

      onTestingInstance?.call(preferredInstance.name);
      final isWorking = await testInstanceConnection(preferredInstanceApi);
      if (isWorking) {
        return Right(preferredInstanceApi);
      }
    }

    // Test other instances
    for (final instance in instances) {
      // Skip the preferred instance since we already tested it
      if (instance.api == preferredInstanceApi) continue;

      try {
        onTestingInstance?.call(instance.name);
        final isWorking = await testInstanceConnection(instance.api);
        if (isWorking) {
          return Right(instance.api);
        }
      } catch (_) {
        continue;
      }
    }

    return const Left(MainFailure.serverFailure());
  }

  @override
  Future<bool> testInstanceConnection(String apiUrl) async {
    try {
      final testUrl = '${apiUrl}trending?region=US';
      final response = await ApiClient.dio.get(
        testUrl,
        options: Options(
          receiveTimeout: const Duration(seconds: 5),
          sendTimeout: const Duration(seconds: 5),
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        if (response.data is List && (response.data as List).isNotEmpty) {
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<Either<MainFailure, String>> findWorkingInvidiousInstance({
    required List<Instance> instances,
    String? preferredInstanceApi,
    void Function(String instanceName)? onTestingInstance,
  }) async {
    // If user has a preferred instance, test it first
    if (preferredInstanceApi != null && preferredInstanceApi.isNotEmpty) {
      final preferredInstance = instances.firstWhere(
        (i) => i.api == preferredInstanceApi,
        orElse: () => Instance(
            name: 'Preferred', api: preferredInstanceApi, locations: ''),
      );

      onTestingInstance?.call(preferredInstance.name);
      final isWorking =
          await testInvidiousInstanceConnection(preferredInstanceApi);
      if (isWorking) {
        return Right(preferredInstanceApi);
      }
    }

    // Filter to only test instances without "(API disabled)" in name
    final apiEnabledInstances = instances
        .where(
          (i) =>
              !i.name.contains('(API disabled)') &&
              i.api != preferredInstanceApi,
        )
        .toList();

    // Test API-enabled instances first
    for (final instance in apiEnabledInstances) {
      try {
        onTestingInstance?.call(instance.name);
        final isWorking = await testInvidiousInstanceConnection(instance.api);
        if (isWorking) {
          return Right(instance.api);
        }
      } catch (_) {
        continue;
      }
    }

    return const Left(MainFailure.serverFailure());
  }

  @override
  Future<bool> testInvidiousInstanceConnection(String apiUrl) async {
    try {
      final testUrl = '$apiUrl/api/v1/trending?region=US';
      final response = await ApiClient.dio.get(
        testUrl,
        options: Options(
          receiveTimeout: const Duration(seconds: 5),
          sendTimeout: const Duration(seconds: 5),
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        if (response.data is List && (response.data as List).isNotEmpty) {
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // New methods for additional features

  @override
  Future<Either<MainFailure, String>> setSearchFilter(
      {required String filter}) async {
    return _setSetting(
      settingName: searchFilterKey,
      value: filter,
      toStringValue: (v) => v,
    );
  }

  @override
  Future<Either<MainFailure, String>> setVideoFitMode(
      {required String fitMode}) async {
    return _setSetting(
      settingName: videoFitModeKey,
      value: fitMode,
      toStringValue: (v) => v,
    );
  }

  @override
  Future<Either<MainFailure, int>> setSkipInterval(
      {required int seconds}) async {
    return _setSetting(
      settingName: skipIntervalKey,
      value: seconds,
      toStringValue: (v) => v.toString(),
    );
  }

  @override
  Future<Either<MainFailure, bool>> toggleSponsorBlock(
      {required bool isEnabled}) async {
    return _setSetting(
      settingName: sponsorBlockEnabledKey,
      value: isEnabled,
      toStringValue: (v) => v.toString(),
    );
  }

  @override
  Future<Either<MainFailure, List<String>>> setSponsorBlockCategories(
      {required List<String> categories}) async {
    return _setSetting(
      settingName: sponsorBlockCategoriesKey,
      value: categories,
      toStringValue: (v) => v.join(','),
    );
  }

  @override
  Future<Either<MainFailure, bool>> toggleOpenLinksInBrowser(
      {required bool openInBrowser}) async {
    return _setSetting(
      settingName: openLinksInBrowserKey,
      value: openInBrowser,
      toStringValue: (v) => v.toString(),
    );
  }

  @override
  Future<Either<MainFailure, String>> setHomeFeedMode(
      {required String mode}) async {
    return _setSetting(
      settingName: homeFeedModeKey,
      value: mode,
      toStringValue: (v) => v,
    );
  }

  @override
  Future<Either<MainFailure, bool>> toggleAudioFocus(
      {required bool isEnabled}) async {
    return _setSetting(
      settingName: audioFocusEnabledKey,
      value: isEnabled,
      toStringValue: (v) => v.toString(),
    );
  }

  // Profile methods
  @override
  Future<Either<MainFailure, List<String>>> getProfiles() async {
    try {
      final setting = await db.getSetting(profilesListKey);

      if (setting == null || setting.isEmpty) {
        return const Right(['default']);
      }
      return Right(setting.split(','));
    } catch (e) {
      return const Left(MainFailure.serverFailure());
    }
  }

  @override
  Future<Either<MainFailure, List<String>>> addProfile(
      {required String profileName}) async {
    try {
      final currentProfiles = await getProfiles();
      return currentProfiles.fold(
        (failure) => Left(failure),
        (profiles) async {
          if (profiles.contains(profileName)) {
            return Right(profiles); // Profile already exists
          }
          final newProfiles = [...profiles, profileName];
          await _setSetting(
            settingName: profilesListKey,
            value: newProfiles,
            toStringValue: (v) => v.join(','),
          );
          return Right(newProfiles);
        },
      );
    } catch (e) {
      return const Left(MainFailure.serverFailure());
    }
  }

  @override
  Future<Either<MainFailure, List<String>>> deleteProfile(
      {required String profileName}) async {
    try {
      if (profileName == 'default') {
        return const Left(
            MainFailure.serverFailure()); // Cannot delete default profile
      }
      final currentProfiles = await getProfiles();
      return currentProfiles.fold(
        (failure) => Left(failure),
        (profiles) async {
          final newProfiles = profiles.where((p) => p != profileName).toList();
          if (newProfiles.isEmpty) {
            newProfiles.add('default');
          }
          await _setSetting(
            settingName: profilesListKey,
            value: newProfiles,
            toStringValue: (v) => v.join(','),
          );
          return Right(newProfiles);
        },
      );
    } catch (e) {
      return const Left(MainFailure.serverFailure());
    }
  }

  @override
  Future<Either<MainFailure, String>> switchProfile(
      {required String profileName}) async {
    return _setSetting(
      settingName: currentProfileKey,
      value: profileName,
      toStringValue: (v) => v,
    );
  }

  @override
  Future<Either<MainFailure, List<String>>> renameProfile(
      {required String oldName, required String newName}) async {
    try {
      if (oldName == 'default') {
        return const Left(
            MainFailure.serverFailure()); // Cannot rename default profile
      }
      if (oldName == newName) {
        final profiles = await getProfiles();
        return profiles;
      }
      final currentProfiles = await getProfiles();
      return currentProfiles.fold(
        (failure) => Left(failure),
        (profiles) async {
          if (!profiles.contains(oldName)) {
            return Right(profiles); // Profile doesn't exist
          }
          if (profiles.contains(newName)) {
            return Right(profiles); // New name already exists
          }
          final newProfiles =
              profiles.map((p) => p == oldName ? newName : p).toList();
          await _setSetting(
            settingName: profilesListKey,
            value: newProfiles,
            toStringValue: (v) => v.join(','),
          );
          return Right(newProfiles);
        },
      );
    } catch (e) {
      return const Left(MainFailure.serverFailure());
    }
  }

  // Import/Export methods
  @override
  Future<Either<MainFailure, String>> exportSubscriptions(
      {String profileName = 'default'}) async {
    try {
      // Get subscriptions only for the specified profile
      final subscriptions = await db.getAllSubscriptions(profileName);

      // Create NewPipe compatible format
      final subscriptionsList = subscriptions.map((sub) {
        return {
          'service_id': 0, // YouTube
          'url': 'https://www.youtube.com/channel/${sub.channelId}',
          'name': sub.channelName,
        };
      }).toList();

      final exportData = {
        'app_version': '0.9.0',
        'app_version_int': 11,
        'subscriptions': subscriptionsList,
        'profile': profileName,
      };

      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final profileSuffix = profileName == 'default' ? '' : '_$profileName';
      final file = File(
          '${dir.path}/fluxtube_subscriptions${profileSuffix}_$timestamp.json');
      await file.writeAsString(jsonEncode(exportData));

      return Right(file.path);
    } catch (e) {
      return const Left(MainFailure.serverFailure());
    }
  }

  @override
  Future<Either<MainFailure, int>> importSubscriptions(
      {required String filePath, String profileName = 'default'}) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return const Left(MainFailure.serverFailure());
      }

      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;

      int importedCount = 0;

      // Handle NewPipe format
      if (data.containsKey('subscriptions')) {
        final subscriptions = data['subscriptions'] as List<dynamic>;

        for (final sub in subscriptions) {
          final subMap = sub as Map<String, dynamic>;
          final url = subMap['url'] as String? ?? '';
          final name = subMap['name'] as String? ?? '';

          // Extract channel ID from URL
          String? channelId;
          if (url.contains('/channel/')) {
            channelId = url.split('/channel/').last.split('/').first;
          } else if (url.contains('/c/') || url.contains('/@')) {
            // Handle custom URLs - would need API lookup in production
            continue;
          }

          if (channelId != null && channelId.isNotEmpty) {
            // Check if already subscribed in this profile
            final existing = await db.getSubscription(channelId, profileName);

            if (existing == null) {
              await db.upsertSubscription(SubscriptionsCompanion.insert(
                channelId: channelId,
                profileName: profileName,
                channelName: name,
              ));
              importedCount++;
            }
          }
        }
      }

      return Right(importedCount);
    } catch (e) {
      return const Left(MainFailure.serverFailure());
    }
  }

  @override
  Future<Either<MainFailure, double>> setSubtitleSize(
      {required double size}) async {
    return _setSetting(
      settingName: subtitleSizeKey,
      value: size,
      toStringValue: (v) => v.toString(),
    );
  }

  @override
  Future<Either<MainFailure, bool>> toggleSearchHistoryEnabled(
      {required bool isEnabled}) async {
    return _setSetting(
      settingName: searchHistoryEnabledKey,
      value: isEnabled,
      toStringValue: (v) => v.toString(),
    );
  }

  @override
  Future<Either<MainFailure, bool>> toggleSearchHistoryVisibility(
      {required bool isVisible}) async {
    return _setSetting(
      settingName: searchHistoryVisibilityKey,
      value: isVisible,
      toStringValue: (v) => v.toString(),
    );
  }

  @override
  Future<Either<MainFailure, bool>> toggleAutoPip(
      {required bool isEnabled}) async {
    return _setSetting(
      settingName: autoPipEnabledKey,
      value: isEnabled,
      toStringValue: (v) => v.toString(),
    );
  }
}
