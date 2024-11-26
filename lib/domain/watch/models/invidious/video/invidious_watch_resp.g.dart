// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invidious_watch_resp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvidiousWatchResp _$InvidiousWatchRespFromJson(Map<String, dynamic> json) =>
    InvidiousWatchResp(
      type: json['type'] as String?,
      title: json['title'] as String?,
      videoId: json['videoId'] as String?,
      videoThumbnails: (json['videoThumbnails'] as List<dynamic>?)
          ?.map((e) => VideoThumbnail.fromJson(e as Map<String, dynamic>))
          .toList(),
      storyboards: (json['storyboards'] as List<dynamic>?)
          ?.map((e) => Storyboard.fromJson(e as Map<String, dynamic>))
          .toList(),
      description: json['description'] as String?,
      descriptionHtml: json['descriptionHtml'] as String?,
      published: (json['published'] as num?)?.toInt(),
      publishedText: json['publishedText'] as String?,
      keywords: json['keywords'] as List<dynamic>?,
      viewCount: (json['viewCount'] as num?)?.toInt(),
      likeCount: (json['likeCount'] as num?)?.toInt(),
      dislikeCount: (json['dislikeCount'] as num?)?.toInt(),
      paid: json['paid'] as bool?,
      premium: json['premium'] as bool?,
      isFamilyFriendly: json['isFamilyFriendly'] as bool?,
      allowedRegions: (json['allowedRegions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      genre: json['genre'] as String?,
      genreUrl: json['genreUrl'],
      author: json['author'] as String?,
      authorId: json['authorId'] as String?,
      authorUrl: json['authorUrl'] as String?,
      authorVerified: json['authorVerified'] as bool?,
      authorThumbnails: (json['authorThumbnails'] as List<dynamic>?)
          ?.map((e) => AuthorThumbnail.fromJson(e as Map<String, dynamic>))
          .toList(),
      subCountText: json['subCountText'] as String?,
      lengthSeconds: (json['lengthSeconds'] as num?)?.toInt(),
      allowRatings: json['allowRatings'] as bool?,
      rating: (json['rating'] as num?)?.toInt(),
      isListed: json['isListed'] as bool?,
      liveNow: json['liveNow'] as bool?,
      isPostLiveDvr: json['isPostLiveDvr'] as bool?,
      isUpcoming: json['isUpcoming'] as bool?,
      dashUrl: json['dashUrl'] as String?,
      adaptiveFormats: (json['adaptiveFormats'] as List<dynamic>?)
          ?.map((e) => AdaptiveFormat.fromJson(e as Map<String, dynamic>))
          .toList(),
      formatStreams: (json['formatStreams'] as List<dynamic>?)
          ?.map((e) => FormatStream.fromJson(e as Map<String, dynamic>))
          .toList(),
      captions: (json['captions'] as List<dynamic>?)
          ?.map((e) => Caption.fromJson(e as Map<String, dynamic>))
          .toList(),
      recommendedVideos: (json['recommendedVideos'] as List<dynamic>?)
          ?.map((e) => RecommendedVideo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$InvidiousWatchRespToJson(InvidiousWatchResp instance) =>
    <String, dynamic>{
      'type': instance.type,
      'title': instance.title,
      'videoId': instance.videoId,
      'videoThumbnails': instance.videoThumbnails,
      'storyboards': instance.storyboards,
      'description': instance.description,
      'descriptionHtml': instance.descriptionHtml,
      'published': instance.published,
      'publishedText': instance.publishedText,
      'keywords': instance.keywords,
      'viewCount': instance.viewCount,
      'likeCount': instance.likeCount,
      'dislikeCount': instance.dislikeCount,
      'paid': instance.paid,
      'premium': instance.premium,
      'isFamilyFriendly': instance.isFamilyFriendly,
      'allowedRegions': instance.allowedRegions,
      'genre': instance.genre,
      'genreUrl': instance.genreUrl,
      'author': instance.author,
      'authorId': instance.authorId,
      'authorUrl': instance.authorUrl,
      'authorVerified': instance.authorVerified,
      'authorThumbnails': instance.authorThumbnails,
      'subCountText': instance.subCountText,
      'lengthSeconds': instance.lengthSeconds,
      'allowRatings': instance.allowRatings,
      'rating': instance.rating,
      'isListed': instance.isListed,
      'liveNow': instance.liveNow,
      'isPostLiveDvr': instance.isPostLiveDvr,
      'isUpcoming': instance.isUpcoming,
      'dashUrl': instance.dashUrl,
      'adaptiveFormats': instance.adaptiveFormats,
      'formatStreams': instance.formatStreams,
      'captions': instance.captions,
      'recommendedVideos': instance.recommendedVideos,
    };
