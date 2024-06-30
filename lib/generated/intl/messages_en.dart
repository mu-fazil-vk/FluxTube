// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static String m0(count) =>
      "${Intl.plural(count, zero: 'No subscribers', one: 'subscriber', other: 'subscribers')}";

  static String m1(count) =>
      "${Intl.plural(count, one: 'Reply', other: 'Replies')}";

  static String m2(count) =>
      "${Intl.plural(count, zero: 'No views', one: 'view', other: 'views')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("About"),
        "canada": MessageLookupByLibrary.simpleMessage("Canada"),
        "channelSubscribers": m0,
        "commentAuthorNotFound":
            MessageLookupByLibrary.simpleMessage("Not found"),
        "commonSettingsTitle": MessageLookupByLibrary.simpleMessage("Common"),
        "defaultQuality":
            MessageLookupByLibrary.simpleMessage("Default Quality"),
        "developer": MessageLookupByLibrary.simpleMessage("Developer"),
        "disableVideoHistory":
            MessageLookupByLibrary.simpleMessage("Disable video history"),
        "enableHlsPlayerDescription": MessageLookupByLibrary.simpleMessage(
            "Enable HLS player to unlock all quality options. Disable if errors occur."),
        "france": MessageLookupByLibrary.simpleMessage("France"),
        "history": MessageLookupByLibrary.simpleMessage("History"),
        "hlsPlayer": MessageLookupByLibrary.simpleMessage("Hls Player"),
        "home": MessageLookupByLibrary.simpleMessage("Home"),
        "india": MessageLookupByLibrary.simpleMessage("India"),
        "language": MessageLookupByLibrary.simpleMessage("Language"),
        "netherlands": MessageLookupByLibrary.simpleMessage("Netherlands"),
        "noUploadDate": MessageLookupByLibrary.simpleMessage("No date"),
        "noUploaderName": MessageLookupByLibrary.simpleMessage("No name"),
        "noVideoAvailableChangedToHls": MessageLookupByLibrary.simpleMessage(
            "No video source available, automatically changed to hls"),
        "noVideoDescription":
            MessageLookupByLibrary.simpleMessage("No description"),
        "noVideoTitle": MessageLookupByLibrary.simpleMessage("No title"),
        "readMoreText": MessageLookupByLibrary.simpleMessage("Read more"),
        "region": MessageLookupByLibrary.simpleMessage("Region"),
        "relatedTitle": MessageLookupByLibrary.simpleMessage("Related"),
        "repliesPlural": m1,
        "retrieveDislikeCounts":
            MessageLookupByLibrary.simpleMessage("Retrieve dislike counts"),
        "retrieveDislikes":
            MessageLookupByLibrary.simpleMessage("Retrieve Dislikes"),
        "retry": MessageLookupByLibrary.simpleMessage("Retry"),
        "saved": MessageLookupByLibrary.simpleMessage("Saved"),
        "savedVideosTitle":
            MessageLookupByLibrary.simpleMessage("Saved Videos"),
        "settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "showLessText": MessageLookupByLibrary.simpleMessage("Show less"),
        "subscribe": MessageLookupByLibrary.simpleMessage("Subscribe"),
        "theme": MessageLookupByLibrary.simpleMessage("Theme"),
        "thereIsNoSavedOrHistoryVideos": MessageLookupByLibrary.simpleMessage(
            "There are no saved/history videos"),
        "thereIsNoSavedVideos":
            MessageLookupByLibrary.simpleMessage("There are no saved videos"),
        "translators": MessageLookupByLibrary.simpleMessage("Translators"),
        "trending": MessageLookupByLibrary.simpleMessage("Trending"),
        "unitedKingdom": MessageLookupByLibrary.simpleMessage("United Kingdom"),
        "unitedStates": MessageLookupByLibrary.simpleMessage("United States"),
        "unknown": MessageLookupByLibrary.simpleMessage("unknown"),
        "unknownQuality":
            MessageLookupByLibrary.simpleMessage("Unknown Quality"),
        "version": MessageLookupByLibrary.simpleMessage("Version"),
        "video": MessageLookupByLibrary.simpleMessage("Video"),
        "videoViews": m2
      };
}
