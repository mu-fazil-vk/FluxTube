// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watch_resp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WatchResp _$WatchRespFromJson(Map<String, dynamic> json) => WatchResp(
      title: json['title'] as String?,
      description: json['description'] as String?,
      uploadDate: json['uploadDate'] as String?,
      uploader: json['uploader'] as String?,
      uploaderUrl: json['uploaderUrl'] as String?,
      uploaderAvatar: json['uploaderAvatar'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      hls: json['hls'] as String?,
      dash: json['dash'],
      lbryId: json['lbryId'],
      category: json['category'] as String?,
      license: json['license'] as String?,
      visibility: json['visibility'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      metaInfo: json['metaInfo'] as List<dynamic>?,
      uploaderVerified: json['uploaderVerified'] as bool?,
      duration: (json['duration'] as num?)?.toInt(),
      views: (json['views'] as num?)?.toInt(),
      likes: (json['likes'] as num?)?.toInt(),
      dislikes: (json['dislikes'] as num?)?.toInt(),
      uploaderSubscriberCount:
          (json['uploaderSubscriberCount'] as num?)?.toInt(),
      audioStreams: (json['audioStreams'] as List<dynamic>?)
          ?.map((e) => AudioStream.fromJson(e as Map<String, dynamic>))
          .toList(),
      videoStreams: (json['videoStreams'] as List<dynamic>?)
              ?.map((e) => VideoStream.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      relatedStreams: (json['relatedStreams'] as List<dynamic>?)
          ?.map((e) => RelatedStream.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtitles: (json['subtitles'] as List<dynamic>?)
          ?.map((e) => Subtitle.fromJson(e as Map<String, dynamic>))
          .toList(),
      livestream: json['livestream'] as bool?,
      proxyUrl: json['proxyUrl'] as String?,
      chapters: json['chapters'] as List<dynamic>?,
      previewFrames: (json['previewFrames'] as List<dynamic>?)
          ?.map((e) => PreviewFrame.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$WatchRespToJson(WatchResp instance) => <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'uploadDate': instance.uploadDate,
      'uploader': instance.uploader,
      'uploaderUrl': instance.uploaderUrl,
      'uploaderAvatar': instance.uploaderAvatar,
      'thumbnailUrl': instance.thumbnailUrl,
      'hls': instance.hls,
      'dash': instance.dash,
      'lbryId': instance.lbryId,
      'category': instance.category,
      'license': instance.license,
      'visibility': instance.visibility,
      'tags': instance.tags,
      'metaInfo': instance.metaInfo,
      'uploaderVerified': instance.uploaderVerified,
      'duration': instance.duration,
      'views': instance.views,
      'likes': instance.likes,
      'dislikes': instance.dislikes,
      'uploaderSubscriberCount': instance.uploaderSubscriberCount,
      'audioStreams': instance.audioStreams,
      'videoStreams': instance.videoStreams,
      'relatedStreams': instance.relatedStreams,
      'subtitles': instance.subtitles,
      'livestream': instance.livestream,
      'proxyUrl': instance.proxyUrl,
      'chapters': instance.chapters,
      'previewFrames': instance.previewFrames,
    };
