// ignore_for_file: public_member_api_docs, sort_constructors_first
// FOR STORE SAVED VIDEOS & HISTORY

import 'package:isar/isar.dart';

import '../../../core/operations/math_operations.dart';

part 'local_store.g.dart';


@Collection()
class LocalStoreVideoInfo {
  String id;
  Id get isarId => fastHash(id);
  String? title;
  int? views;
  String? thumbnail;
  String? uploadedDate;
  String? uploaderName;
  String? uploaderId;
  String? uploaderAvatar;
  int? uploaderSubscriberCount;
  int? duration;
  bool? uploaderVerified;
  bool? isSaved;
  bool? isHistory;
  bool? isLive;
  int? playbackPosition;
  LocalStoreVideoInfo({
    required this.id,
    this.title,
    this.views,
    this.thumbnail,
    this.uploadedDate,
    this.uploaderName,
    this.uploaderId,
    this.uploaderAvatar,
    this.uploaderSubscriberCount,
    this.duration,
    this.uploaderVerified,
    this.isSaved,
    this.isHistory,
    this.isLive,
    this.playbackPosition,
  });
}
