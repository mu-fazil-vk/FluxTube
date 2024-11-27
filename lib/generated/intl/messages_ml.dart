// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ml locale. All the
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
  String get localeName => 'ml';

  static String m0(count) =>
      "${Intl.plural(count, zero: 'സബ്സ്ക്രൈബർമാർ ഇല്ല', one: 'സബ്സ്ക്രൈബർ', other: 'സബ്സ്ക്രൈബർമാർ')}";

  static String m1(count) =>
      "${Intl.plural(count, one: 'മറുപടി', other: 'മറുപടികൾ')}";

  static String m2(count) =>
      "${Intl.plural(count, zero: 'കാഴ്ചക്കാർ ഇല്ല', one: 'കാഴ്ച', other: 'കാഴ്ചക്കാർ')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("എന്നെക്കുറിച്ച്"),
        "canada": MessageLookupByLibrary.simpleMessage("കാനഡ"),
        "channelSubscribers": m0,
        "commentAuthorNotFound":
            MessageLookupByLibrary.simpleMessage("കണ്ടെത്തിയില്ല"),
        "commonSettingsTitle": MessageLookupByLibrary.simpleMessage("പൊതുവായവ"),
        "defaultQuality":
            MessageLookupByLibrary.simpleMessage("സാധാരണ ക്വാളിറ്റി"),
        "developer": MessageLookupByLibrary.simpleMessage("ഡെവലപ്പർ"),
        "disablePipPlayer":
            MessageLookupByLibrary.simpleMessage("Disable PIP player"),
        "disableVideoHistory":
            MessageLookupByLibrary.simpleMessage("കണ്ട വീഡിയോകൾ മറച്ചുവെക്കുക"),
        "distractionFree":
            MessageLookupByLibrary.simpleMessage("ശ്രദ്ധ തിരിയാതിരിക്കാൻ"),
        "enableHlsPlayerDescription": MessageLookupByLibrary.simpleMessage(
            "എല്ലാ ക്വാളിറ്റി ഓപ്ഷനുകളും ലഭ്യമാകാൻ HLS പ്ലെയർ ഓൺ ചെയ്യുക. പിശകുകൾ സംഭവിച്ചാൽ ഓഫ് ചെയ്യുക."),
        "france": MessageLookupByLibrary.simpleMessage("ഫ്രാൻസ്"),
        "hideComments":
            MessageLookupByLibrary.simpleMessage("കമൻ്റുകൾ മറയ്ക്കുക"),
        "hideCommentsButtonFromWatchScreen":
            MessageLookupByLibrary.simpleMessage(
                "വാച്ച് സ്ക്രീനിൽ നിന്ന് കമൻ്റുകൾ മറയ്ക്കുക."),
        "hideRelated":
            MessageLookupByLibrary.simpleMessage("അനുബന്ധപ്പെട്ടവ മറയ്ക്കുക"),
        "hideRelatedVideosFromWatchScreen":
            MessageLookupByLibrary.simpleMessage(
                "വാച്ച് സ്ക്രീനിൽ നിന്ന് അനുബന്ധ വീഡിയോകൾ മറയ്ക്കുക"),
        "history": MessageLookupByLibrary.simpleMessage("കണ്ടു കഴിഞ്ഞത്"),
        "hlsPlayer": MessageLookupByLibrary.simpleMessage("HLS പ്ലെയർ"),
        "home": MessageLookupByLibrary.simpleMessage("ഹോം"),
        "includeTitle":
            MessageLookupByLibrary.simpleMessage("ശീർഷകം ഉൾപ്പെടുത്തുക"),
        "india": MessageLookupByLibrary.simpleMessage("ഇന്ത്യ"),
        "instances": MessageLookupByLibrary.simpleMessage("Instances"),
        "language": MessageLookupByLibrary.simpleMessage("ഭാഷ"),
        "netherlands": MessageLookupByLibrary.simpleMessage("നെതർലാൻഡ്‌സ്"),
        "noCommentsFound":
            MessageLookupByLibrary.simpleMessage("അഭിപ്രായങ്ങൾ ലഭ്യമല്ല."),
        "noUploadDate": MessageLookupByLibrary.simpleMessage("തീയതി ഇല്ല"),
        "noUploaderName": MessageLookupByLibrary.simpleMessage("പേര് ലഭ്യമല്ല"),
        "noVideoAvailableChangedToHls": MessageLookupByLibrary.simpleMessage(
            "കാണാൻ സ്രോതസ്സ് ഇല്ല, സ്വയം HLS ആയി മാറ്റിയിരിക്കുന്നു"),
        "noVideoDescription":
            MessageLookupByLibrary.simpleMessage("വിവരണം ഇല്ല"),
        "noVideoTitle": MessageLookupByLibrary.simpleMessage("ശീർഷകം ഇല്ല"),
        "readMoreText":
            MessageLookupByLibrary.simpleMessage("കൂടുതൽ വായിക്കുക"),
        "region": MessageLookupByLibrary.simpleMessage("പ്രദേശം"),
        "relatedTitle": MessageLookupByLibrary.simpleMessage("സംബന്ധിച്ചവ"),
        "repliesPlural": m1,
        "retrieveDislikeCounts": MessageLookupByLibrary.simpleMessage(
            "ഡിസ്ലൈക്ക് എണ്ണങ്ങൾ വീണ്ടെടുക്കുക"),
        "retrieveDislikes":
            MessageLookupByLibrary.simpleMessage("ഡിസ്ലൈക്കുകൾ വീണ്ടെടുക്കുക"),
        "retry": MessageLookupByLibrary.simpleMessage("വീണ്ടും ശ്രമിക്കുക"),
        "saved": MessageLookupByLibrary.simpleMessage("സേവ് ചെയ്‌തത്"),
        "savedVideosTitle":
            MessageLookupByLibrary.simpleMessage("സേവ് ചെയ്‌തവ"),
        "settings": MessageLookupByLibrary.simpleMessage("ക്രമീകരണങ്ങൾ"),
        "share": MessageLookupByLibrary.simpleMessage("പങ്കിടുക"),
        "showLessText":
            MessageLookupByLibrary.simpleMessage("കുറച്ചത് കാണിക്കുക"),
        "subscribe": MessageLookupByLibrary.simpleMessage("സബ്സ്ക്രൈബ്"),
        "swipeDownToDismissDisabled": MessageLookupByLibrary.simpleMessage(
            "\'സ്വൈപ്പ് ഡൗൺ ചെയ്ത് ഡിസ്മിസ് ചെയ്യൽ\' പ്രവർത്തനരഹിതമാക്കിയിരിക്കുന്നു"),
        "swipeUpToDismissEnabled": MessageLookupByLibrary.simpleMessage(
            "\'സ്വൈപ്പ് അപ്പ് ചെയ്ത് ഡിസ്മിസ് ചെയ്യൽ\' പ്രവർത്തന സജ്ജമാക്കിയിരിക്കുന്നു"),
        "switchRegion": MessageLookupByLibrary.simpleMessage(
            "മികച്ച ഫലങ്ങൾക്കായി ദയവായി വ്യത്യസ്തമായ ഒരു പ്രദേശത്തിലേക്ക് മാറുന്നതു പരിഗണിക്കുക."),
        "theme": MessageLookupByLibrary.simpleMessage("തീം"),
        "thereIsNoSavedOrHistoryVideos": MessageLookupByLibrary.simpleMessage(
            "സേവ് ചെയ്‌ത/കണ്ടുകഴിഞ്ഞ വീഡിയോകൾ ഇല്ല"),
        "thereIsNoSavedVideos":
            MessageLookupByLibrary.simpleMessage("സേവ് ചെയ്‌ത വീഡിയോകൾ ഇല്ല"),
        "translators": MessageLookupByLibrary.simpleMessage("പരിഭാഷകർ"),
        "trending": MessageLookupByLibrary.simpleMessage("ട്രെൻഡിംഗ്"),
        "unitedKingdom":
            MessageLookupByLibrary.simpleMessage("യുണൈറ്റഡ് കിംഗ്ഡം"),
        "unitedStates":
            MessageLookupByLibrary.simpleMessage("യുണൈറ്റഡ് സ്റ്റേറ്റ്സ്"),
        "unknown": MessageLookupByLibrary.simpleMessage("അജ്ഞാതം"),
        "unknownQuality":
            MessageLookupByLibrary.simpleMessage("അജ്ഞാത ക്വാളിറ്റി"),
        "version": MessageLookupByLibrary.simpleMessage("പതിപ്പ്"),
        "video": MessageLookupByLibrary.simpleMessage("വീഡിയോ"),
        "videoViews": m2
      };
}
