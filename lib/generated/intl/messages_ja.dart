// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ja locale. All the
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
  String get localeName => 'ja';

  static String m0(count) =>
      "${Intl.plural(count, zero: '登録者なし', one: '人の登録者', other: '人の登録者')}";

  static String m1(count) => "${Intl.plural(count, one: '返信', other: '返信')}";

  static String m2(count) =>
      "${Intl.plural(count, zero: '視聴なし', one: '回視聴', other: '回視聴')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("情報"),
        "canada": MessageLookupByLibrary.simpleMessage("カナダ"),
        "channelSubscribers": m0,
        "commentAuthorNotFound":
            MessageLookupByLibrary.simpleMessage("見つかりません"),
        "commonSettingsTitle": MessageLookupByLibrary.simpleMessage("一般"),
        "defaultQuality": MessageLookupByLibrary.simpleMessage("初期選択の品質"),
        "developer": MessageLookupByLibrary.simpleMessage("開発"),
        "disablePipPlayer":
            MessageLookupByLibrary.simpleMessage("PIP プレイヤーを無効化"),
        "disableVideoHistory":
            MessageLookupByLibrary.simpleMessage("動画の履歴をとらない"),
        "distractionFree": MessageLookupByLibrary.simpleMessage("集中モード"),
        "enableHlsPlayerDescription": MessageLookupByLibrary.simpleMessage(
            "すべての品質オプションを選ぶためHLSプレイヤーを有効にします。エラー発生時に無効にしてください。"),
        "france": MessageLookupByLibrary.simpleMessage("フランス"),
        "hideComments": MessageLookupByLibrary.simpleMessage("コメントを非表示"),
        "hideCommentsButtonFromWatchScreen":
            MessageLookupByLibrary.simpleMessage("視聴画面のコメントボタンを非表示"),
        "hideRelated": MessageLookupByLibrary.simpleMessage("関連を非表示"),
        "hideRelatedVideosFromWatchScreen":
            MessageLookupByLibrary.simpleMessage("視聴画面の関連動画を非表示"),
        "history": MessageLookupByLibrary.simpleMessage("履歴"),
        "hlsPlayer": MessageLookupByLibrary.simpleMessage("HLSプレイヤー"),
        "home": MessageLookupByLibrary.simpleMessage("ホーム"),
        "includeTitle": MessageLookupByLibrary.simpleMessage("題名とURLを含める"),
        "india": MessageLookupByLibrary.simpleMessage("インド"),
        "instances": MessageLookupByLibrary.simpleMessage("インスタンス"),
        "language": MessageLookupByLibrary.simpleMessage("言語"),
        "netherlands": MessageLookupByLibrary.simpleMessage("オランダ"),
        "noCommentsFound": MessageLookupByLibrary.simpleMessage("コメントなし"),
        "noUploadDate": MessageLookupByLibrary.simpleMessage("日付なし"),
        "noUploaderName": MessageLookupByLibrary.simpleMessage("名無し"),
        "noVideoAvailableChangedToHls":
            MessageLookupByLibrary.simpleMessage("利用可能な動画形式がないので自動でHLSに変更"),
        "noVideoDescription": MessageLookupByLibrary.simpleMessage("説明なし"),
        "noVideoTitle": MessageLookupByLibrary.simpleMessage("題名なし"),
        "readMoreText": MessageLookupByLibrary.simpleMessage("もっと読む"),
        "region": MessageLookupByLibrary.simpleMessage("地域"),
        "relatedTitle": MessageLookupByLibrary.simpleMessage("関連"),
        "repliesPlural": m1,
        "retrieveDislikeCounts":
            MessageLookupByLibrary.simpleMessage("低評価数を取得"),
        "retrieveDislikes": MessageLookupByLibrary.simpleMessage("低評価を取得"),
        "retry": MessageLookupByLibrary.simpleMessage("再試行"),
        "saved": MessageLookupByLibrary.simpleMessage("保存済み"),
        "savedVideosTitle": MessageLookupByLibrary.simpleMessage("保存済み動画"),
        "settings": MessageLookupByLibrary.simpleMessage("設定"),
        "share": MessageLookupByLibrary.simpleMessage("共有"),
        "showLessText": MessageLookupByLibrary.simpleMessage("少なく表示"),
        "subscribe": MessageLookupByLibrary.simpleMessage("チャンネル登録"),
        "swipeDownToDismissDisabled": MessageLookupByLibrary.simpleMessage(
            "\'Swipe down to dismiss\' disabled"),
        "swipeUpToDismissEnabled": MessageLookupByLibrary.simpleMessage(
            "\'Swipe up to dismiss\' enabled"),
        "switchRegion":
            MessageLookupByLibrary.simpleMessage("より良い結果にするため、地域へ変更もできます。"),
        "theme": MessageLookupByLibrary.simpleMessage("テーマ"),
        "thereIsNoSavedOrHistoryVideos":
            MessageLookupByLibrary.simpleMessage("保存済み動画・履歴なし"),
        "thereIsNoSavedVideos":
            MessageLookupByLibrary.simpleMessage("保存済み動画なし"),
        "translators": MessageLookupByLibrary.simpleMessage("翻訳"),
        "trending": MessageLookupByLibrary.simpleMessage("急上昇"),
        "unitedKingdom": MessageLookupByLibrary.simpleMessage("イギリス"),
        "unitedStates": MessageLookupByLibrary.simpleMessage("アメリカ"),
        "unknown": MessageLookupByLibrary.simpleMessage("不明"),
        "unknownQuality": MessageLookupByLibrary.simpleMessage("不明の品質"),
        "version": MessageLookupByLibrary.simpleMessage("バージョン"),
        "video": MessageLookupByLibrary.simpleMessage("動画"),
        "videoViews": m2
      };
}
