// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'newpipe_watch_resp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewPipeWatchResp _$NewPipeWatchRespFromJson(Map<String, dynamic> json) =>
    NewPipeWatchResp(
      id: json['id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      uploaderName: json['uploaderName'] as String?,
      uploaderUrl: json['uploaderUrl'] as String?,
      uploaderAvatarUrl: json['uploaderAvatarUrl'] as String?,
      uploaderVerified: json['uploaderVerified'] as bool?,
      uploaderSubscriberCount:
          (json['uploaderSubscriberCount'] as num?)?.toInt(),
      thumbnailUrl: json['thumbnailUrl'] as String?,
      duration: (json['duration'] as num?)?.toInt(),
      viewCount: (json['viewCount'] as num?)?.toInt(),
      likeCount: (json['likeCount'] as num?)?.toInt(),
      dislikeCount: (json['dislikeCount'] as num?)?.toInt(),
      uploadDate: json['uploadDate'] as String?,
      textualUploadDate: json['textualUploadDate'] as String?,
      category: json['category'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      isLive: json['isLive'] as bool?,
      hlsUrl: json['hlsUrl'] as String?,
      dashMpdUrl: json['dashMpdUrl'] as String?,
      audioStreams: (json['audioStreams'] as List<dynamic>?)
          ?.map((e) => NewPipeAudioStream.fromJson(e as Map<String, dynamic>))
          .toList(),
      videoStreams: (json['videoStreams'] as List<dynamic>?)
          ?.map((e) => NewPipeVideoStream.fromJson(e as Map<String, dynamic>))
          .toList(),
      videoOnlyStreams: (json['videoOnlyStreams'] as List<dynamic>?)
          ?.map((e) => NewPipeVideoStream.fromJson(e as Map<String, dynamic>))
          .toList(),
      relatedStreams: (json['relatedStreams'] as List<dynamic>?)
          ?.map((e) => NewPipeRelatedStream.fromJson(e as Map<String, dynamic>))
          .toList(),
      // Hand-added: build_runner can't currently regenerate this file (see
      // newpipe_chapter.dart's doc comment) — this line matches exactly
      // what json_serializable would emit for the `chapters` field.
      chapters: (json['chapters'] as List<dynamic>?)
          ?.map((e) => NewPipeChapter.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtitles: (json['subtitles'] as List<dynamic>?)
          ?.map((e) => NewPipeSubtitle.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NewPipeWatchRespToJson(NewPipeWatchResp instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'uploaderName': instance.uploaderName,
      'uploaderUrl': instance.uploaderUrl,
      'uploaderAvatarUrl': instance.uploaderAvatarUrl,
      'uploaderVerified': instance.uploaderVerified,
      'uploaderSubscriberCount': instance.uploaderSubscriberCount,
      'thumbnailUrl': instance.thumbnailUrl,
      'duration': instance.duration,
      'viewCount': instance.viewCount,
      'likeCount': instance.likeCount,
      'dislikeCount': instance.dislikeCount,
      'uploadDate': instance.uploadDate,
      'textualUploadDate': instance.textualUploadDate,
      'category': instance.category,
      'tags': instance.tags,
      'isLive': instance.isLive,
      'hlsUrl': instance.hlsUrl,
      'dashMpdUrl': instance.dashMpdUrl,
      'audioStreams': instance.audioStreams,
      'videoStreams': instance.videoStreams,
      'videoOnlyStreams': instance.videoOnlyStreams,
      'relatedStreams': instance.relatedStreams,
      'chapters': instance.chapters,
      'subtitles': instance.subtitles,
    };
