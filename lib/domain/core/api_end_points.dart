import 'package:fluxtube/core/strings.dart';

class ApiEndPoints {
  static String feed = "${BaseUrl.kBaseUrl}feed/unauthenticated?channels=";
  static String trending = "${BaseUrl.kBaseUrl}trending?region=";
  static String watch = "${BaseUrl.kBaseUrl}streams/";
  static String comments = "${BaseUrl.kBaseUrl}comments/";
  static String search = "${BaseUrl.kBaseUrl}search?q=";
  static String moreSearch = "${BaseUrl.kBaseUrl}nextpage/search?q=";
  static String suggestions = "${BaseUrl.kBaseUrl}suggestions?query=";
  static String commentReplies = "${BaseUrl.kBaseUrl}nextpage/comments/";
  static String channel = "${BaseUrl.kBaseUrl}channel/";
  static String moreChannelVideos = "${BaseUrl.kBaseUrl}nextpage/channel/";
}

class InvidiousApiEndpoints {
  static String trending =
      "${BaseUrl.kInvidiousBaseUrl}api/v1/trending?region=";
  static String search = "${BaseUrl.kInvidiousBaseUrl}/api/v1/search?q=";
  static String suggestions =
      "${BaseUrl.kInvidiousBaseUrl}api/v1/search/suggestions?q=";
  static String watch = "${BaseUrl.kInvidiousBaseUrl}api/v1/videos/";
  static String comments = "${BaseUrl.kInvidiousBaseUrl}api/v1/comments/";
  static String channel = "${BaseUrl.kInvidiousBaseUrl}api/v1/channels/";
}
