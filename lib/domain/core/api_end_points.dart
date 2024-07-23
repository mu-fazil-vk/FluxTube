import 'package:fluxtube/core/strings.dart';

class ApiEndPoints {
  static const feed = "$kBaseUrl/feed/unauthenticated?channels=";
  static const trending = "$kBaseUrl/trending?region=";
  static const watch = "$kBaseUrl/streams/";
  static const comments = "$kBaseUrl/comments/";
  static const search = "$kBaseUrl/search?q=";
  static const moreSearch = "$kBaseUrl/nextpage/search?q=";
  static const suggestions = "$kBaseUrl/suggestions?query=";
  static const commentReplies = "$kBaseUrl/nextpage/comments/";
  static const channel = "$kBaseUrl/channel/";
  static const moreChannelVideos = "$kBaseUrl/nextpage/channel/";
}
