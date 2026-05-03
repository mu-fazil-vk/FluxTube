import 'package:flutter/services.dart';

class ExoPlayerNotificationBridge {
  ExoPlayerNotificationBridge._();

  static final ExoPlayerNotificationBridge instance =
      ExoPlayerNotificationBridge._();

  static const _controlChannel = MethodChannel(
    'com.fazilvk.fluxtube/newpipe_exoplayer_control',
  );

  void attach(MethodChannel channel) {}

  Future<void> play() async {
    await _controlChannel.invokeMethod('play');
  }

  Future<void> pause() async {
    await _controlChannel.invokeMethod('pause');
  }

  Future<void> stop() async {
    await _controlChannel.invokeMethod('stop');
  }

  Future<void> seek(Duration position) async {
    await _controlChannel.invokeMethod('seekTo', {
      'positionMs': position.inMilliseconds,
    });
  }

  Future<Duration> seekBy(Duration delta) async {
    final positionMs = await _controlChannel.invokeMethod<int>('seekBy', {
      'deltaMs': delta.inMilliseconds,
    });
    return Duration(milliseconds: positionMs ?? 0);
  }
}
