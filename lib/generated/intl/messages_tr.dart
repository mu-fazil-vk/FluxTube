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
      "${Intl.plural(count, one: 'Yanıt', other: 'Yanıtlar')}";

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
        "disableVideoHistory": MessageLookupByLibrary.simpleMessage(
            "Video geçmişini devre dışı bırak"),
        "distractionFree":
            MessageLookupByLibrary.simpleMessage("Distraction Free"),
        "enableHlsPlayerDescription": MessageLookupByLibrary.simpleMessage(
            "Tüm kalite seçeneklerini açmak için HLS oynatıcıyı etkinleştirin. Hata oluşursa devre dışı bırakın."),
        "france": MessageLookupByLibrary.simpleMessage("Fransa"),
        "hideComments": MessageLookupByLibrary.simpleMessage("Hide Comments"),
        "hideCommentsButtonFromWatchScreen":
            MessageLookupByLibrary.simpleMessage(
                "Hide comments button from watch screen."),
        "hideRelated": MessageLookupByLibrary.simpleMessage("Hide Related"),
        "hideRelatedVideosFromWatchScreen":
            MessageLookupByLibrary.simpleMessage(
                "Hide related videos from watch screen"),
        "history": MessageLookupByLibrary.simpleMessage("Geçmiş"),
        "hlsPlayer": MessageLookupByLibrary.simpleMessage("Hls Oynatıcı"),
        "home": MessageLookupByLibrary.simpleMessage("Ana Sayfa"),
        "includeTitle": MessageLookupByLibrary.simpleMessage("Include title"),
        "india": MessageLookupByLibrary.simpleMessage("Hindistan"),
        "instances": MessageLookupByLibrary.simpleMessage("Instances"),
        "language": MessageLookupByLibrary.simpleMessage("Dil"),
        "netherlands": MessageLookupByLibrary.simpleMessage("Hollanda"),
        "noUploadDate": MessageLookupByLibrary.simpleMessage("Tarih yok"),
        "noUploaderName": MessageLookupByLibrary.simpleMessage("İsim yok"),
        "noVideoAvailableChangedToHls": MessageLookupByLibrary.simpleMessage(
            "Mevcut video kaynağı yok, otomatik olarak hls\'ye dönüştü"),
        "noVideoDescription":
            MessageLookupByLibrary.simpleMessage("Açıklama yok"),
        "noVideoTitle": MessageLookupByLibrary.simpleMessage("Başlık yok"),
        "readMoreText": MessageLookupByLibrary.simpleMessage("Daha fazla oku"),
        "region": MessageLookupByLibrary.simpleMessage("Bölge"),
        "relatedTitle": MessageLookupByLibrary.simpleMessage("İlgili"),
        "repliesPlural": m1,
        "retrieveDislikeCounts":
            MessageLookupByLibrary.simpleMessage("Beğenmeme sayısını getir"),
        "retrieveDislikes":
            MessageLookupByLibrary.simpleMessage("Beğenilmeyenleri Getir"),
        "retry": MessageLookupByLibrary.simpleMessage("Tekrar Dene"),
        "saved": MessageLookupByLibrary.simpleMessage("Kaydedilenler"),
        "savedVideosTitle":
            MessageLookupByLibrary.simpleMessage("Kaydedilen Videolar"),
        "settings": MessageLookupByLibrary.simpleMessage("Ayarlar"),
        "share": MessageLookupByLibrary.simpleMessage("Share"),
        "showLessText": MessageLookupByLibrary.simpleMessage("Daha az göster"),
        "subscribe": MessageLookupByLibrary.simpleMessage("Abone Ol"),
        "theme": MessageLookupByLibrary.simpleMessage("Tema"),
        "thereIsNoSavedOrHistoryVideos":
            MessageLookupByLibrary.simpleMessage("Kaydedilen/geçmiş video yok"),
        "thereIsNoSavedVideos":
            MessageLookupByLibrary.simpleMessage("Kaydedilen video yok"),
        "translators": MessageLookupByLibrary.simpleMessage("Çevirmenler"),
        "trending": MessageLookupByLibrary.simpleMessage("Popüler"),
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
