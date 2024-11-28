// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ko locale. All the
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
  String get localeName => 'ko';

  static String m0(count) =>
      "${Intl.plural(count, zero: '구독자 없음', one: '구독자', other: '구독자')}";

  static String m1(count) => "${Intl.plural(count, one: '답장', other: '답장')}";

  static String m2(count) =>
      "${Intl.plural(count, zero: '조회수 없음', one: '조회수', other: '조회수')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("정보"),
        "canada": MessageLookupByLibrary.simpleMessage("캐나다"),
        "channelSubscribers": m0,
        "commentAuthorNotFound": MessageLookupByLibrary.simpleMessage("찾지 못함"),
        "commonSettingsTitle": MessageLookupByLibrary.simpleMessage("공통 사항"),
        "defaultQuality": MessageLookupByLibrary.simpleMessage("기본 화질"),
        "developer": MessageLookupByLibrary.simpleMessage("개발자"),
        "disablePipPlayer":
            MessageLookupByLibrary.simpleMessage("Disable PIP player"),
        "disableVideoHistory":
            MessageLookupByLibrary.simpleMessage("동영상 기록 사용 중지"),
        "distractionFree": MessageLookupByLibrary.simpleMessage("방해 요소 제거"),
        "enableHlsPlayerDescription": MessageLookupByLibrary.simpleMessage(
            "HLS 재생기를 사용해 모든 화질 설정을 잠금 해제하세요. 오류가 발생한다면 사용 중지하세요."),
        "france": MessageLookupByLibrary.simpleMessage("프랑스"),
        "hideComments": MessageLookupByLibrary.simpleMessage("댓글 숨기기"),
        "hideCommentsButtonFromWatchScreen":
            MessageLookupByLibrary.simpleMessage("시청 화면에서 댓글 버튼을 숨겨요"),
        "hideRelated": MessageLookupByLibrary.simpleMessage("연관 동영상 숨기기"),
        "hideRelatedVideosFromWatchScreen":
            MessageLookupByLibrary.simpleMessage("시청 화면에서 연관 동영상을 숨겨요"),
        "history": MessageLookupByLibrary.simpleMessage("기록"),
        "hlsPlayer": MessageLookupByLibrary.simpleMessage("Hls 재생기"),
        "home": MessageLookupByLibrary.simpleMessage("홈"),
        "includeTitle": MessageLookupByLibrary.simpleMessage("제목 포함"),
        "india": MessageLookupByLibrary.simpleMessage("인도"),
        "instances": MessageLookupByLibrary.simpleMessage("인스턴스"),
        "language": MessageLookupByLibrary.simpleMessage("언어"),
        "netherlands": MessageLookupByLibrary.simpleMessage("네덜란드"),
        "noCommentsFound":
            MessageLookupByLibrary.simpleMessage("No Comments Found"),
        "noUploadDate": MessageLookupByLibrary.simpleMessage("날짜 없음"),
        "noUploaderName": MessageLookupByLibrary.simpleMessage("이름 없음"),
        "noVideoAvailableChangedToHls": MessageLookupByLibrary.simpleMessage(
            "동영상 원본을 사용할 수 없어요. 자동으로 hls로 변경했어요"),
        "noVideoDescription": MessageLookupByLibrary.simpleMessage("설명 없음"),
        "noVideoTitle": MessageLookupByLibrary.simpleMessage("제목 없음"),
        "readMoreText": MessageLookupByLibrary.simpleMessage("더 읽기"),
        "region": MessageLookupByLibrary.simpleMessage("지역"),
        "relatedTitle": MessageLookupByLibrary.simpleMessage("연관 동영상"),
        "repliesPlural": m1,
        "retrieveDislikeCounts":
            MessageLookupByLibrary.simpleMessage("싫어요 수를 가져와요"),
        "retrieveDislikes": MessageLookupByLibrary.simpleMessage("싫어요 가져오기"),
        "retry": MessageLookupByLibrary.simpleMessage("재시도"),
        "saved": MessageLookupByLibrary.simpleMessage("저장 사항"),
        "savedVideosTitle": MessageLookupByLibrary.simpleMessage("저장한 동영상"),
        "settings": MessageLookupByLibrary.simpleMessage("설정"),
        "share": MessageLookupByLibrary.simpleMessage("공유"),
        "showLessText": MessageLookupByLibrary.simpleMessage("덜 보기"),
        "subscribe": MessageLookupByLibrary.simpleMessage("구독"),
        "swipeDownToDismissDisabled": MessageLookupByLibrary.simpleMessage(
            "\'Swipe down to dismiss\' disabled"),
        "swipeUpToDismissEnabled": MessageLookupByLibrary.simpleMessage(
            "\'Swipe up to dismiss\' enabled"),
        "switchRegion": MessageLookupByLibrary.simpleMessage(
            "더 나은 결과를 위해 다른 지역으로 전환하는 걸 고려해 주세요."),
        "theme": MessageLookupByLibrary.simpleMessage("테마"),
        "thereIsNoSavedOrHistoryVideos":
            MessageLookupByLibrary.simpleMessage("저장한/기록된 동영상이 없어요"),
        "thereIsNoSavedVideos":
            MessageLookupByLibrary.simpleMessage("저장한 동영상이 없어요"),
        "translators": MessageLookupByLibrary.simpleMessage("번역가"),
        "trending": MessageLookupByLibrary.simpleMessage("인기 급상승"),
        "unitedKingdom": MessageLookupByLibrary.simpleMessage("영국"),
        "unitedStates": MessageLookupByLibrary.simpleMessage("미국"),
        "unknown": MessageLookupByLibrary.simpleMessage("알 수 없음"),
        "unknownQuality": MessageLookupByLibrary.simpleMessage("알 수 없는 화질"),
        "version": MessageLookupByLibrary.simpleMessage("버전"),
        "video": MessageLookupByLibrary.simpleMessage("동영상"),
        "videoViews": m2
      };
}
