// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a tr locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'tr';

  static String m0(count) =>
      "${Intl.plural(count, zero: 'Abone yok', one: 'abone', other: 'abone')}";

  static String m1(count) =>
      "${Intl.plural(count, one: 'Yanıt', other: 'Yanıt')}";

  static String m2(count) =>
      "${Intl.plural(count, zero: 'Görüntüleme yok', one: 'görüntüleme', other: 'görüntüleme')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("Hakkında"),
        "canada": MessageLookupByLibrary.simpleMessage("Kanada"),
        "channelSubscribers": m0,
        "commentAuthorNotFound":
            MessageLookupByLibrary.simpleMessage("Bulunamadı"),
        "commonSettingsTitle": MessageLookupByLibrary.simpleMessage("Genel"),
        "defaultQuality":
            MessageLookupByLibrary.simpleMessage("Varsayılan Kalite"),
        "developer": MessageLookupByLibrary.simpleMessage("Geliştirici"),
        "disablePipPlayer":
            MessageLookupByLibrary.simpleMessage("Disable PIP player"),
        "disableVideoHistory": MessageLookupByLibrary.simpleMessage(
            "Video geçmişini devre dışı bırak"),
        "distractionFree":
            MessageLookupByLibrary.simpleMessage("Dikkat Dağıtmayan"),
        "enableHlsPlayerDescription": MessageLookupByLibrary.simpleMessage(
            "Tüm kalite seçeneklerini açmak için HLS oynatıcıyı etkinleştirin. Hata oluşursa devre dışı bırakın."),
        "france": MessageLookupByLibrary.simpleMessage("Fransa"),
        "hideComments": MessageLookupByLibrary.simpleMessage("Yorumları Gizle"),
        "hideCommentsButtonFromWatchScreen":
            MessageLookupByLibrary.simpleMessage(
                "İzleme ekranından yorum butonunu gizle"),
        "hideRelated":
            MessageLookupByLibrary.simpleMessage("İlgili Videoları Gizle"),
        "hideRelatedVideosFromWatchScreen":
            MessageLookupByLibrary.simpleMessage(
                "İzleme ekranından ilgili videoları gizle"),
        "history": MessageLookupByLibrary.simpleMessage("Geçmiş"),
        "hlsPlayer": MessageLookupByLibrary.simpleMessage("Hls Oynatıcı"),
        "home": MessageLookupByLibrary.simpleMessage("Ana Sayfa"),
        "includeTitle":
            MessageLookupByLibrary.simpleMessage("Başlığı dahil et"),
        "india": MessageLookupByLibrary.simpleMessage("Hindistan"),
        "instances": MessageLookupByLibrary.simpleMessage("Örnekler"),
        "language": MessageLookupByLibrary.simpleMessage("Dil"),
        "netherlands": MessageLookupByLibrary.simpleMessage("Hollanda"),
        "noCommentsFound":
            MessageLookupByLibrary.simpleMessage("No Comments Found"),
        "noUploadDate": MessageLookupByLibrary.simpleMessage("Tarih yok"),
        "noUploaderName": MessageLookupByLibrary.simpleMessage("İsim yok"),
        "noVideoAvailableChangedToHls": MessageLookupByLibrary.simpleMessage(
            "Video kaynağı yok, otomatik olarak hls\'ye değiştirildi"),
        "noVideoDescription":
            MessageLookupByLibrary.simpleMessage("Açıklama yok"),
        "noVideoTitle": MessageLookupByLibrary.simpleMessage("Başlık yok"),
        "readMoreText": MessageLookupByLibrary.simpleMessage("Devamını oku"),
        "region": MessageLookupByLibrary.simpleMessage("Bölge"),
        "relatedTitle": MessageLookupByLibrary.simpleMessage("İlgili"),
        "repliesPlural": m1,
        "retrieveDislikeCounts": MessageLookupByLibrary.simpleMessage(
            "Beğenmeme sayısını geri getir"),
        "retrieveDislikes":
            MessageLookupByLibrary.simpleMessage("Beğenmeme sayılarını gör"),
        "retry": MessageLookupByLibrary.simpleMessage("Tekrar Dene"),
        "saved": MessageLookupByLibrary.simpleMessage("Kaydedilenler"),
        "savedVideosTitle":
            MessageLookupByLibrary.simpleMessage("Kaydedilen Videolar"),
        "settings": MessageLookupByLibrary.simpleMessage("Ayarlar"),
        "share": MessageLookupByLibrary.simpleMessage("Paylaş"),
        "showLessText": MessageLookupByLibrary.simpleMessage("Daha az göster"),
        "subscribe": MessageLookupByLibrary.simpleMessage("Abone Ol"),
        "swipeDownToDismissDisabled": MessageLookupByLibrary.simpleMessage(
            "\'Swipe down to dismiss\' disabled"),
        "swipeUpToDismissEnabled": MessageLookupByLibrary.simpleMessage(
            "\'Swipe up to dismiss\' enabled"),
        "switchRegion": MessageLookupByLibrary.simpleMessage(
            "Daha iyi sonuçlar için lütfen farklı bir bölgeye geçmeyi düşünün."),
        "theme": MessageLookupByLibrary.simpleMessage("Tema"),
        "thereIsNoSavedOrHistoryVideos":
            MessageLookupByLibrary.simpleMessage("Kaydedilen/geçmiş video yok"),
        "thereIsNoSavedVideos":
            MessageLookupByLibrary.simpleMessage("Kaydedilen video yok"),
        "translators": MessageLookupByLibrary.simpleMessage("Çevirmenler"),
        "trending": MessageLookupByLibrary.simpleMessage("Trendler"),
        "unitedKingdom":
            MessageLookupByLibrary.simpleMessage("Birleşik Krallık"),
        "unitedStates":
            MessageLookupByLibrary.simpleMessage("Amerika Birleşik Devletleri"),
        "unknown": MessageLookupByLibrary.simpleMessage("bilinmiyor"),
        "unknownQuality":
            MessageLookupByLibrary.simpleMessage("Bilinmeyen Kalite"),
        "version": MessageLookupByLibrary.simpleMessage("Sürüm"),
        "video": MessageLookupByLibrary.simpleMessage("Video"),
        "videoViews": m2
      };
}
