import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Color;

import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluxtube/core/api_client.dart';
import 'package:fluxtube/domain/download/models/download_item.dart';
import 'package:fluxtube/presentation/main_navigation/main_navigation.dart';
import 'package:fluxtube/presentation/routes/app_routes.dart';

/// Service for managing download notifications with modern UI
class DownloadNotificationService {
  static final DownloadNotificationService _instance = DownloadNotificationService._internal();
  factory DownloadNotificationService() => _instance;
  DownloadNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  bool _hasPermission = false;

  // Cache for thumbnails to avoid re-downloading
  final Map<String, Uint8List> _thumbnailCache = {};

  // Notification channel IDs
  static const String _downloadChannelId = 'download_channel';
  static const String _downloadChannelName = 'Downloads';
  static const String _downloadChannelDescription = 'Download progress and status notifications';

  // Notification IDs - use download item ID as base
  static const int _baseNotificationId = 10000;

  /// Initialize the notification service
  Future<bool> initialize() async {
    if (_isInitialized) return _hasPermission;

    try {
      log('[Notification] Initializing notification service...');

      // Android initialization settings
      const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');

      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      final initialized = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      log('[Notification] Plugin initialized: $initialized');

      // Create notification channel for Android
      if (Platform.isAndroid) {
        await _createNotificationChannel();
        log('[Notification] Channel created');

        // Check if we already have permission
        _hasPermission = await _checkNotificationPermission();
        log('[Notification] Current permission status: $_hasPermission');

        // If not granted, request permission
        if (!_hasPermission) {
          _hasPermission = await requestNotificationPermission();
          log('[Notification] Permission after request: $_hasPermission');
        }
      } else {
        // iOS handles permissions during initialization
        _hasPermission = true;
      }

      _isInitialized = true;
      log('[Notification] Service initialized successfully, hasPermission: $_hasPermission');
      return _hasPermission;
    } catch (e, stack) {
      log('[Notification] Initialization error: $e');
      log('[Notification] Stack trace: $stack');
      return false;
    }
  }

  /// Ensure service is initialized before showing notifications
  Future<bool> _ensureInitialized() async {
    if (!_isInitialized) {
      return await initialize();
    }
    return _hasPermission;
  }

  /// Check if notification permission is granted
  Future<bool> _checkNotificationPermission() async {
    if (!Platform.isAndroid) return true;

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final areEnabled = await androidPlugin.areNotificationsEnabled();
      return areEnabled ?? false;
    }
    return false;
  }

  /// Request notification permission for Android 13+
  /// This is public so it can be called from settings or when starting a download
  Future<bool> requestNotificationPermission() async {
    if (!Platform.isAndroid) return true;

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      log('[Notification] Requesting notification permission...');
      final granted = await androidPlugin.requestNotificationsPermission();
      _hasPermission = granted ?? false;
      log('[Notification] Permission request result: $_hasPermission');
      return _hasPermission;
    }
    return false;
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (!Platform.isAndroid) return true;
    return await _checkNotificationPermission();
  }

  /// Open app notification settings (for when user needs to manually enable)
  Future<void> openNotificationSettings() async {
    if (!Platform.isAndroid) return;

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }
  }

  /// Get current initialization state
  bool get isInitialized => _isInitialized;

  /// Get current permission state
  bool get hasPermission => _hasPermission;

  /// Create Android notification channel
  Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      _downloadChannelId,
      _downloadChannelName,
      description: _downloadChannelDescription,
      importance: Importance.low, // Low importance for progress notifications
      showBadge: false,
      playSound: false,
      enableVibration: false,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Handle notification tap - navigate to downloads screen
  void _onNotificationTapped(NotificationResponse response) {
    // Navigate to main screen first (in case app was killed)
    router.go('/main');

    // Check payload to determine which tab to open
    // Payload format: "status:downloading|completed|failed|paused"
    int? downloadsTab;
    if (response.payload != null) {
      if (response.payload == 'status:completed') {
        downloadsTab = 1; // Completed tab
      } else {
        downloadsTab = 0; // Downloading tab for progress/paused/failed
      }
    }

    // Switch to Downloads tab with the appropriate sub-tab
    navigateToDownloadsTab(downloadsTabIndex: downloadsTab);
  }

  /// Get notification ID for a download item
  int _getNotificationId(int downloadId) => _baseNotificationId + downloadId;

  /// Show download started notification
  Future<void> showDownloadStarted(DownloadItem item) async {
    log('[Notification] showDownloadStarted called - initialized: $_isInitialized, hasPermission: $_hasPermission, id: ${item.id}');

    if (item.id == null) {
      log('[Notification] Skipping notification - no item id');
      return;
    }

    // Ensure initialized and request permission if needed
    final hasPermission = await _ensureInitialized();
    if (!hasPermission) {
      log('[Notification] Skipping notification - no permission');
      return;
    }

    // Fetch thumbnail for large icon
    final thumbnail = await _getThumbnailBitmap(item.thumbnailUrl);

    final androidDetails = AndroidNotificationDetails(
      _downloadChannelId,
      _downloadChannelName,
      channelDescription: _downloadChannelDescription,
      importance: Importance.low,
      priority: Priority.low,
      showProgress: true,
      maxProgress: 100,
      progress: 0,
      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true,
      category: AndroidNotificationCategory.progress,
      icon: '@mipmap/launcher_icon',
      largeIcon: thumbnail,
      subText: 'Starting download...',
    );

    final iosDetails = DarwinNotificationDetails(
      subtitle: 'Starting download...',
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notifications.show(
        _getNotificationId(item.id!),
        _truncateTitle(item.title),
        'Preparing download...',
        details,
        payload: 'status:downloading',
      );
      log('[Notification] Download started notification shown');
    } catch (e) {
      log('[Notification] Error showing notification: $e');
    }
  }

  /// Update download progress notification
  Future<void> showDownloadProgress(DownloadItem item) async {
    if (item.id == null) return;
    if (!_isInitialized || !_hasPermission) return;

    final progress = _calculateProgress(item);
    final speedText = _formatSpeed(item.downloadSpeed);
    final etaText = _formatEta(item.etaSeconds);
    final sizeText = _formatSize(item.downloadedBytes, item.totalBytes);

    String phaseText = '';
    if (item.downloadType == DownloadType.videoWithAudio) {
      if (item.currentPhase == 'video') {
        phaseText = 'Video: ';
      } else if (item.currentPhase == 'audio') {
        phaseText = 'Audio: ';
      } else if (item.currentPhase == 'merging') {
        phaseText = 'Merging... ';
      }
    }

    final subText = item.currentPhase == 'merging'
        ? 'Merging video and audio...'
        : '$phaseText$sizeText • $speedText • $etaText';

    // Use cached thumbnail (already fetched in showDownloadStarted)
    final thumbnail = await _getThumbnailBitmap(item.thumbnailUrl);

    final androidDetails = AndroidNotificationDetails(
      _downloadChannelId,
      _downloadChannelName,
      channelDescription: _downloadChannelDescription,
      importance: Importance.low,
      priority: Priority.low,
      showProgress: item.currentPhase != 'merging',
      maxProgress: 100,
      progress: progress,
      indeterminate: item.currentPhase == 'merging',
      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true,
      category: AndroidNotificationCategory.progress,
      icon: '@mipmap/launcher_icon',
      largeIcon: thumbnail,
      subText: '$progress%',
    );

    final iosDetails = DarwinNotificationDetails(
      subtitle: '$progress%',
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      _getNotificationId(item.id!),
      _truncateTitle(item.title),
      subText,
      details,
      payload: 'status:downloading',
    );
  }

  /// Show download completed notification
  Future<void> showDownloadCompleted(DownloadItem item) async {
    if (item.id == null) return;
    if (!_isInitialized || !_hasPermission) return;

    final sizeText = _formatBytes(item.totalBytes ?? item.downloadedBytes);

    // Use cached thumbnail
    final thumbnail = await _getThumbnailBitmap(item.thumbnailUrl);

    final androidDetails = AndroidNotificationDetails(
      _downloadChannelId,
      _downloadChannelName,
      channelDescription: _downloadChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      ongoing: false,
      autoCancel: true,
      icon: '@mipmap/launcher_icon',
      largeIcon: thumbnail,
      subText: 'Completed',
      category: AndroidNotificationCategory.status,
    );

    final iosDetails = DarwinNotificationDetails(
      subtitle: 'Completed',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      _getNotificationId(item.id!),
      _truncateTitle(item.title),
      'Download complete • $sizeText',
      details,
      payload: 'status:completed',
    );
  }

  /// Show download failed notification
  Future<void> showDownloadFailed(DownloadItem item, String? error) async {
    if (item.id == null) return;
    if (!_isInitialized || !_hasPermission) return;

    final errorMessage = error ?? 'Download failed';

    // Use cached thumbnail
    final thumbnail = await _getThumbnailBitmap(item.thumbnailUrl);

    final androidDetails = AndroidNotificationDetails(
      _downloadChannelId,
      _downloadChannelName,
      channelDescription: _downloadChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      ongoing: false,
      autoCancel: true,
      icon: '@mipmap/launcher_icon',
      largeIcon: thumbnail,
      subText: 'Failed',
      category: AndroidNotificationCategory.error,
      color: const Color(0xFFE53935), // Red color for error
    );

    final iosDetails = DarwinNotificationDetails(
      subtitle: 'Failed',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      _getNotificationId(item.id!),
      _truncateTitle(item.title),
      errorMessage,
      details,
      payload: 'status:failed',
    );
  }

  /// Show download paused notification
  Future<void> showDownloadPaused(DownloadItem item) async {
    if (item.id == null) return;
    if (!_isInitialized || !_hasPermission) return;

    final progress = _calculateProgress(item);
    final sizeText = _formatSize(item.downloadedBytes, item.totalBytes);

    // Use cached thumbnail
    final thumbnail = await _getThumbnailBitmap(item.thumbnailUrl);

    final androidDetails = AndroidNotificationDetails(
      _downloadChannelId,
      _downloadChannelName,
      channelDescription: _downloadChannelDescription,
      importance: Importance.low,
      priority: Priority.low,
      showProgress: true,
      maxProgress: 100,
      progress: progress,
      ongoing: false,
      autoCancel: false,
      onlyAlertOnce: true,
      icon: '@mipmap/launcher_icon',
      largeIcon: thumbnail,
      subText: 'Paused',
      category: AndroidNotificationCategory.progress,
    );

    final iosDetails = DarwinNotificationDetails(
      subtitle: 'Paused',
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      _getNotificationId(item.id!),
      _truncateTitle(item.title),
      'Paused • $sizeText • $progress%',
      details,
      payload: 'status:paused',
    );
  }

  /// Show download cancelled notification (or just cancel it)
  Future<void> cancelNotification(int downloadId) async {
    if (!_isInitialized || !_hasPermission) return;
    await _notifications.cancel(_getNotificationId(downloadId));
  }

  /// Cancel all download notifications
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized || !_hasPermission) return;
    await _notifications.cancelAll();
  }

  // Helper methods

  int _calculateProgress(DownloadItem item) {
    if (item.totalBytes == null || item.totalBytes == 0) return 0;
    final progress = (item.downloadedBytes / item.totalBytes! * 100).round();
    return progress.clamp(0, 100);
  }

  String _truncateTitle(String title) {
    if (title.length <= 40) return title;
    return '${title.substring(0, 37)}...';
  }

  String _formatSpeed(int bytesPerSecond) {
    if (bytesPerSecond <= 0) return '--/s';
    if (bytesPerSecond < 1024) return '${bytesPerSecond}B/s';
    if (bytesPerSecond < 1024 * 1024) {
      return '${(bytesPerSecond / 1024).toStringAsFixed(1)}KB/s';
    }
    return '${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(1)}MB/s';
  }

  String _formatEta(int? seconds) {
    if (seconds == null || seconds <= 0) return '--:--';
    if (seconds < 60) return '${seconds}s';
    if (seconds < 3600) {
      final mins = seconds ~/ 60;
      final secs = seconds % 60;
      return '${mins}m ${secs}s';
    }
    final hours = seconds ~/ 3600;
    final mins = (seconds % 3600) ~/ 60;
    return '${hours}h ${mins}m';
  }

  String _formatSize(int downloaded, int? total) {
    final downloadedStr = _formatBytes(downloaded);
    if (total == null || total == 0) return downloadedStr;
    final totalStr = _formatBytes(total);
    return '$downloadedStr / $totalStr';
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)}GB';
  }

  /// Fetch and cache thumbnail for notification large icon
  Future<ByteArrayAndroidBitmap?> _getThumbnailBitmap(String? thumbnailUrl) async {
    if (thumbnailUrl == null || thumbnailUrl.isEmpty) return null;

    try {
      // Check cache first
      if (_thumbnailCache.containsKey(thumbnailUrl)) {
        return ByteArrayAndroidBitmap(_thumbnailCache[thumbnailUrl]!);
      }

      final response = await ApiClient.dio.get<List<int>>(
        thumbnailUrl,
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final bytes = Uint8List.fromList(response.data!);
        // Cache for future use
        _thumbnailCache[thumbnailUrl] = bytes;
        return ByteArrayAndroidBitmap(bytes);
      }
    } catch (e) {
      log('[Notification] Failed to fetch thumbnail: $e');
    }
    return null;
  }

  /// Clean up thumbnail cache for a specific video
  void clearThumbnailCache(String? thumbnailUrl) {
    if (thumbnailUrl != null) {
      _thumbnailCache.remove(thumbnailUrl);
    }
  }
}
