// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ar locale. All the
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
  String get localeName => 'ar';

  static String m0(count) =>
      "${Intl.plural(count, zero: 'لا مشتركين', one: 'مشترك', two: 'مشتركين', few: 'مشتركين', many: 'مشتركين', other: 'مشتركين')}";

  static String m1(count) =>
      "${Intl.plural(count, zero: '', one: 'تعليق', two: 'تعليقات', few: 'تعليقات', many: 'تعليقات', other: 'تعليقات')}";

  static String m2(count) =>
      "${Intl.plural(count, zero: 'لا مشاهدات', one: 'مشاهدة', two: 'مشاهدات', few: 'مشاهدات', many: 'مشاهدات', other: 'مشاهدات')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("حول"),
        "canada": MessageLookupByLibrary.simpleMessage("كندا"),
        "channelSubscribers": m0,
        "commentAuthorNotFound":
            MessageLookupByLibrary.simpleMessage("غير متاح"),
        "commonSettingsTitle": MessageLookupByLibrary.simpleMessage("شائع"),
        "defaultQuality":
            MessageLookupByLibrary.simpleMessage("الجودة الافتراضية"),
        "developer": MessageLookupByLibrary.simpleMessage("المطور"),
        "disablePipPlayer":
            MessageLookupByLibrary.simpleMessage("Disable PIP player"),
        "disableVideoHistory":
            MessageLookupByLibrary.simpleMessage("عطل تاريخ المشاهدة"),
        "distractionFree": MessageLookupByLibrary.simpleMessage("بلا تشتت"),
        "enableHlsPlayerDescription": MessageLookupByLibrary.simpleMessage(
            "شغل مشغل المباشر لتفعيل كل اختيارات الجودة، عطله عند ظهور أي أخطاء."),
        "france": MessageLookupByLibrary.simpleMessage("فرنسا"),
        "hideComments": MessageLookupByLibrary.simpleMessage("إخفاء التعليقات"),
        "hideCommentsButtonFromWatchScreen":
            MessageLookupByLibrary.simpleMessage(
                "إخفاء زر التعليقات من شاشة المشاهدة."),
        "hideRelated": MessageLookupByLibrary.simpleMessage("إخفاء المرتبط"),
        "hideRelatedVideosFromWatchScreen":
            MessageLookupByLibrary.simpleMessage(
                "إخفاء الفيديوهات المرتبطة من شاشة المشاهدة"),
        "history": MessageLookupByLibrary.simpleMessage("التاريخ"),
        "hlsPlayer": MessageLookupByLibrary.simpleMessage("مشغل المباشر"),
        "home": MessageLookupByLibrary.simpleMessage("الرئيسية"),
        "includeTitle": MessageLookupByLibrary.simpleMessage("تضمين العنوان"),
        "india": MessageLookupByLibrary.simpleMessage("الهند"),
        "instances": MessageLookupByLibrary.simpleMessage("فوريات"),
        "language": MessageLookupByLibrary.simpleMessage("اللغة"),
        "netherlands": MessageLookupByLibrary.simpleMessage("هولندا"),
        "noCommentsFound":
            MessageLookupByLibrary.simpleMessage("No Comments Found"),
        "noUploadDate": MessageLookupByLibrary.simpleMessage("بلا تاريخ"),
        "noUploaderName": MessageLookupByLibrary.simpleMessage("بدون اسم"),
        "noVideoAvailableChangedToHls": MessageLookupByLibrary.simpleMessage(
            "لا يوجد مصدر للفيديو، تغير أوتوماتيكيا إلى المباشر"),
        "noVideoDescription":
            MessageLookupByLibrary.simpleMessage("لا يوجد وصف"),
        "noVideoTitle": MessageLookupByLibrary.simpleMessage("بلا عنوان"),
        "readMoreText": MessageLookupByLibrary.simpleMessage("اقرأ المزيد"),
        "region": MessageLookupByLibrary.simpleMessage("المنطقة"),
        "relatedTitle": MessageLookupByLibrary.simpleMessage("مرتبط"),
        "repliesPlural": m1,
        "retrieveDislikeCounts":
            MessageLookupByLibrary.simpleMessage("أظهر عدد عدم الإعجابات"),
        "retrieveDislikes":
            MessageLookupByLibrary.simpleMessage("أظهر عدم الإعجابات"),
        "retry": MessageLookupByLibrary.simpleMessage("إعادة المحاولة"),
        "saved": MessageLookupByLibrary.simpleMessage("المحفوظات"),
        "savedVideosTitle":
            MessageLookupByLibrary.simpleMessage("الفيديوهات المحفوظة"),
        "settings": MessageLookupByLibrary.simpleMessage("الإعدادات"),
        "share": MessageLookupByLibrary.simpleMessage("مشاركة"),
        "showLessText": MessageLookupByLibrary.simpleMessage("إظهار أقل"),
        "subscribe": MessageLookupByLibrary.simpleMessage("اشتراك"),
        "swipeDownToDismissDisabled": MessageLookupByLibrary.simpleMessage(
            "\'Swipe down to dismiss\' disabled"),
        "swipeUpToDismissEnabled": MessageLookupByLibrary.simpleMessage(
            "\'Swipe up to dismiss\' enabled"),
        "switchRegion": MessageLookupByLibrary.simpleMessage(
            "من فضلك غير المنطقة لنتائج فُضْلى."),
        "theme": MessageLookupByLibrary.simpleMessage("المظهر"),
        "thereIsNoSavedOrHistoryVideos": MessageLookupByLibrary.simpleMessage(
            "لا يوجد فيديوهات/تاريخ محفوظ"),
        "thereIsNoSavedVideos":
            MessageLookupByLibrary.simpleMessage("لا يوجد فيديوهات محفوظة"),
        "translators": MessageLookupByLibrary.simpleMessage("المترجمين"),
        "trending": MessageLookupByLibrary.simpleMessage("شائع"),
        "unitedKingdom":
            MessageLookupByLibrary.simpleMessage("المملكة المتحدة"),
        "unitedStates":
            MessageLookupByLibrary.simpleMessage("الولايات المتحدة"),
        "unknown": MessageLookupByLibrary.simpleMessage("غير معرف"),
        "unknownQuality":
            MessageLookupByLibrary.simpleMessage("جودة غير محددة"),
        "version": MessageLookupByLibrary.simpleMessage("النسخة"),
        "video": MessageLookupByLibrary.simpleMessage("فيديو"),
        "videoViews": m2
      };
}
