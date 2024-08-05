import 'package:fluxtube/core/strings.dart';

class ApiEndPoints {
  static String feed = "${BaseUrl.kBaseUrl}/feed/unauthenticated?channels=";
  static String trending = "${BaseUrl.kBaseUrl}/trending?region=";
  static String watch = "${BaseUrl.kBaseUrl}/streams/";
  static String comments = "${BaseUrl.kBaseUrl}/comments/";
  static String search = "${BaseUrl.kBaseUrl}/search?q=";
  static String moreSearch = "${BaseUrl.kBaseUrl}/nextpage/search?q=";
  static String suggestions = "${BaseUrl.kBaseUrl}/suggestions?query=";
  static String commentReplies = "${BaseUrl.kBaseUrl}/nextpage/comments/";
  static String channel = "${BaseUrl.kBaseUrl}/channel/";
  static String moreChannelVideos = "${BaseUrl.kBaseUrl}/nextpage/channel/";
}
