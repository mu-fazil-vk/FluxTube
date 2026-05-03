import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';

/// Service for managing Android Picture-in-Picture mode
class PipService {
  static final PipService _instance = PipService._internal();
  factory PipService() => _instance;
  PipService._internal() {
    _setupMethodChannel();
  }

  static const _channel = MethodChannel('com.fazilvk.fluxtube/pip');

  bool _isInPipMode = false;
  bool _isAutoPipEnabled = false;

  // Callbacks for PiP state changes
  final List<void Function(bool)> _pipModeListeners = [];
  final List<void Function()> _nextActionListeners = [];

  /// Whether the device is currently in PiP mode
  bool get isInPipMode => _isInPipMode;

  /// Whether auto-PiP on home button is enabled
  bool get isAutoPipEnabled => _isAutoPipEnabled;

  void _setupMethodChannel() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onPipModeChanged':
          final isInPipMode = call.arguments['isInPipMode'] as bool? ?? false;
          _isInPipMode = isInPipMode;
          log('[PipService] PiP mode changed: $isInPipMode');

          // Notify all listeners
          for (final listener in _pipModeListeners) {
            listener(isInPipMode);
          }
          break;
        case 'onPipNext':
          for (final listener
              in List<void Function()>.from(_nextActionListeners)) {
            listener();
          }
          break;
      }
    });
  }

  /// Add a listener for PiP mode changes
  void addPipModeListener(void Function(bool) listener) {
    _pipModeListeners.add(listener);
  }

  /// Remove a PiP mode listener
  void removePipModeListener(void Function(bool) listener) {
    _pipModeListeners.remove(listener);
  }

  void addNextActionListener(void Function() listener) {
    _nextActionListeners.add(listener);
  }

  void removeNextActionListener(void Function() listener) {
    _nextActionListeners.remove(listener);
  }

  /// Check if PiP is supported on this device
  Future<bool> isPipSupported() async {
    if (!Platform.isAndroid) return false;

    try {
      final result = await _channel.invokeMethod<bool>('isPipSupported');
      return result ?? false;
    } catch (e) {
      log('[PipService] Error checking PiP support: $e');
      return false;
    }
  }

  /// Check if currently in PiP mode
  Future<bool> checkIsInPipMode() async {
    if (!Platform.isAndroid) return false;

    try {
      final result = await _channel.invokeMethod<bool>('isInPipMode');
      _isInPipMode = result ?? false;
      return _isInPipMode;
    } catch (e) {
      log('[PipService] Error checking PiP mode: $e');
      return false;
    }
  }

  /// Enter Picture-in-Picture mode
  /// [aspectRatioWidth] and [aspectRatioHeight] define the PiP window aspect ratio
  Future<bool> enterPipMode({
    int aspectRatioWidth = 16,
    int aspectRatioHeight = 9,
  }) async {
    if (!Platform.isAndroid) return false;

    try {
      final result = await _channel.invokeMethod<bool>('enterPip', {
        'aspectRatioWidth': aspectRatioWidth,
        'aspectRatioHeight': aspectRatioHeight,
      });
      return result ?? false;
    } catch (e) {
      log('[PipService] Error entering PiP mode: $e');
      return false;
    }
  }

  /// Exit PiP mode (notify native side)
  Future<bool> exitPipMode() async {
    if (!Platform.isAndroid) return false;

    try {
      final result = await _channel.invokeMethod<bool>('exitPip');
      return result ?? false;
    } catch (e) {
      log('[PipService] Error exiting PiP mode: $e');
      return false;
    }
  }

  /// Notify native side about video playback state
  /// This is used to determine whether to auto-enter PiP on home button press
  Future<void> setVideoPlaying(bool isPlaying) async {
    if (!Platform.isAndroid) return;

    try {
      await _channel.invokeMethod('setVideoPlaying', {
        'isPlaying': isPlaying,
      });
    } catch (e) {
      log('[PipService] Error setting video playing: $e');
    }
  }

  /// Set the aspect ratio of the PiP window
  Future<void> setAspectRatio(int width, int height) async {
    if (!Platform.isAndroid) return;

    try {
      await _channel.invokeMethod('setAspectRatio', {
        'width': width,
        'height': height,
      });
    } catch (e) {
      log('[PipService] Error setting aspect ratio: $e');
    }
  }

  Future<void> setSourceRect(Rect rect) async {
    if (!Platform.isAndroid) return;

    try {
      await _channel.invokeMethod('setSourceRect', {
        'left': rect.left.round(),
        'top': rect.top.round(),
        'right': rect.right.round(),
        'bottom': rect.bottom.round(),
      });
    } catch (e) {
      log('[PipService] Error setting source rect: $e');
    }
  }

  /// Enable or disable auto-PiP on home button press
  Future<void> enableAutoPip(bool enabled) async {
    if (!Platform.isAndroid) return;

    _isAutoPipEnabled = enabled;

    try {
      await _channel.invokeMethod('enableAutoPip', {
        'enabled': enabled,
      });
      log('[PipService] Auto-PiP enabled: $enabled');
    } catch (e) {
      log('[PipService] Error setting auto-PiP: $e');
    }
  }
}
