import 'package:fluxtube/core/strings.dart';

class ApiEndPoints {
  static const feed = "$kBaseUrl/feed/unauthenticated?channels=";
  static const trending = "$kBaseUrl/trending?region=";
  static const watch = "$kBaseUrl/streams/";
  static const comments = "$kBaseUrl/comments/";
  static const search = "$kBaseUrl/search?q=";
  static const suggestions = "$kBaseUrl/suggestions?query=";
  static const commentReplies = "$kBaseUrl/nextpage/comments/";
}
