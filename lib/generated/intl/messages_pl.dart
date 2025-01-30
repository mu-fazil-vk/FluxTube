// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a pl locale. All the
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
  String get localeName => 'pl';

  static String m0(count) =>
      "${Intl.plural(count, zero: 'Brak subskrybentów', one: 'subskrybent', other: 'subskrybentów')}";

  static String m1(count) =>
      "${Intl.plural(count, one: 'odpowiedź', other: 'odpowiedzi')}";

  static String m2(count) =>
      "${Intl.plural(count, zero: 'Brak widzów', one: 'widz', other: 'widzów')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("Informacje"),
        "canada": MessageLookupByLibrary.simpleMessage("Kanada"),
        "channelSubscribers": m0,
        "commentAuthorNotFound":
            MessageLookupByLibrary.simpleMessage("Nie znaleziono"),
        "commonSettingsTitle": MessageLookupByLibrary.simpleMessage("Zwykłe"),
        "defaultQuality":
            MessageLookupByLibrary.simpleMessage("Domyślna jakość"),
        "developer": MessageLookupByLibrary.simpleMessage("Programista"),
        "disablePipPlayer":
            MessageLookupByLibrary.simpleMessage("Wyłącz obraz w obrazie"),
        "disableVideoHistory":
            MessageLookupByLibrary.simpleMessage("Wyłącz historię filmów"),
        "distractionFree":
            MessageLookupByLibrary.simpleMessage("Tryb skupienia"),
        "enableHlsPlayerDescription": MessageLookupByLibrary.simpleMessage(
            "Włącz odtwarzacz HLS, aby odblokować wszystkie opcje jakości. Wyłącz, jeśli wystąpią błędy."),
        "france": MessageLookupByLibrary.simpleMessage("Francja"),
        "hideComments":
            MessageLookupByLibrary.simpleMessage("Ukryj komentarze"),
        "hideCommentsButtonFromWatchScreen":
            MessageLookupByLibrary.simpleMessage(
                "Ukryj przycisk komentarzy z ekranu oglądania"),
        "hideRelated": MessageLookupByLibrary.simpleMessage("Ukryj powiązane"),
        "hideRelatedVideosFromWatchScreen":
            MessageLookupByLibrary.simpleMessage(
                "Ukryj powiązane filmy z ekranu oglądania"),
        "history": MessageLookupByLibrary.simpleMessage("Historia"),
        "hlsPlayer": MessageLookupByLibrary.simpleMessage("Odtwarzacz Hls"),
        "home": MessageLookupByLibrary.simpleMessage("Strona główna"),
        "includeTitle": MessageLookupByLibrary.simpleMessage("Zawiera tytuł"),
        "india": MessageLookupByLibrary.simpleMessage("Indie"),
        "instances": MessageLookupByLibrary.simpleMessage("Wystąpienia"),
        "language": MessageLookupByLibrary.simpleMessage("Język"),
        "netherlands": MessageLookupByLibrary.simpleMessage("Holandia"),
        "noCommentsFound":
            MessageLookupByLibrary.simpleMessage("Nie znaleziono komentarzy"),
        "noUploadDate": MessageLookupByLibrary.simpleMessage("Brak daty"),
        "noUploaderName": MessageLookupByLibrary.simpleMessage("Brak nazwy"),
        "noVideoAvailableChangedToHls": MessageLookupByLibrary.simpleMessage(
            "Brak dostępnego źródła, automatycznie zmienianie na hls"),
        "noVideoDescription":
            MessageLookupByLibrary.simpleMessage("Brak opisu"),
        "noVideoTitle": MessageLookupByLibrary.simpleMessage("Brak tytułu"),
        "readMoreText": MessageLookupByLibrary.simpleMessage("Więcej"),
        "region": MessageLookupByLibrary.simpleMessage("Region"),
        "relatedTitle": MessageLookupByLibrary.simpleMessage("Powiązane"),
        "repliesPlural": m1,
        "retrieveDislikeCounts": MessageLookupByLibrary.simpleMessage(
            "Liczba przywróconych łapek w dół"),
        "retrieveDislikes":
            MessageLookupByLibrary.simpleMessage("Przywróć łapki w dół"),
        "retry": MessageLookupByLibrary.simpleMessage("Ponów"),
        "saved": MessageLookupByLibrary.simpleMessage("Zapisane"),
        "savedVideosTitle":
            MessageLookupByLibrary.simpleMessage("Zapisane filmy"),
        "settings": MessageLookupByLibrary.simpleMessage("Ustawienia"),
        "share": MessageLookupByLibrary.simpleMessage("Udostępnij"),
        "showLessText": MessageLookupByLibrary.simpleMessage("Pokaż mniej"),
        "subscribe": MessageLookupByLibrary.simpleMessage("Subskrybuj"),
        "swipeDownToDismissDisabled": MessageLookupByLibrary.simpleMessage(
            "Funkcja „Przesuń w dół, aby odrzucić” wyłączona"),
        "swipeUpToDismissEnabled": MessageLookupByLibrary.simpleMessage(
            "Funkcja „Przesuń w dół, aby odrzucić” włączona"),
        "switchRegion": MessageLookupByLibrary.simpleMessage(
            "Rozważ zmianę regionu, aby uzyskać lepsze wyniki."),
        "theme": MessageLookupByLibrary.simpleMessage("Motyw"),
        "thereIsNoSavedOrHistoryVideos": MessageLookupByLibrary.simpleMessage(
            "Nie masz zapisanych filmów i historii"),
        "thereIsNoSavedVideos":
            MessageLookupByLibrary.simpleMessage("Nie masz zapisanych filmów"),
        "translators": MessageLookupByLibrary.simpleMessage("Tłumacze"),
        "trending": MessageLookupByLibrary.simpleMessage("Na czasie"),
        "unitedKingdom":
            MessageLookupByLibrary.simpleMessage("Wielka Brytania"),
        "unitedStates":
            MessageLookupByLibrary.simpleMessage("Stany Zjednoczone"),
        "unknown": MessageLookupByLibrary.simpleMessage("nieznana"),
        "unknownQuality":
            MessageLookupByLibrary.simpleMessage("Nieznana jakość"),
        "version": MessageLookupByLibrary.simpleMessage("Wersja"),
        "video": MessageLookupByLibrary.simpleMessage("Film"),
        "videoViews": m2
      };
}
