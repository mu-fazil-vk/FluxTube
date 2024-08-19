import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class ExplodeWatchResp {
  final String id;
  final String title;
  final String author;
  final String channelId;
  final DateTime uploadDate;
  final String description;
  final Duration duration;
  final String thumbnailUrl;
  final int viewCount;
  final int likeCount;
  final int dislikeCount;
  final bool isLive;

  ExplodeWatchResp({
    required this.id,
    required this.title,
    required this.author,
    required this.channelId,
    required this.uploadDate,
    required this.description,
    required this.duration,
    required this.thumbnailUrl,
    required this.viewCount,
    required this.likeCount,
    required this.dislikeCount,
    required this.isLive,
  });

  // Initial empty state for WatchResp
  factory ExplodeWatchResp.initial() {
    return ExplodeWatchResp(
      id: '',
      title: '',
      author: '',
      channelId: '',
      uploadDate: DateTime.now(),
      description: '',
      duration: Duration.zero,
      thumbnailUrl: '',
      viewCount: 0,
      likeCount: 0,
      dislikeCount: 0,
      isLive: false,
    );
  }

  // Method to convert the ExplodeWatchResp to JSON format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'channelId': channelId,
      'uploadDate': uploadDate.toIso8601String(),
      'description': description,
      'duration': duration.toString(),
      'thumbnailUrl': thumbnailUrl,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'dislikeCount': dislikeCount,
      'isLive': isLive,
    };
  }

  // Factory method to create ExplodeWatchResp from YouTubeExplode Video object
  factory ExplodeWatchResp.fromYoutubeVideo(Video video) {
    return ExplodeWatchResp(
      id: video.id.value,
      title: video.title,
      author: video.author,
      channelId: video.channelId.value,
      uploadDate:
          video.uploadDate ?? DateTime.now(), // Fallback in case of null
      description: video.description,
      duration: video.duration ?? Duration.zero, // Fallback in case of null
      thumbnailUrl: video.thumbnails.highResUrl,
      viewCount: video.engagement.viewCount,
      likeCount: video.engagement.likeCount ?? 0,
      dislikeCount: video.engagement.dislikeCount ?? 0,
      isLive: video.isLive,
    );
  }
}

// Muxed stream model class
class MyMuxedStreamInfo {
  final String videoId;
  final int itag;
  final String url;
  final String container;
  final double size; // Size in MB
  final double bitrate; // Bitrate in Kbit/s
  final String audioCodec;
  final String videoCodec;
  final String quality;
  final String resolution;
  final Framerate framerate;
  final String codec;

  MyMuxedStreamInfo({
    required this.videoId,
    required this.itag,
    required this.url,
    required this.container,
    required this.size,
    required this.bitrate,
    required this.audioCodec,
    required this.videoCodec,
    required this.quality,
    required this.resolution,
    required this.framerate,
    required this.codec,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'videoId': videoId,
      'itag': itag,
      'url': url,
      'container': container,
      'size': size,
      'bitrate': bitrate,
      'audioCodec': audioCodec,
      'videoCodec': videoCodec,
      'quality': quality,
      'resolution': resolution,
      'framerate': framerate,
      'codec': codec,
    };
  }

  // Factory method to create MyMuxedStreamInfo from YouTubeExplode's MuxedStreamInfo object
  factory MyMuxedStreamInfo.fromYoutubeStream(MuxedStreamInfo streamInfo) {
    return MyMuxedStreamInfo(
      videoId: streamInfo.videoId.value,
      itag: streamInfo.tag,
      url: streamInfo.url.toString(),
      container: streamInfo.container.name,
      size: streamInfo.size.totalMegaBytes,
      bitrate: streamInfo.bitrate.kiloBitsPerSecond,
      audioCodec: streamInfo.audioCodec,
      videoCodec: streamInfo.videoCodec,
      quality: streamInfo.qualityLabel,
      resolution:
          '${streamInfo.videoResolution.width}x${streamInfo.videoResolution.height}',
      framerate: streamInfo.framerate,
      codec: streamInfo.codec.toString(),
    );
  }
}

//Related video
class MyRelatedVideo {
  final String id;
  final String title;
  final String author;
  final String channelId;
  final DateTime uploadDate;
  final Duration duration;
  final String thumbnailUrl;
  final int viewCount;
  final bool isLive;

  MyRelatedVideo({
    required this.id,
    required this.title,
    required this.author,
    required this.channelId,
    required this.uploadDate,
    required this.duration,
    required this.thumbnailUrl,
    required this.viewCount,
    required this.isLive,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'channelId': channelId,
      'uploadDate': uploadDate.toIso8601String(),
      'duration': duration.inSeconds,
      'thumbnailUrl': thumbnailUrl,
      'viewCount': viewCount,
      'isLive': isLive,
    };
  }

  // Factory method to create MyRelatedVideo from YouTubeExplode's Video object
  factory MyRelatedVideo.fromYoutubeVideo(Video video) {
    return MyRelatedVideo(
      id: video.id.value,
      title: video.title,
      author: video.author,
      channelId: video.channelId.value,
      uploadDate: video.uploadDate ?? DateTime.now(),
      duration: video.duration ?? Duration.zero,
      thumbnailUrl: video.thumbnails.highResUrl,
      viewCount: video.engagement.viewCount,
      isLive: video.isLive,
    );
  }
}
