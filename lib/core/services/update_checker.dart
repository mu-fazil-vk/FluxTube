import 'dart:developer' as dev;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluxtube/core/settings.dart';
import 'package:fluxtube/domain/update/update_info.dart';
import 'package:fluxtube/infrastructure/database/database.dart';
import 'package:fluxtube/presentation/settings/utils/launch_url.dart';
import 'package:fluxtube/widgets/update_available_dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Checks GitHub Releases for a newer FluxTube build than the one currently
/// installed.
///
/// Two entry points share the same fetch/compare logic but show the result
/// differently:
///  * [checkOnStartup] — silent, throttled, skipped entirely once the user
///    has picked "Never show again". Shows a 3-button dialog (Later / Update
///    / Never show again) when a newer release exists, says nothing otherwise.
///  * [checkManually] — always hits the network, ignores the throttle and the
///    "never show again" flag (an explicit tap is explicit consent), and
///    always gives feedback — the 2-button dialog (Close / Download) when
///    there's an update, a snackbar when the app is already current.
class UpdateChecker {
  static final UpdateChecker _instance = UpdateChecker._();
  factory UpdateChecker() => _instance;
  UpdateChecker._();

  static const _repo = 'mu-fazil-vk/fluxtube';
  static const _minCheckInterval = Duration(hours: 12);

  final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Accept': 'application/vnd.github+json'},
  ));

  AppDatabase get _db => AppDatabase.instance;

  Future<void> checkOnStartup(BuildContext context) async {
    try {
      final neverShow = await _db.getSetting(updateCheckNeverShowKey);
      if (neverShow == 'true') return;
      if (!await _throttleElapsed()) return;

      final info = await _fetchNewerRelease();
      await _stampCheck();
      if (info == null || !context.mounted) return;

      await showUpdateAvailableDialog(context,
          info: info, showThreeButtons: true);
    } catch (e) {
      dev.log('startup check failed: $e', name: 'UpdateChecker');
    }
  }

  Future<void> checkManually(BuildContext context) async {
    UpdateInfo? info;
    String? error;
    try {
      info = await _fetchNewerRelease();
      await _stampCheck();
    } catch (e) {
      error = e.toString();
      dev.log('manual check failed: $e', name: 'UpdateChecker');
    }

    if (!context.mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Couldn't check for updates. Try again later.")),
      );
      return;
    }

    if (info == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You're on the latest version.")),
      );
      return;
    }

    await showUpdateAvailableDialog(context,
        info: info, showThreeButtons: false);
  }

  Future<void> neverShowAgain() =>
      _db.setSetting(updateCheckNeverShowKey, 'true');

  Future<void> openRelease(String htmlUrl) =>
      urlLaunch(htmlUrl, openInBrowser: true);

  Future<UpdateInfo?> _fetchNewerRelease() async {
    final response =
        await _dio.get('https://api.github.com/repos/$_repo/releases/latest');
    final data = response.data;
    if (data is! Map<String, dynamic>) return null;

    final info = UpdateInfo.fromGitHubRelease(data);
    if (info.version.isEmpty || info.htmlUrl.isEmpty) return null;

    final current = (await PackageInfo.fromPlatform()).version;
    return _isNewer(info.version, current) ? info : null;
  }

  Future<bool> _throttleElapsed() async {
    final raw = await _db.getSetting(updateCheckLastCheckKey);
    final last = DateTime.tryParse(raw ?? '');
    if (last == null) return true;
    return DateTime.now().difference(last) >= _minCheckInterval;
  }

  Future<void> _stampCheck() =>
      _db.setSetting(updateCheckLastCheckKey, DateTime.now().toIso8601String());

  /// Compares dotted numeric versions (`1.2.10` > `1.2.9`), ignoring any
  /// `-beta`/`+build` suffix. Good enough for this project's `x.y.z` scheme
  /// without pulling in a semver package for one comparison.
  static bool _isNewer(String remote, String local) {
    final remoteParts = _numericParts(remote);
    final localParts = _numericParts(local);
    final length = remoteParts.length > localParts.length
        ? remoteParts.length
        : localParts.length;
    for (var i = 0; i < length; i++) {
      final r = i < remoteParts.length ? remoteParts[i] : 0;
      final l = i < localParts.length ? localParts[i] : 0;
      if (r != l) return r > l;
    }
    return false;
  }

  static List<int> _numericParts(String version) {
    final core = version.split(RegExp(r'[-+]')).first;
    return core.split('.').map((p) => int.tryParse(p) ?? 0).toList();
  }
}
