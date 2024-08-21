// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh locale. All the
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
  String get localeName => 'zh';

  static String m0(count) =>
      "${Intl.plural(count, zero: '无订阅者', one: '1位订阅者', other: '${count}位订阅者')}";

  static String m1(count) =>
      "${Intl.plural(count, one: '回复', other: '${count}条回复')}";

  static String m2(count) =>
      "${Intl.plural(count, zero: '无观看', one: '1次观看', other: '${count}次观看')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("关于"),
        "canada": MessageLookupByLibrary.simpleMessage("加拿大"),
        "channelSubscribers": m0,
        "commentAuthorNotFound": MessageLookupByLibrary.simpleMessage("未找到"),
        "commonSettingsTitle": MessageLookupByLibrary.simpleMessage("通用"),
        "defaultQuality": MessageLookupByLibrary.simpleMessage("默认质量"),
        "developer": MessageLookupByLibrary.simpleMessage("开发者"),
        "disableVideoHistory": MessageLookupByLibrary.simpleMessage("禁用视频历史记录"),
        "distractionFree": MessageLookupByLibrary.simpleMessage("无干扰"),
        "enableHlsPlayerDescription": MessageLookupByLibrary.simpleMessage(
            "启用 HLS 播放器以解锁所有质量选项。如果出现错误，请禁用。"),
        "france": MessageLookupByLibrary.simpleMessage("法国"),
        "hideComments": MessageLookupByLibrary.simpleMessage("隐藏评论"),
        "hideCommentsButtonFromWatchScreen":
            MessageLookupByLibrary.simpleMessage("隐藏视频播放屏幕的评论按钮。"),
        "hideRelated": MessageLookupByLibrary.simpleMessage("隐藏相关视频"),
        "hideRelatedVideosFromWatchScreen":
            MessageLookupByLibrary.simpleMessage("隐藏视频播放屏幕上的相关视频"),
        "history": MessageLookupByLibrary.simpleMessage("历史记录"),
        "hlsPlayer": MessageLookupByLibrary.simpleMessage("Hls 播放器"),
        "home": MessageLookupByLibrary.simpleMessage("首页"),
        "includeTitle": MessageLookupByLibrary.simpleMessage("包含标题"),
        "india": MessageLookupByLibrary.simpleMessage("印度"),
        "instances": MessageLookupByLibrary.simpleMessage("实例"),
        "language": MessageLookupByLibrary.simpleMessage("语言"),
        "netherlands": MessageLookupByLibrary.simpleMessage("荷兰"),
        "noUploadDate": MessageLookupByLibrary.simpleMessage("无日期"),
        "noUploaderName": MessageLookupByLibrary.simpleMessage("无名称"),
        "noVideoAvailableChangedToHls":
            MessageLookupByLibrary.simpleMessage("无视频源可用，自动更改为hls"),
        "noVideoDescription": MessageLookupByLibrary.simpleMessage("无描述"),
        "noVideoTitle": MessageLookupByLibrary.simpleMessage("无标题"),
        "readMoreText": MessageLookupByLibrary.simpleMessage("阅读更多"),
        "region": MessageLookupByLibrary.simpleMessage("地区"),
        "relatedTitle": MessageLookupByLibrary.simpleMessage("相关"),
        "repliesPlural": m1,
        "retrieveDislikeCounts":
            MessageLookupByLibrary.simpleMessage("检索 dislike counts"),
        "retrieveDislikes": MessageLookupByLibrary.simpleMessage("检索 Dislikes"),
        "retry": MessageLookupByLibrary.simpleMessage("重试"),
        "saved": MessageLookupByLibrary.simpleMessage("已保存"),
        "savedVideosTitle": MessageLookupByLibrary.simpleMessage("已保存的视频"),
        "settings": MessageLookupByLibrary.simpleMessage("设置"),
        "share": MessageLookupByLibrary.simpleMessage("分享"),
        "showLessText": MessageLookupByLibrary.simpleMessage("显示更少"),
        "subscribe": MessageLookupByLibrary.simpleMessage("订阅"),
        "switchRegion": MessageLookupByLibrary.simpleMessage(
            "Please consider switching to a different region for better results."),
        "theme": MessageLookupByLibrary.simpleMessage("主题"),
        "thereIsNoSavedOrHistoryVideos":
            MessageLookupByLibrary.simpleMessage("没有已保存或历史视频"),
        "thereIsNoSavedVideos":
            MessageLookupByLibrary.simpleMessage("没有已保存的视频"),
        "translators": MessageLookupByLibrary.simpleMessage("翻译人员"),
        "trending": MessageLookupByLibrary.simpleMessage("热门"),
        "unitedKingdom": MessageLookupByLibrary.simpleMessage("英国"),
        "unitedStates": MessageLookupByLibrary.simpleMessage("美国"),
        "unknown": MessageLookupByLibrary.simpleMessage("未知"),
        "unknownQuality": MessageLookupByLibrary.simpleMessage("未知质量"),
        "version": MessageLookupByLibrary.simpleMessage("版本"),
        "video": MessageLookupByLibrary.simpleMessage("视频"),
        "videoViews": m2
      };
}
