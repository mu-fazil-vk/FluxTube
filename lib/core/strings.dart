// ignore_for_file: public_member_api_docs, sort_constructors_firstclass BaseUrl {
class BaseUrl {
  static String _kBaseUrl = 'https://api.piped.private.coffee/';
  // inv.nadeko.net started answering 403 to API clients; this was the only
  // clearnet instance serving both API and media in the 2026-10-02 probe.
  static String _kInvidiousBaseUrl = 'https://invidious.f5.si';

  static String get kBaseUrl => _kBaseUrl;
  static String get kInvidiousBaseUrl => _kInvidiousBaseUrl;

  static void updateBaseUrl(String newBaseUrl) {
    _kBaseUrl = newBaseUrl;
  }

  static void updateInvidiousBaseUrl(String newInvidiousBaseUrl) {
    _kInvidiousBaseUrl = newInvidiousBaseUrl;
  }
}


const String kYTBaseUrl = 'https://www.youtube.com/watch?v=';
const String kYTChannelUrl = 'https://youtube.com/channel/';
const String kInstanceUrl =
    'https://raw.githubusercontent.com/TeamPiped/documentation/main/content/docs/public-instances/index.md';
const String kInvidiousInstanceUrl = 'https://api.invidious.io/instances.json';
