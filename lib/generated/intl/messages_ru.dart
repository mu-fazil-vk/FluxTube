// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ru locale. All the
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
  String get localeName => 'ru';

  static String m0(count) =>
      "${Intl.plural(count, zero: 'Нет подписчиков', one: 'подписчик', few: 'подписчика', many: 'подписчиков', other: 'подписчика')}";

  static String m1(count) =>
      "{count, plural, =1{ответ} few{ответа} many{ответов} other{ответа}";

  static String m2(count) =>
      "${Intl.plural(count, zero: 'Нет просмотров', one: 'просмотр', few: 'просмотра', many: 'просмотров', other: 'просмотра')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("О приложении"),
        "canada": MessageLookupByLibrary.simpleMessage("Канада"),
        "channelSubscribers": m0,
        "commentAuthorNotFound":
            MessageLookupByLibrary.simpleMessage("Не найден"),
        "commonSettingsTitle": MessageLookupByLibrary.simpleMessage("Общие"),
        "defaultQuality":
            MessageLookupByLibrary.simpleMessage("Качество по умолчанию"),
        "developer": MessageLookupByLibrary.simpleMessage("Разработчик"),
        "disableVideoHistory": MessageLookupByLibrary.simpleMessage(
            "Отключить историю просмотров"),
        "distractionFree":
            MessageLookupByLibrary.simpleMessage("Отсекая лишнее"),
        "enableHlsPlayerDescription": MessageLookupByLibrary.simpleMessage(
            "Переключит на проигрыватель HLS, поддерживающий больше форматов. Отключите при ошибках."),
        "france": MessageLookupByLibrary.simpleMessage("Франция"),
        "hideComments":
            MessageLookupByLibrary.simpleMessage("Скрыть коментарии"),
        "hideCommentsButtonFromWatchScreen":
            MessageLookupByLibrary.simpleMessage(
                "Убирает кнопку показа коментариев с экрана просмотра."),
        "hideRelated": MessageLookupByLibrary.simpleMessage("Скрыть похожие"),
        "hideRelatedVideosFromWatchScreen":
            MessageLookupByLibrary.simpleMessage(
                "Убирает ленту похожих видео с экрана просмотра."),
        "history": MessageLookupByLibrary.simpleMessage("История"),
        "hlsPlayer": MessageLookupByLibrary.simpleMessage("Проигрыватель HLS"),
        "home": MessageLookupByLibrary.simpleMessage("Главная"),
        "includeTitle":
            MessageLookupByLibrary.simpleMessage("Включая название"),
        "india": MessageLookupByLibrary.simpleMessage("Индия"),
        "instances": MessageLookupByLibrary.simpleMessage("Instances"),
        "language": MessageLookupByLibrary.simpleMessage("Язык"),
        "netherlands": MessageLookupByLibrary.simpleMessage("Нидерланды"),
        "noUploadDate": MessageLookupByLibrary.simpleMessage("Без даты"),
        "noUploaderName": MessageLookupByLibrary.simpleMessage("Безымянный"),
        "noVideoAvailableChangedToHls": MessageLookupByLibrary.simpleMessage(
            "Нет доступных форматов, переход на HLS"),
        "noVideoDescription":
            MessageLookupByLibrary.simpleMessage("Без описания"),
        "noVideoTitle": MessageLookupByLibrary.simpleMessage("Неназванное"),
        "readMoreText": MessageLookupByLibrary.simpleMessage("Раскрыть"),
        "region": MessageLookupByLibrary.simpleMessage("Регион"),
        "relatedTitle": MessageLookupByLibrary.simpleMessage("Похожие"),
        "repliesPlural": m1,
        "retrieveDislikeCounts": MessageLookupByLibrary.simpleMessage(
            "Запрашивать количество дизлайков"),
        "retrieveDislikes":
            MessageLookupByLibrary.simpleMessage("Вернуть дизлайки"),
        "retry": MessageLookupByLibrary.simpleMessage("Повторить"),
        "saved": MessageLookupByLibrary.simpleMessage("Сохранено"),
        "savedVideosTitle":
            MessageLookupByLibrary.simpleMessage("Сохранённые видео"),
        "settings": MessageLookupByLibrary.simpleMessage("Настройки"),
        "share": MessageLookupByLibrary.simpleMessage("Поделиться"),
        "showLessText": MessageLookupByLibrary.simpleMessage("Скрыть"),
        "subscribe": MessageLookupByLibrary.simpleMessage("Подписаться"),
        "theme": MessageLookupByLibrary.simpleMessage("Оформление"),
        "thereIsNoSavedOrHistoryVideos": MessageLookupByLibrary.simpleMessage(
            "Сохранённых/просмотренных видео нет"),
        "thereIsNoSavedVideos":
            MessageLookupByLibrary.simpleMessage("Сохранённых видео нет"),
        "translators": MessageLookupByLibrary.simpleMessage("Переводчики"),
        "trending": MessageLookupByLibrary.simpleMessage("Тренды"),
        "unitedKingdom":
            MessageLookupByLibrary.simpleMessage("Соединённое королевство"),
        "unitedStates":
            MessageLookupByLibrary.simpleMessage("Соединённые штаты Америки"),
        "unknown": MessageLookupByLibrary.simpleMessage("неизвестно"),
        "unknownQuality":
            MessageLookupByLibrary.simpleMessage("Качество не опознано"),
        "version": MessageLookupByLibrary.simpleMessage("Версия"),
        "video": MessageLookupByLibrary.simpleMessage("Видео"),
        "videoViews": m2
      };
}
