import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:fluxtube/domain/core/failure/main_failure.dart';
import 'package:fluxtube/domain/download/download_service.dart';
import 'package:fluxtube/domain/download/models/download_item.dart' as domain;
import 'package:fluxtube/domain/download/models/download_quality.dart';
import 'package:fluxtube/domain/watch/models/newpipe/newpipe_stream.dart';
import 'package:fluxtube/domain/watch/models/newpipe/newpipe_watch_resp.dart';
import 'package:fluxtube/domain/watch/playback/newpipe_stream_helper.dart';
import 'package:fluxtube/core/api_client.dart';
import 'package:fluxtube/infrastructure/database/database.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

@LazySingleton(as: DownloadService)
class DownloadImpl implements DownloadService {
  AppDatabase get _db => AppDatabase.instance;
  Dio get _dio => ApiClient.downloadDio;

  // Platform channel for native MediaMuxer
  static const _muxerChannel = MethodChannel('com.fazilvk.fluxtube/muxer');

  // Track active downloads
  final Map<int, CancelToken> _cancelTokens = {};
  final Map<int, bool> _pausedDownloads = {};

  // CPN alphabet for generating Content Playback Nonce
  static const String _cpnAlphabet =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_';

  // Multi-threaded download settings
  static const int _downloadThreads = 3;
  static const int _chunkSize = 512 * 1024; // 512KB chunks

  /// Generate a Content Playback Nonce (CPN)
  /// This is a 16-character random string that YouTube uses to track playback sessions
  String _generateCpn() {
    final random = math.Random.secure();
    return List.generate(16, (_) => _cpnAlphabet[random.nextInt(_cpnAlphabet.length)]).join();
  }

  /// Add required parameters to YouTube URL for faster downloads
  String _enhanceDownloadUrl(String url) {
    if (!url.contains('googlevideo.com')) return url;

    String enhancedUrl = url;

    // Add ratebypass parameter if not present
    if (!enhancedUrl.contains('ratebypass')) {
      enhancedUrl = enhancedUrl.contains('?')
          ? '$enhancedUrl&ratebypass=yes'
          : '$enhancedUrl?ratebypass=yes';
    }

    // Add CPN (Content Playback Nonce) if not present - critical for speed
    if (!enhancedUrl.contains('cpn=')) {
      enhancedUrl = '$enhancedUrl&cpn=${_generateCpn()}';
    }

    return enhancedUrl;
  }

  // Convert Drift DownloadItem to domain
  domain.DownloadItem _toDomain(DownloadItem item) {
    return domain.DownloadItem()
      ..id = item.id
      ..videoId = item.videoId
      ..profileName = item.profileName
      ..title = item.title
      ..channelName = item.channelName
      ..thumbnailUrl = item.thumbnailUrl
      ..duration = item.duration
      ..videoQuality = item.videoQuality
      ..audioQuality = item.audioQuality
      ..downloadType = domain.DownloadType.values[item.downloadType]
      ..status = domain.DownloadStatus.values[item.status]
      ..videoUrl = item.videoUrl
      ..audioUrl = item.audioUrl
      ..videoFilePath = item.videoFilePath
      ..audioFilePath = item.audioFilePath
      ..outputFilePath = item.outputFilePath
      ..totalBytes = item.totalBytes
      ..videoTotalBytes = item.videoTotalBytes
      ..audioTotalBytes = item.audioTotalBytes
      ..downloadedBytes = item.downloadedBytes
      ..videoDownloadedBytes = item.videoDownloadedBytes
      ..audioDownloadedBytes = item.audioDownloadedBytes
      ..downloadSpeed = item.downloadSpeed
      ..etaSeconds = item.etaSeconds
      ..currentPhase = item.currentPhase
      ..errorMessage = item.errorMessage
      ..retryCount = item.retryCount
      ..createdAt = item.createdAt
      ..startedAt = item.startedAt
      ..completedAt = item.completedAt
      ..videoProgress = item.videoProgress
      ..audioProgress = item.audioProgress;
  }

  // Convert domain to Drift companion
  DownloadItemsCompanion _toCompanion(domain.DownloadItem item) {
    return DownloadItemsCompanion(
      id: item.id != null ? Value(item.id!) : const Value.absent(),
      videoId: Value(item.videoId),
      profileName: Value(item.profileName),
      title: Value(item.title),
      channelName: Value(item.channelName),
      thumbnailUrl: Value(item.thumbnailUrl),
      duration: Value(item.duration),
      videoQuality: Value(item.videoQuality),
      audioQuality: Value(item.audioQuality),
      downloadType: Value(item.downloadType.index),
      status: Value(item.status.index),
      videoUrl: Value(item.videoUrl),
      audioUrl: Value(item.audioUrl),
      videoFilePath: Value(item.videoFilePath),
      audioFilePath: Value(item.audioFilePath),
      outputFilePath: Value(item.outputFilePath),
      totalBytes: Value(item.totalBytes),
      videoTotalBytes: Value(item.videoTotalBytes),
      audioTotalBytes: Value(item.audioTotalBytes),
      downloadedBytes: Value(item.downloadedBytes),
      videoDownloadedBytes: Value(item.videoDownloadedBytes),
      audioDownloadedBytes: Value(item.audioDownloadedBytes),
      downloadSpeed: Value(item.downloadSpeed),
      etaSeconds: Value(item.etaSeconds),
      currentPhase: Value(item.currentPhase),
      errorMessage: Value(item.errorMessage),
      retryCount: Value(item.retryCount),
      createdAt: Value(item.createdAt),
      startedAt: Value(item.startedAt),
      completedAt: Value(item.completedAt),
      videoProgress: Value(item.videoProgress),
      audioProgress: Value(item.audioProgress),
    );
  }

  @override
  Future<Either<MainFailure, DownloadOptions>> getDownloadOptions({
    required String videoId,
    required String serviceType,
  }) async {
    // This method is deprecated - use getDownloadOptionsFromStreams with NewPipe streams instead
    // Downloads should use the same streams that work for video playback
    return Left(MainFailure.serverError(
      message: 'Use getDownloadOptionsFromStreams with NewPipe streams instead',
    ));
  }

  @override
  DownloadOptions getDownloadOptionsFromStreams({
    required String videoId,
    required String title,
    required String channelName,
    String? thumbnailUrl,
    int? duration,
    List<NewPipeVideoStream>? videoStreams,
    List<NewPipeVideoStream>? videoOnlyStreams,
    List<NewPipeAudioStream>? audioStreams,
  }) {
    log('[Download] Processing streams for $videoId:');
    log('[Download] videoOnlyStreams: ${videoOnlyStreams?.length ?? 0}');
    log('[Download] videoStreams (muxed): ${videoStreams?.length ?? 0}');
    log('[Download] audioStreams: ${audioStreams?.length ?? 0}');

    // Create a mock NewPipeWatchResp to use NewPipeStreamHelper for consistent quality listing
    // This ensures download quality options match exactly what the player shows
    final mockWatchResp = NewPipeWatchResp(
      id: videoId,
      title: title,
      uploaderName: channelName,
      thumbnailUrl: thumbnailUrl,
      duration: duration,
      videoStreams: videoStreams,
      videoOnlyStreams: videoOnlyStreams,
      audioStreams: audioStreams,
    );

    // Use NewPipeStreamHelper to get available qualities - same logic as the player
    final availableQualities = NewPipeStreamHelper.getAvailableQualities(mockWatchResp);

    log('[Download] NewPipeStreamHelper found ${availableQualities.length} qualities: ${availableQualities.map((q) => q.label).join(", ")}');

    // Convert StreamQualityInfo to VideoQualityOption
    final videoQualities = <VideoQualityOption>[];
    for (final quality in availableQualities) {
      final videoStream = quality.videoStream;
      if (videoStream == null || videoStream.url == null) continue;

      // Determine if this is a muxed stream (no audio merging required)
      final isMuxed = !quality.requiresMerging;
      final label = isMuxed ? '${quality.label} (muxed)' : quality.label;

      videoQualities.add(VideoQualityOption(
        label: label,
        quality: videoStream.quality ?? quality.label,
        resolution: videoStream.width != null && videoStream.height != null
            ? '${videoStream.width}x${videoStream.height}'
            : videoStream.resolution ?? '${quality.resolution}p',
        bitrate: videoStream.bitrate != null ? videoStream.bitrate! ~/ 1000 : null,
        codec: videoStream.codec,
        fileSize: videoStream.contentLength,
        url: videoStream.url!,
        isMuxed: isMuxed,
      ));
    }

    log('[Download] Found ${videoQualities.length} video qualities: ${videoQualities.map((q) => q.label).join(", ")}');

    // Process audio streams
    final audioQualities = <AudioQualityOption>[];

    // Add all valid audio streams (not dubbed/descriptive)
    for (final stream in audioStreams ?? []) {
      if (stream.url == null || stream.url!.isEmpty) continue;
      // Skip dubbed/descriptive tracks for download, prefer original
      if (stream.isDubbed || stream.isDescriptive) continue;

      audioQualities.add(AudioQualityOption(
        label: stream.format ?? 'Audio',
        bitrate: stream.averageBitrate != null ? stream.averageBitrate! ~/ 1000 : null,
        codec: stream.codec,
        fileSize: stream.contentLength,
        url: stream.url!,
      ));
    }

    // Sort audio by bitrate descending
    audioQualities.sort((a, b) => (b.bitrate ?? 0).compareTo(a.bitrate ?? 0));

    log('[Download] Found ${audioQualities.length} audio qualities');

    return DownloadOptions(
      videoId: videoId,
      title: title,
      channelName: channelName,
      thumbnailUrl: thumbnailUrl,
      duration: duration,
      videoQualities: videoQualities,
      audioQualities: audioQualities,
    );
  }

  @override
  Future<Either<MainFailure, domain.DownloadItem>> startDownload({
    required domain.DownloadItem item,
    required Function(domain.DownloadItem) onProgress,
    required Function(domain.DownloadItem) onComplete,
    required Function(domain.DownloadItem, String) onError,
  }) async {
    try {
      // Save initial state
      item.status = domain.DownloadStatus.downloading;
      item.startedAt = DateTime.now();

      final insertedId = await _db.insertDownload(_toCompanion(item));
      item.id = insertedId;

      final cancelToken = CancelToken();
      _cancelTokens[item.id!] = cancelToken;
      _pausedDownloads[item.id!] = false;

      final downloadDir = await _getDownloadDirectory();

      if (item.downloadType == domain.DownloadType.audioOnly) {
        // Audio only download
        await _downloadAudio(item, downloadDir, cancelToken, onProgress);
      } else if (item.downloadType == domain.DownloadType.videoOnly) {
        // Video only download
        await _downloadVideo(item, downloadDir, cancelToken, onProgress);
      } else {
        // Video with audio - download both and merge
        await _downloadVideoWithAudio(item, downloadDir, cancelToken, onProgress);
      }

      // Check if cancelled or paused
      if (_pausedDownloads[item.id] == true) {
        item.status = domain.DownloadStatus.paused;
        await _db.updateDownload(_toCompanion(item));
        return Right(item);
      }

      if (cancelToken.isCancelled) {
        item.status = domain.DownloadStatus.cancelled;
        await _db.updateDownload(_toCompanion(item));
        return Right(item);
      }

      // Mark as completed
      item.status = domain.DownloadStatus.completed;
      item.completedAt = DateTime.now();
      item.videoProgress = 1.0;
      item.audioProgress = 1.0;
      await _db.updateDownload(_toCompanion(item));

      onComplete(item);
      _cleanup(item.id!);

      return Right(item);
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        return Right(item);
      }

      item.status = domain.DownloadStatus.failed;
      item.errorMessage = e.toString();
      item.retryCount++;
      if (item.id != null) {
        await _db.updateDownload(_toCompanion(item));
      }

      onError(item, e.toString());
      if (item.id != null) {
        _cleanup(item.id!);
      }

      return Left(MainFailure.serverError(message: 'Download failed: $e'));
    }
  }

  Future<void> _downloadVideo(
    domain.DownloadItem item,
    Directory downloadDir,
    CancelToken cancelToken,
    Function(domain.DownloadItem) onProgress,
  ) async {
    if (item.videoUrl == null) return;

    final fileName = '${item.videoId}_video.mp4';
    final filePath = '${downloadDir.path}/$fileName';
    item.videoFilePath = filePath;
    item.outputFilePath = filePath;

    await _downloadFile(
      url: item.videoUrl!,
      savePath: filePath,
      cancelToken: cancelToken,
      onProgress: (received, total) {
        if (_pausedDownloads[item.id] == true) {
          cancelToken.cancel('Paused');
          return;
        }
        item.downloadedBytes = received;
        if (total > 0) item.totalBytes = total;
        final newProgress = total > 0 ? received / total : 0.0;
        _updateVideoProgress(item, newProgress);
        _calculateSpeed(item, received);
        if (_shouldSendProgressUpdate(item.id)) {
          onProgress(item);
        }
      },
    );
  }

  Future<void> _downloadAudio(
    domain.DownloadItem item,
    Directory downloadDir,
    CancelToken cancelToken,
    Function(domain.DownloadItem) onProgress,
  ) async {
    if (item.audioUrl == null) return;

    final fileName = '${item.videoId}_audio.m4a';
    final filePath = '${downloadDir.path}/$fileName';
    item.audioFilePath = filePath;
    item.outputFilePath = filePath;

    await _downloadFile(
      url: item.audioUrl!,
      savePath: filePath,
      cancelToken: cancelToken,
      onProgress: (received, total) {
        if (_pausedDownloads[item.id] == true) {
          cancelToken.cancel('Paused');
          return;
        }
        item.downloadedBytes = received;
        if (total > 0) item.totalBytes = total;
        final newProgress = total > 0 ? received / total : 0.0;
        _updateAudioProgress(item, newProgress);
        _calculateSpeed(item, received);
        if (_shouldSendProgressUpdate(item.id)) {
          onProgress(item);
        }
      },
    );
  }

  Future<void> _downloadVideoWithAudio(
    domain.DownloadItem item,
    Directory downloadDir,
    CancelToken cancelToken,
    Function(domain.DownloadItem) onProgress,
  ) async {
    // Download video
    if (item.videoUrl != null) {
      item.currentPhase = 'video';
      final videoFileName = '${item.videoId}_video_temp.mp4';
      final videoPath = '${downloadDir.path}/$videoFileName';
      item.videoFilePath = videoPath;

      await _downloadFile(
        url: item.videoUrl!,
        savePath: videoPath,
        cancelToken: cancelToken,
        onProgress: (received, total) {
          if (_pausedDownloads[item.id] == true) {
            cancelToken.cancel('Paused');
            return;
          }
          final newProgress = total > 0 ? received / total : 0.0;
          _updateVideoProgress(item, newProgress);
          item.videoDownloadedBytes = received;
          if (total > 0) item.videoTotalBytes = total;
          // Update combined totals
          item.downloadedBytes = item.videoDownloadedBytes + item.audioDownloadedBytes;
          item.totalBytes = (item.videoTotalBytes ?? 0) + (item.audioTotalBytes ?? 0);
          if (item.totalBytes == 0) item.totalBytes = null;
          _calculateSpeed(item, received);
          if (_shouldSendProgressUpdate(item.id)) {
            onProgress(item);
          }
        },
      );
    }

    if (cancelToken.isCancelled || _pausedDownloads[item.id] == true) return;

    // Download audio
    if (item.audioUrl != null) {
      item.currentPhase = 'audio';
      final audioFileName = '${item.videoId}_audio_temp.m4a';
      final audioPath = '${downloadDir.path}/$audioFileName';
      item.audioFilePath = audioPath;

      await _downloadFile(
        url: item.audioUrl!,
        savePath: audioPath,
        cancelToken: cancelToken,
        onProgress: (received, total) {
          if (_pausedDownloads[item.id] == true) {
            cancelToken.cancel('Paused');
            return;
          }
          final newProgress = total > 0 ? received / total : 0.0;
          _updateAudioProgress(item, newProgress);
          item.audioDownloadedBytes = received;
          if (total > 0) item.audioTotalBytes = total;
          // Update combined totals
          item.downloadedBytes = item.videoDownloadedBytes + item.audioDownloadedBytes;
          item.totalBytes = (item.videoTotalBytes ?? 0) + (item.audioTotalBytes ?? 0);
          if (item.totalBytes == 0) item.totalBytes = null;
          _calculateSpeed(item, received);
          if (_shouldSendProgressUpdate(item.id)) {
            onProgress(item);
          }
        },
      );
    }

    if (cancelToken.isCancelled || _pausedDownloads[item.id] == true) return;

    // Set output path
    final outputFileName = '${item.videoId}.mp4';
    item.outputFilePath = '${downloadDir.path}/$outputFileName';

    // Mux video and audio using FFmpeg
    if (item.videoFilePath != null && item.audioFilePath != null) {
      item.currentPhase = 'merging';
      item.status = domain.DownloadStatus.merging;
      await _db.updateDownload(_toCompanion(item));
      onProgress(item); // Always send merging status update

      final success = await _muxVideoAndAudio(
        videoPath: item.videoFilePath!,
        audioPath: item.audioFilePath!,
        outputPath: item.outputFilePath!,
      );

      if (success) {
        // Clean up temp files
        await _deleteFile(item.videoFilePath);
        await _deleteFile(item.audioFilePath);
      } else {
        // Fallback: just use video file if muxing fails
        final videoFile = File(item.videoFilePath!);
        if (await videoFile.exists()) {
          await videoFile.rename(item.outputFilePath!);
        }
        // Still delete audio temp file
        await _deleteFile(item.audioFilePath);
      }
    } else if (item.videoFilePath != null) {
      // No audio, just rename video
      final videoFile = File(item.videoFilePath!);
      if (await videoFile.exists()) {
        await videoFile.rename(item.outputFilePath!);
      }
    }
  }

  /// Mux video and audio streams into a single MP4 file
  /// Uses Android's native MediaMuxer API via platform channel
  Future<bool> _muxVideoAndAudio({
    required String videoPath,
    required String audioPath,
    required String outputPath,
  }) async {
    try {
      if (Platform.isAndroid) {
        // Use native Android MediaMuxer via platform channel
        final result = await _muxerChannel.invokeMethod<bool>('muxVideoAudio', {
          'videoPath': videoPath,
          'audioPath': audioPath,
          'outputPath': outputPath,
        });

        if (result == true) {
          log('[Download] Native MediaMuxer muxing successful');
          return true;
        }

        log('[Download] Native MediaMuxer muxing failed');
        return false;
      } else {
        // For non-Android platforms, try FFmpeg via Process
        final result = await Process.run(
          'ffmpeg',
          [
            '-i', videoPath,
            '-i', audioPath,
            '-c:v', 'copy',
            '-c:a', 'copy',
            '-shortest',
            '-y',
            outputPath,
          ],
          runInShell: Platform.isWindows,
        );

        if (result.exitCode == 0) {
          log('[Download] FFmpeg muxing successful');
          return true;
        }

        log('[Download] FFmpeg muxing failed (exit code: ${result.exitCode})');
        return false;
      }
    } catch (e) {
      log('[Download] Muxing error: $e');
      return false;
    }
  }

  Future<void> _deleteFile(String? path) async {
    if (path == null) return;
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> _downloadFile({
    required String url,
    required String savePath,
    required CancelToken cancelToken,
    required Function(int received, int total) onProgress,
    int resumeFromByte = 0,
    int maxRetries = 3,
  }) async {
    // Enhance URL with CPN and ratebypass parameters
    final downloadUrl = _enhanceDownloadUrl(url);
    log('[Download] Enhanced URL with CPN: ${downloadUrl.contains('cpn=') ? 'yes' : 'no'}');

    // Get content length for chunked download
    int totalSize = -1;
    try {
      final headResponse = await _dio.head(
        downloadUrl,
        options: Options(
          headers: _getDownloadHeaders(),
          followRedirects: true,
        ),
      );
      final contentLength = headResponse.headers.value('content-length');
      if (contentLength != null) {
        totalSize = int.tryParse(contentLength) ?? -1;
      }
      // Check if server supports range requests
      final acceptRanges = headResponse.headers.value('accept-ranges');
      final supportsRanges = acceptRanges == 'bytes' || totalSize > 0;

      if (supportsRanges && totalSize > _chunkSize * 2) {
        // Use multi-threaded chunked download for large files
        log('[Download] Using multi-threaded download ($totalSize bytes, $_downloadThreads threads)');
        await _downloadFileChunked(
          url: downloadUrl,
          savePath: savePath,
          cancelToken: cancelToken,
          onProgress: onProgress,
          totalSize: totalSize,
          resumeFromByte: resumeFromByte,
        );
        return;
      }
    } catch (e) {
      log('[Download] HEAD request failed, falling back to single-threaded: $e');
    }

    // Fall back to single-threaded download
    await _downloadFileSingleThreaded(
      url: downloadUrl,
      savePath: savePath,
      cancelToken: cancelToken,
      onProgress: onProgress,
      totalSize: totalSize,
      resumeFromByte: resumeFromByte,
      maxRetries: maxRetries,
    );
  }

  Map<String, dynamic> _getDownloadHeaders() {
    return {
      'User-Agent': 'com.google.android.youtube/19.02.39 (Linux; U; Android 14) gzip',
      'Accept': '*/*',
      'Accept-Encoding': '*',
      'Connection': 'keep-alive',
    };
  }

  /// Multi-threaded chunked download for faster speeds
  Future<void> _downloadFileChunked({
    required String url,
    required String savePath,
    required CancelToken cancelToken,
    required Function(int received, int total) onProgress,
    required int totalSize,
    int resumeFromByte = 0,
  }) async {
    final file = File(savePath);
    final tempDir = file.parent;

    // Calculate chunks
    final chunkCount = (totalSize / _chunkSize).ceil();
    final threadsToUse = math.min(_downloadThreads, chunkCount);
    final chunksPerThread = (chunkCount / threadsToUse).ceil();

    log('[Download] Total: $totalSize bytes, Chunks: $chunkCount, Threads: $threadsToUse');

    // Track progress per chunk
    final chunkProgress = List<int>.filled(chunkCount, 0);
    int lastReportedTotal = resumeFromByte;

    void updateProgress() {
      final totalReceived = chunkProgress.fold(0, (a, b) => a + b) + resumeFromByte;
      if (totalReceived > lastReportedTotal) {
        lastReportedTotal = totalReceived;
        onProgress(totalReceived, totalSize);
      }
    }

    // Download chunks in parallel
    final futures = <Future<void>>[];
    for (int thread = 0; thread < threadsToUse; thread++) {
      final startChunk = thread * chunksPerThread;
      final endChunk = math.min(startChunk + chunksPerThread, chunkCount);

      futures.add(_downloadChunkRange(
        url: url,
        tempDir: tempDir.path,
        cancelToken: cancelToken,
        totalSize: totalSize,
        startChunk: startChunk,
        endChunk: endChunk,
        chunkProgress: chunkProgress,
        onProgressUpdate: updateProgress,
      ));
    }

    try {
      await Future.wait(futures);
    } catch (e) {
      if (cancelToken.isCancelled) rethrow;
      log('[Download] Chunk download failed: $e');
      rethrow;
    }

    // Merge chunks into final file
    final sink = file.openWrite();
    try {
      for (int i = 0; i < chunkCount; i++) {
        final chunkFile = File('${tempDir.path}/.chunk_$i');
        if (await chunkFile.exists()) {
          await sink.addStream(chunkFile.openRead());
          await chunkFile.delete();
        }
      }
    } finally {
      await sink.close();
    }

    onProgress(totalSize, totalSize);
  }

  Future<void> _downloadChunkRange({
    required String url,
    required String tempDir,
    required CancelToken cancelToken,
    required int totalSize,
    required int startChunk,
    required int endChunk,
    required List<int> chunkProgress,
    required VoidCallback onProgressUpdate,
  }) async {
    for (int chunk = startChunk; chunk < endChunk; chunk++) {
      if (cancelToken.isCancelled) return;

      final startByte = chunk * _chunkSize;
      final endByte = math.min(startByte + _chunkSize - 1, totalSize - 1);
      final chunkFile = File('$tempDir/.chunk_$chunk');

      // Skip if chunk already downloaded
      if (await chunkFile.exists()) {
        final existingSize = await chunkFile.length();
        if (existingSize == endByte - startByte + 1) {
          chunkProgress[chunk] = existingSize;
          onProgressUpdate();
          continue;
        }
      }

      int retries = 0;
      while (retries < 3) {
        try {
          await ApiClient.downloadDio.download(
            url,
            chunkFile.path,
            cancelToken: cancelToken,
            deleteOnError: false,
            onReceiveProgress: (received, _) {
              chunkProgress[chunk] = received;
              onProgressUpdate();
            },
            options: Options(
              headers: {
                ..._getDownloadHeaders(),
                'Range': 'bytes=$startByte-$endByte',
              },
              followRedirects: true,
              maxRedirects: 5,
            ),
          );
          break;
        } catch (e) {
          if (cancelToken.isCancelled) return;
          retries++;
          if (retries >= 3) rethrow;
          await Future.delayed(Duration(seconds: retries));
        }
      }
    }
  }

  /// Single-threaded download (fallback)
  Future<void> _downloadFileSingleThreaded({
    required String url,
    required String savePath,
    required CancelToken cancelToken,
    required Function(int received, int total) onProgress,
    required int totalSize,
    int resumeFromByte = 0,
    int maxRetries = 3,
  }) async {
    int retryCount = 0;
    int currentResumeFrom = resumeFromByte;

    while (retryCount <= maxRetries) {
      try {
        final headers = _getDownloadHeaders();

        // Add Range header for resume support
        if (currentResumeFrom > 0) {
          headers['Range'] = 'bytes=$currentResumeFrom-';
        }

        await _dio.download(
          url,
          savePath,
          cancelToken: cancelToken,
          deleteOnError: false,
          onReceiveProgress: (received, total) {
            final actualReceived = received + currentResumeFrom;
            final actualTotal = total > 0
                ? total + currentResumeFrom
                : (totalSize > 0 ? totalSize : total);
            onProgress(actualReceived, actualTotal);
          },
          options: Options(
            headers: headers,
            followRedirects: true,
            maxRedirects: 5,
            receiveTimeout: const Duration(minutes: 30),
          ),
        );
        return;
      } catch (e) {
        if (cancelToken.isCancelled) rethrow;

        final isRetryable = e is DioException &&
            (e.type == DioExceptionType.connectionError ||
             e.type == DioExceptionType.receiveTimeout ||
             e.message?.contains('Connection closed') == true ||
             e.error.toString().contains('Connection closed') == true);

        if (isRetryable && retryCount < maxRetries) {
          retryCount++;
          log('[Download] Connection error, retrying ($retryCount/$maxRetries)');

          final existingSize = await _getExistingFileSize(savePath);
          if (existingSize > currentResumeFrom) {
            currentResumeFrom = existingSize;
            log('[Download] Resuming from byte: $currentResumeFrom');
          }

          await Future.delayed(Duration(seconds: retryCount * 2));
          continue;
        }
        rethrow;
      }
    }
  }

  Future<int> _getExistingFileSize(String? filePath) async {
    if (filePath == null) return 0;
    final file = File(filePath);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  // Per-download tracking for speed calculation to avoid cross-contamination
  final Map<int, int> _lastReceivedBytesMap = {};
  final Map<int, DateTime> _lastSpeedUpdateMap = {};
  final Map<int, DateTime> _lastProgressUpdateMap = {};
  // Track last known progress to prevent backward jumps
  final Map<int, double> _lastVideoProgressMap = {};
  final Map<int, double> _lastAudioProgressMap = {};
  // Rolling average for smoother speed calculation
  final Map<int, List<int>> _speedSamplesMap = {};

  /// Calculate download speed and ETA based on combined downloaded bytes
  /// Uses rolling average for smoother speed display
  void _calculateSpeed(domain.DownloadItem item, int currentStreamBytes) {
    if (item.id == null) return;

    final now = DateTime.now();
    final combinedDownloaded = item.downloadedBytes;
    final combinedTotal = item.totalBytes ?? 0;

    // Initialize tracking on first call
    if (!_lastSpeedUpdateMap.containsKey(item.id!)) {
      _lastSpeedUpdateMap[item.id!] = now;
      _lastReceivedBytesMap[item.id!] = combinedDownloaded;
      _speedSamplesMap[item.id!] = [];
      return;
    }

    final lastUpdate = _lastSpeedUpdateMap[item.id!]!;
    final lastReceived = _lastReceivedBytesMap[item.id!] ?? 0;
    final elapsed = now.difference(lastUpdate).inMilliseconds;

    // Update speed every 500ms for more responsive display
    if (elapsed >= 500) {
      final bytesDiff = combinedDownloaded - lastReceived;

      if (bytesDiff > 0 && elapsed > 0) {
        final instantSpeed = (bytesDiff * 1000 / elapsed).round();

        // Add to rolling samples (keep last 5 samples for smoothing)
        final samples = _speedSamplesMap[item.id!] ?? [];
        samples.add(instantSpeed);
        if (samples.length > 5) {
          samples.removeAt(0);
        }
        _speedSamplesMap[item.id!] = samples;

        // Calculate average speed from samples
        if (samples.isNotEmpty) {
          final avgSpeed = samples.reduce((a, b) => a + b) ~/ samples.length;
          item.downloadSpeed = avgSpeed;

          // Calculate ETA based on average speed and remaining bytes
          if (avgSpeed > 0 && combinedTotal > 0) {
            final remainingBytes = combinedTotal - combinedDownloaded;
            item.etaSeconds = remainingBytes > 0 ? (remainingBytes / avgSpeed).round() : 0;
          } else {
            item.etaSeconds = null;
          }
        }
      }

      _lastReceivedBytesMap[item.id!] = combinedDownloaded;
      _lastSpeedUpdateMap[item.id!] = now;
    }
  }

  /// Throttle progress updates to max 4 times per second to prevent event spam
  /// Per-download throttling to handle multiple concurrent downloads
  bool _shouldSendProgressUpdate(int? downloadId) {
    if (downloadId == null) return true;

    final now = DateTime.now();
    final lastUpdate = _lastProgressUpdateMap[downloadId];
    if (lastUpdate == null || now.difference(lastUpdate).inMilliseconds >= 250) {
      _lastProgressUpdateMap[downloadId] = now;
      return true;
    }
    return false;
  }

  /// Update progress ensuring it only moves forward (prevents flickering)
  void _updateVideoProgress(domain.DownloadItem item, double newProgress) {
    if (item.id == null) {
      item.videoProgress = newProgress;
      return;
    }
    final lastProgress = _lastVideoProgressMap[item.id!] ?? 0.0;
    if (newProgress >= lastProgress) {
      item.videoProgress = newProgress;
      _lastVideoProgressMap[item.id!] = newProgress;
    } else {
      // Keep the higher progress value
      item.videoProgress = lastProgress;
    }
  }

  void _updateAudioProgress(domain.DownloadItem item, double newProgress) {
    if (item.id == null) {
      item.audioProgress = newProgress;
      return;
    }
    final lastProgress = _lastAudioProgressMap[item.id!] ?? 0.0;
    if (newProgress >= lastProgress) {
      item.audioProgress = newProgress;
      _lastAudioProgressMap[item.id!] = newProgress;
    } else {
      // Keep the higher progress value
      item.audioProgress = lastProgress;
    }
  }

  /// Clean up tracking data for a download
  void _cleanupTrackingData(int downloadId) {
    _lastReceivedBytesMap.remove(downloadId);
    _lastSpeedUpdateMap.remove(downloadId);
    _lastProgressUpdateMap.remove(downloadId);
    _lastVideoProgressMap.remove(downloadId);
    _lastAudioProgressMap.remove(downloadId);
    _speedSamplesMap.remove(downloadId);
  }

  Future<Directory> _getDownloadDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${appDir.path}/FluxTube/Downloads');
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }
    return downloadDir;
  }

  void _cleanup(int downloadId) {
    _cancelTokens.remove(downloadId);
    _pausedDownloads.remove(downloadId);
    _cleanupTrackingData(downloadId);
  }

  @override
  Future<Either<MainFailure, Unit>> pauseDownload(int downloadId) async {
    try {
      _pausedDownloads[downloadId] = true;
      _cancelTokens[downloadId]?.cancel('Paused');

      final item = await _db.getDownloadById(downloadId);
      if (item != null) {
        final domainItem = _toDomain(item);
        domainItem.status = domain.DownloadStatus.paused;
        await _db.updateDownload(_toCompanion(domainItem));
      }

      return const Right(unit);
    } catch (e) {
      return Left(MainFailure.unknown(message: 'Failed to pause download: $e'));
    }
  }

  @override
  Future<Either<MainFailure, domain.DownloadItem>> resumeDownload({
    required int downloadId,
    required Function(domain.DownloadItem) onProgress,
    required Function(domain.DownloadItem) onComplete,
    required Function(domain.DownloadItem, String) onError,
  }) async {
    try {
      final dbItem = await _db.getDownloadById(downloadId);
      if (dbItem == null) {
        return const Left(MainFailure.notFound(resource: 'Download'));
      }

      final item = _toDomain(dbItem);

      // Check current file size to resume from
      final existingVideoBytes = await _getExistingFileSize(item.videoFilePath);
      final existingAudioBytes = await _getExistingFileSize(item.audioFilePath);

      // Update status to downloading
      item.status = domain.DownloadStatus.downloading;
      await _db.updateDownload(_toCompanion(item));

      final cancelToken = CancelToken();
      _cancelTokens[item.id!] = cancelToken;
      _pausedDownloads[item.id!] = false;

      final downloadDir = await _getDownloadDirectory();

      if (item.downloadType == domain.DownloadType.audioOnly) {
        await _downloadAudioWithResume(item, downloadDir, cancelToken, onProgress, existingAudioBytes);
      } else if (item.downloadType == domain.DownloadType.videoOnly) {
        await _downloadVideoWithResume(item, downloadDir, cancelToken, onProgress, existingVideoBytes);
      } else {
        await _downloadVideoWithAudioResume(item, downloadDir, cancelToken, onProgress, existingVideoBytes, existingAudioBytes);
      }

      // Check if cancelled or paused
      if (_pausedDownloads[item.id] == true) {
        item.status = domain.DownloadStatus.paused;
        await _db.updateDownload(_toCompanion(item));
        return Right(item);
      }

      if (cancelToken.isCancelled) {
        item.status = domain.DownloadStatus.cancelled;
        await _db.updateDownload(_toCompanion(item));
        return Right(item);
      }

      // Mark as completed
      item.status = domain.DownloadStatus.completed;
      item.completedAt = DateTime.now();
      item.videoProgress = 1.0;
      item.audioProgress = 1.0;
      await _db.updateDownload(_toCompanion(item));

      onComplete(item);
      _cleanup(item.id!);

      return Right(item);
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        final dbItem = await _db.getDownloadById(downloadId);
        return Right(_toDomain(dbItem!));
      }

      final dbItem = await _db.getDownloadById(downloadId);
      if (dbItem != null) {
        final item = _toDomain(dbItem);
        item.status = domain.DownloadStatus.failed;
        item.errorMessage = e.toString();
        item.retryCount++;
        await _db.updateDownload(_toCompanion(item));
        onError(item, e.toString());
        _cleanup(item.id!);
      }

      return Left(MainFailure.serverError(message: 'Resume failed: $e'));
    }
  }

  Future<void> _downloadVideoWithResume(
    domain.DownloadItem item,
    Directory downloadDir,
    CancelToken cancelToken,
    Function(domain.DownloadItem) onProgress,
    int resumeFromByte,
  ) async {
    if (item.videoUrl == null) return;

    final fileName = '${item.videoId}_video.mp4';
    final filePath = '${downloadDir.path}/$fileName';
    item.videoFilePath = filePath;
    item.outputFilePath = filePath;

    await _downloadFile(
      url: item.videoUrl!,
      savePath: filePath,
      cancelToken: cancelToken,
      resumeFromByte: resumeFromByte,
      onProgress: (received, total) {
        if (_pausedDownloads[item.id] == true) {
          cancelToken.cancel('Paused');
          return;
        }
        item.downloadedBytes = received;
        if (total > 0) item.totalBytes = total;
        final newProgress = total > 0 ? received / total : 0.0;
        _updateVideoProgress(item, newProgress);
        _calculateSpeed(item, received);
        if (_shouldSendProgressUpdate(item.id)) {
          onProgress(item);
        }
      },
    );
  }

  Future<void> _downloadAudioWithResume(
    domain.DownloadItem item,
    Directory downloadDir,
    CancelToken cancelToken,
    Function(domain.DownloadItem) onProgress,
    int resumeFromByte,
  ) async {
    if (item.audioUrl == null) return;

    final fileName = '${item.videoId}_audio.m4a';
    final filePath = '${downloadDir.path}/$fileName';
    item.audioFilePath = filePath;
    item.outputFilePath = filePath;

    await _downloadFile(
      url: item.audioUrl!,
      savePath: filePath,
      cancelToken: cancelToken,
      resumeFromByte: resumeFromByte,
      onProgress: (received, total) {
        if (_pausedDownloads[item.id] == true) {
          cancelToken.cancel('Paused');
          return;
        }
        item.downloadedBytes = received;
        if (total > 0) item.totalBytes = total;
        final newProgress = total > 0 ? received / total : 0.0;
        _updateAudioProgress(item, newProgress);
        _calculateSpeed(item, received);
        if (_shouldSendProgressUpdate(item.id)) {
          onProgress(item);
        }
      },
    );
  }

  Future<void> _downloadVideoWithAudioResume(
    domain.DownloadItem item,
    Directory downloadDir,
    CancelToken cancelToken,
    Function(domain.DownloadItem) onProgress,
    int videoResumeBytes,
    int audioResumeBytes,
  ) async {
    // Resume video download if not complete
    if (item.videoUrl != null && item.videoProgress < 1.0) {
      item.currentPhase = 'video';
      final videoFileName = '${item.videoId}_video_temp.mp4';
      final videoPath = '${downloadDir.path}/$videoFileName';
      item.videoFilePath = videoPath;

      await _downloadFile(
        url: item.videoUrl!,
        savePath: videoPath,
        cancelToken: cancelToken,
        resumeFromByte: videoResumeBytes,
        onProgress: (received, total) {
          if (_pausedDownloads[item.id] == true) {
            cancelToken.cancel('Paused');
            return;
          }
          final newProgress = total > 0 ? received / total : 0.0;
          _updateVideoProgress(item, newProgress);
          item.videoDownloadedBytes = received;
          if (total > 0) item.videoTotalBytes = total;
          // Update combined totals
          item.downloadedBytes = item.videoDownloadedBytes + item.audioDownloadedBytes;
          item.totalBytes = (item.videoTotalBytes ?? 0) + (item.audioTotalBytes ?? 0);
          if (item.totalBytes == 0) item.totalBytes = null;
          _calculateSpeed(item, received);
          if (_shouldSendProgressUpdate(item.id)) {
            onProgress(item);
          }
        },
      );
    }

    if (cancelToken.isCancelled || _pausedDownloads[item.id] == true) return;

    // Resume audio download if not complete
    if (item.audioUrl != null && item.audioProgress < 1.0) {
      item.currentPhase = 'audio';
      final audioFileName = '${item.videoId}_audio_temp.m4a';
      final audioPath = '${downloadDir.path}/$audioFileName';
      item.audioFilePath = audioPath;

      await _downloadFile(
        url: item.audioUrl!,
        savePath: audioPath,
        cancelToken: cancelToken,
        resumeFromByte: audioResumeBytes,
        onProgress: (received, total) {
          if (_pausedDownloads[item.id] == true) {
            cancelToken.cancel('Paused');
            return;
          }
          final newProgress = total > 0 ? received / total : 0.0;
          _updateAudioProgress(item, newProgress);
          item.audioDownloadedBytes = received;
          if (total > 0) item.audioTotalBytes = total;
          // Update combined totals
          item.downloadedBytes = item.videoDownloadedBytes + item.audioDownloadedBytes;
          item.totalBytes = (item.videoTotalBytes ?? 0) + (item.audioTotalBytes ?? 0);
          if (item.totalBytes == 0) item.totalBytes = null;
          _calculateSpeed(item, received);
          if (_shouldSendProgressUpdate(item.id)) {
            onProgress(item);
          }
        },
      );
    }

    if (cancelToken.isCancelled || _pausedDownloads[item.id] == true) return;

    // Set output path
    final outputFileName = '${item.videoId}.mp4';
    item.outputFilePath = '${downloadDir.path}/$outputFileName';

    // Mux video and audio using FFmpeg
    if (item.videoFilePath != null && item.audioFilePath != null) {
      item.currentPhase = 'merging';
      item.status = domain.DownloadStatus.merging;
      await _db.updateDownload(_toCompanion(item));
      onProgress(item); // Always send merging status update

      final success = await _muxVideoAndAudio(
        videoPath: item.videoFilePath!,
        audioPath: item.audioFilePath!,
        outputPath: item.outputFilePath!,
      );

      if (success) {
        // Clean up temp files
        await _deleteFile(item.videoFilePath);
        await _deleteFile(item.audioFilePath);
      } else {
        // Fallback: just use video file if muxing fails
        final videoFile = File(item.videoFilePath!);
        if (await videoFile.exists()) {
          await videoFile.rename(item.outputFilePath!);
        }
        await _deleteFile(item.audioFilePath);
      }
    } else if (item.videoFilePath != null) {
      final videoFile = File(item.videoFilePath!);
      if (await videoFile.exists()) {
        await videoFile.rename(item.outputFilePath!);
      }
    }
  }

  @override
  Future<Either<MainFailure, Unit>> cancelDownload(int downloadId) async {
    try {
      _cancelTokens[downloadId]?.cancel('Cancelled');

      final dbItem = await _db.getDownloadById(downloadId);
      if (dbItem != null) {
        final item = _toDomain(dbItem);
        item.status = domain.DownloadStatus.cancelled;
        await _db.updateDownload(_toCompanion(item));

        // Delete partial files
        await _deletePartialFiles(item);
      }

      _cleanup(downloadId);
      return const Right(unit);
    } catch (e) {
      return Left(MainFailure.unknown(message: 'Failed to cancel download: $e'));
    }
  }

  @override
  Future<Either<MainFailure, Unit>> deleteDownload(int downloadId) async {
    try {
      final dbItem = await _db.getDownloadById(downloadId);
      if (dbItem != null) {
        final item = _toDomain(dbItem);
        // Delete files
        await _deleteAllFiles(item);

        // Remove from database
        await _db.deleteDownload(downloadId);
      }

      return const Right(unit);
    } catch (e) {
      return Left(MainFailure.unknown(message: 'Failed to delete download: $e'));
    }
  }

  Future<void> _deletePartialFiles(domain.DownloadItem item) async {
    final paths = [item.videoFilePath, item.audioFilePath];
    for (final path in paths) {
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }
    }
  }

  Future<void> _deleteAllFiles(domain.DownloadItem item) async {
    final paths = [item.videoFilePath, item.audioFilePath, item.outputFilePath];
    for (final path in paths) {
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }
    }
  }

  @override
  Future<Either<MainFailure, List<domain.DownloadItem>>> getAllDownloads({
    String profileName = 'default',
  }) async {
    try {
      final downloads = await _db.getAllDownloads(profileName);
      return Right(downloads.map(_toDomain).toList());
    } catch (e) {
      return Left(MainFailure.unknown(message: 'Failed to get downloads: $e'));
    }
  }

  @override
  Future<Either<MainFailure, List<domain.DownloadItem>>> getDownloadsByStatus({
    required domain.DownloadStatus status,
    String profileName = 'default',
  }) async {
    try {
      final downloads = await _db.getDownloadsByStatus(profileName, status.index);
      return Right(downloads.map(_toDomain).toList());
    } catch (e) {
      return Left(MainFailure.unknown(message: 'Failed to get downloads: $e'));
    }
  }

  @override
  Future<int> getActiveDownloadsCount() async {
    return await _db.getActiveDownloadsCount();
  }

  @override
  Future<bool> isVideoDownloaded(String videoId, {String profileName = 'default'}) async {
    final download = await _db.getCompletedDownload(videoId, profileName);
    return download != null;
  }

  @override
  Future<String?> getDownloadedFilePath(String videoId, {String profileName = 'default'}) async {
    final download = await _db.getCompletedDownload(videoId, profileName);
    return download?.outputFilePath;
  }

  @override
  Future<void> cleanupIncompleteDownloads() async {
    final downloads = await _db.getDownloadsByStatus('default', domain.DownloadStatus.downloading.index);

    for (final dbItem in downloads) {
      final item = _toDomain(dbItem);
      item.status = domain.DownloadStatus.failed;
      item.errorMessage = 'Download interrupted';
      await _db.updateDownload(_toCompanion(item));
    }
  }

  @override
  Future<Either<MainFailure, Unit>> saveToDevice(domain.DownloadItem item) async {
    try {
      if (item.outputFilePath == null) {
        return const Left(MainFailure.notFound(resource: 'Output file path'));
      }

      final sourceFile = File(item.outputFilePath!);
      if (!await sourceFile.exists()) {
        return const Left(MainFailure.notFound(resource: 'Downloaded file'));
      }

      // Determine the public directory based on download type
      // For video: Movies folder, for audio: Music folder
      Directory? publicDir;
      String subFolder;

      if (Platform.isAndroid) {
        // On Android, use the public downloads directory
        // This makes files visible in file managers and media apps
        if (item.downloadType == domain.DownloadType.audioOnly) {
          publicDir = Directory('/storage/emulated/0/Music');
          subFolder = 'FluxTube';
        } else {
          publicDir = Directory('/storage/emulated/0/Movies');
          subFolder = 'FluxTube';
        }
      } else {
        // On other platforms, use the downloads directory
        publicDir = await getDownloadsDirectory();
        subFolder = 'FluxTube';
      }

      if (publicDir == null) {
        return const Left(MainFailure.unknown(message: 'Could not access public storage'));
      }

      // Create the FluxTube subfolder
      final targetDir = Directory('${publicDir.path}/$subFolder');
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      // Generate a safe filename from the title
      final safeTitle = item.title
          .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      // Get file extension from source
      final sourceExt = item.outputFilePath!.split('.').last;
      final targetFileName = '$safeTitle.$sourceExt';
      final targetPath = '${targetDir.path}/$targetFileName';

      // Check if file already exists, if so add a number suffix
      var finalPath = targetPath;
      var counter = 1;
      while (await File(finalPath).exists()) {
        finalPath = '${targetDir.path}/$safeTitle ($counter).$sourceExt';
        counter++;
      }

      // Copy the file to public storage
      await sourceFile.copy(finalPath);

      log('[Download] Saved to device: $finalPath');

      return const Right(unit);
    } catch (e) {
      log('[Download] Save to device failed: $e');
      return Left(MainFailure.unknown(message: 'Failed to save to device: $e'));
    }
  }
}
