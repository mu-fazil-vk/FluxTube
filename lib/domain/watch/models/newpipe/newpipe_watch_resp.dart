import 'package:json_annotation/json_annotation.dart';
import 'newpipe_stream.dart';
import 'newpipe_related.dart';
import 'newpipe_subtitle.dart';
import 'newpipe_chapter.dart';

part 'newpipe_watch_resp.g.dart';

@JsonSerializable()
class NewPipeWatchResp {
  final String? id;
  final String? title;
  final String? description;
  final String? uploaderName;
  final String? uploaderUrl;
  final String? uploaderAvatarUrl;
  final bool? uploaderVerified;
  final int? uploaderSubscriberCount;
  final String? thumbnailUrl;
  final int? duration;
  final int? viewCount;
  final int? likeCount;
  final int? dislikeCount;
  final String? uploadDate;
  final String? textualUploadDate;
  final String? category;
  final List<String>? tags;
  final bool? isLive;
  final String? hlsUrl;
  final String? dashMpdUrl;
  final List<NewPipeAudioStream>? audioStreams;
  final List<NewPipeVideoStream>? videoStreams;
  final List<NewPipeVideoStream>? videoOnlyStreams;
  final List<NewPipeRelatedStream>? relatedStreams;
  final List<NewPipeChapter>? chapters;
  final List<NewPipeSubtitle>? subtitles;

  NewPipeWatchResp({
    this.id,
    this.title,
    this.description,
    this.uploaderName,
    this.uploaderUrl,
    this.uploaderAvatarUrl,
    this.uploaderVerified,
    this.uploaderSubscriberCount,
    this.thumbnailUrl,
    this.duration,
    this.viewCount,
    this.likeCount,
    this.dislikeCount,
    this.uploadDate,
    this.textualUploadDate,
    this.category,
    this.tags,
    this.isLive,
    this.hlsUrl,
    this.dashMpdUrl,
    this.audioStreams,
    this.videoStreams,
    this.videoOnlyStreams,
    this.relatedStreams,
    this.chapters,
    this.subtitles,
  });

  factory NewPipeWatchResp.fromJson(Map<String, dynamic> json) =>
      _$NewPipeWatchRespFromJson(json);

  Map<String, dynamic> toJson() => _$NewPipeWatchRespToJson(this);
}
