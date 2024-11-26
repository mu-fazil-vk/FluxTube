// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class VideoBasicInfo {
  final String id;
  final String? title;
  final String? thumbnailUrl;
  final String? channelName;
  final String? channelThumbnailUrl;
  final String? channelId;
  final bool? uploaderVerified;
  VideoBasicInfo({
    required this.id,
    this.title,
    this.thumbnailUrl,
    this.channelName,
    this.channelThumbnailUrl,
    this.channelId,
    this.uploaderVerified,
  });

  VideoBasicInfo copyWith({
    String? id,
    String? title,
    String? thumbnailUrl,
    String? channelName,
    String? channelThumbnailUrl,
    String? channelId,
    bool? uploaderVerified,
  }) {
    return VideoBasicInfo(
      id: id ?? this.id,
      title: title ?? this.title,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      channelName: channelName ?? this.channelName,
      channelThumbnailUrl: channelThumbnailUrl ?? this.channelThumbnailUrl,
      channelId: channelId ?? this.channelId,
      uploaderVerified: uploaderVerified ?? this.uploaderVerified,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'thumbnailUrl': thumbnailUrl,
      'channelName': channelName,
      'channelThumbnailUrl': channelThumbnailUrl,
      'channelId': channelId,
      'uploaderVerified': uploaderVerified,
    };
  }

  factory VideoBasicInfo.fromMap(Map<String, dynamic> map) {
    return VideoBasicInfo(
      id: map['id'] as String,
      title: map['title'] != null ? map['title'] as String : null,
      thumbnailUrl: map['thumbnailUrl'] != null ? map['thumbnailUrl'] as String : null,
      channelName: map['channelName'] != null ? map['channelName'] as String : null,
      channelThumbnailUrl: map['channelThumbnailUrl'] != null ? map['channelThumbnailUrl'] as String : null,
      channelId: map['channelId'] != null ? map['channelId'] as String : null,
      uploaderVerified: map['uploaderVerified'] != null ? map['uploaderVerified'] as bool : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory VideoBasicInfo.fromJson(String source) => VideoBasicInfo.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'VideoBasicInfo(id: $id, title: $title, thumbnailUrl: $thumbnailUrl, channelName: $channelName, channelThumbnailUrl: $channelThumbnailUrl, channelId: $channelId, uploaderVerified: $uploaderVerified)';
  }

  @override
  bool operator ==(covariant VideoBasicInfo other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.title == title &&
      other.thumbnailUrl == thumbnailUrl &&
      other.channelName == channelName &&
      other.channelThumbnailUrl == channelThumbnailUrl &&
      other.channelId == channelId &&
      other.uploaderVerified == uploaderVerified;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      title.hashCode ^
      thumbnailUrl.hashCode ^
      channelName.hashCode ^
      channelThumbnailUrl.hashCode ^
      channelId.hashCode ^
      uploaderVerified.hashCode;
  }
}
