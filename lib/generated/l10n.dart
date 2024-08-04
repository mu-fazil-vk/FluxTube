// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Home`
  String get home {
    return Intl.message(
      'Home',
      name: 'home',
      desc: 'Home label',
      args: [],
    );
  }

  /// `Trending`
  String get trending {
    return Intl.message(
      'Trending',
      name: 'trending',
      desc: 'Trending label',
      args: [],
    );
  }

  /// `Saved`
  String get saved {
    return Intl.message(
      'Saved',
      name: 'saved',
      desc: 'Saved label',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: 'Settings label',
      args: [],
    );
  }

  /// `History`
  String get history {
    return Intl.message(
      'History',
      name: 'history',
      desc: 'History label',
      args: [],
    );
  }

  /// `Saved Videos`
  String get savedVideosTitle {
    return Intl.message(
      'Saved Videos',
      name: 'savedVideosTitle',
      desc: 'Saved videos app bar title',
      args: [],
    );
  }

  /// `No name`
  String get noUploaderName {
    return Intl.message(
      'No name',
      name: 'noUploaderName',
      desc: 'There is no uploader (channel) name available',
      args: [],
    );
  }

  /// `No title`
  String get noVideoTitle {
    return Intl.message(
      'No title',
      name: 'noVideoTitle',
      desc: 'There is no video title available',
      args: [],
    );
  }

  /// `{count, plural, =0{No views} =1{view} other{views}}`
  String videoViews(num count) {
    return Intl.plural(
      count,
      zero: 'No views',
      one: 'view',
      other: 'views',
      name: 'videoViews',
      desc: '{number} views',
      args: [count],
    );
  }

  /// `{count, plural, =0{No subscribers} =1{subscriber} other{subscribers}}`
  String channelSubscribers(num count) {
    return Intl.plural(
      count,
      zero: 'No subscribers',
      one: 'subscriber',
      other: 'subscribers',
      name: 'channelSubscribers',
      desc: '{number} subscribers',
      args: [count],
    );
  }

  /// `Subscribe`
  String get subscribe {
    return Intl.message(
      'Subscribe',
      name: 'subscribe',
      desc: 'Subscribe button label',
      args: [],
    );
  }

  /// `No date`
  String get noUploadDate {
    return Intl.message(
      'No date',
      name: 'noUploadDate',
      desc: 'There is no video upload date available',
      args: [],
    );
  }

  /// `There are no saved videos`
  String get thereIsNoSavedVideos {
    return Intl.message(
      'There are no saved videos',
      name: 'thereIsNoSavedVideos',
      desc: 'There are no saved videos found',
      args: [],
    );
  }

  /// `There are no saved/history videos`
  String get thereIsNoSavedOrHistoryVideos {
    return Intl.message(
      'There are no saved/history videos',
      name: 'thereIsNoSavedOrHistoryVideos',
      desc: '',
      args: [],
    );
  }

  /// `No video source available, automatically changed to hls`
  String get noVideoAvailableChangedToHls {
    return Intl.message(
      'No video source available, automatically changed to hls',
      name: 'noVideoAvailableChangedToHls',
      desc:
          'When there is no standard player link available, then it changed to hls player',
      args: [],
    );
  }

  /// `Unknown Quality`
  String get unknownQuality {
    return Intl.message(
      'Unknown Quality',
      name: 'unknownQuality',
      desc: 'Quality name not found',
      args: [],
    );
  }

  /// `Hls Player`
  String get hlsPlayer {
    return Intl.message(
      'Hls Player',
      name: 'hlsPlayer',
      desc: 'Hls player label',
      args: [],
    );
  }

  /// `Enable HLS player to unlock all quality options. Disable if errors occur.`
  String get enableHlsPlayerDescription {
    return Intl.message(
      'Enable HLS player to unlock all quality options. Disable if errors occur.',
      name: 'enableHlsPlayerDescription',
      desc:
          'Enabling HLS player may slow down performance but unlocks all quality options. Disable this setting if errors occur.',
      args: [],
    );
  }

  /// `Disable video history`
  String get disableVideoHistory {
    return Intl.message(
      'Disable video history',
      name: 'disableVideoHistory',
      desc: 'Hide watch history',
      args: [],
    );
  }

  /// `Retrieve Dislikes`
  String get retrieveDislikes {
    return Intl.message(
      'Retrieve Dislikes',
      name: 'retrieveDislikes',
      desc: 'Retrieve dislikes label',
      args: [],
    );
  }

  /// `Retrieve dislike counts`
  String get retrieveDislikeCounts {
    return Intl.message(
      'Retrieve dislike counts',
      name: 'retrieveDislikeCounts',
      desc: 'Return the dislike button of videos',
      args: [],
    );
  }

  /// `No description`
  String get noVideoDescription {
    return Intl.message(
      'No description',
      name: 'noVideoDescription',
      desc: 'There is no video description available',
      args: [],
    );
  }

  /// `Related`
  String get relatedTitle {
    return Intl.message(
      'Related',
      name: 'relatedTitle',
      desc: 'Related videos label',
      args: [],
    );
  }

  /// `Not found`
  String get commentAuthorNotFound {
    return Intl.message(
      'Not found',
      name: 'commentAuthorNotFound',
      desc: 'Name of the comment author is not found',
      args: [],
    );
  }

  /// `Read more`
  String get readMoreText {
    return Intl.message(
      'Read more',
      name: 'readMoreText',
      desc: 'Expand the comment text',
      args: [],
    );
  }

  /// `Show less`
  String get showLessText {
    return Intl.message(
      'Show less',
      name: 'showLessText',
      desc: 'Collapse the comment text',
      args: [],
    );
  }

  /// `Common`
  String get commonSettingsTitle {
    return Intl.message(
      'Common',
      name: 'commonSettingsTitle',
      desc: 'Common settings label',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: 'Language label',
      args: [],
    );
  }

  /// `Region`
  String get region {
    return Intl.message(
      'Region',
      name: 'region',
      desc: 'Region label',
      args: [],
    );
  }

  /// `Theme`
  String get theme {
    return Intl.message(
      'Theme',
      name: 'theme',
      desc: 'Theme label',
      args: [],
    );
  }

  /// `Developer`
  String get developer {
    return Intl.message(
      'Developer',
      name: 'developer',
      desc: 'Developer label',
      args: [],
    );
  }

  /// `Translators`
  String get translators {
    return Intl.message(
      'Translators',
      name: 'translators',
      desc: 'Translators label',
      args: [],
    );
  }

  /// `Version`
  String get version {
    return Intl.message(
      'Version',
      name: 'version',
      desc: 'Version label',
      args: [],
    );
  }

  /// `About`
  String get about {
    return Intl.message(
      'About',
      name: 'about',
      desc: 'About label',
      args: [],
    );
  }

  /// `Video`
  String get video {
    return Intl.message(
      'Video',
      name: 'video',
      desc: 'Video label',
      args: [],
    );
  }

  /// `unknown`
  String get unknown {
    return Intl.message(
      'unknown',
      name: 'unknown',
      desc: 'Unknown label',
      args: [],
    );
  }

  /// `Default Quality`
  String get defaultQuality {
    return Intl.message(
      'Default Quality',
      name: 'defaultQuality',
      desc: 'Default video quality label',
      args: [],
    );
  }

  /// `Retry`
  String get retry {
    return Intl.message(
      'Retry',
      name: 'retry',
      desc: 'Retry label',
      args: [],
    );
  }

  /// `{count, plural, =1{Reply} other{Replies}}`
  String repliesPlural(num count) {
    return Intl.plural(
      count,
      one: 'Reply',
      other: 'Replies',
      name: 'repliesPlural',
      desc: '{number} Replies',
      args: [count],
    );
  }

  /// `Canada`
  String get canada {
    return Intl.message(
      'Canada',
      name: 'canada',
      desc: '',
      args: [],
    );
  }

  /// `France`
  String get france {
    return Intl.message(
      'France',
      name: 'france',
      desc: '',
      args: [],
    );
  }

  /// `India`
  String get india {
    return Intl.message(
      'India',
      name: 'india',
      desc: '',
      args: [],
    );
  }

  /// `Netherlands`
  String get netherlands {
    return Intl.message(
      'Netherlands',
      name: 'netherlands',
      desc: '',
      args: [],
    );
  }

  /// `United Kingdom`
  String get unitedKingdom {
    return Intl.message(
      'United Kingdom',
      name: 'unitedKingdom',
      desc: '',
      args: [],
    );
  }

  /// `United States`
  String get unitedStates {
    return Intl.message(
      'United States',
      name: 'unitedStates',
      desc: '',
      args: [],
    );
  }

  /// `Distraction Free`
  String get distractionFree {
    return Intl.message(
      'Distraction Free',
      name: 'distractionFree',
      desc: 'A section for control distracting elements.',
      args: [],
    );
  }

  /// `Hide Comments`
  String get hideComments {
    return Intl.message(
      'Hide Comments',
      name: 'hideComments',
      desc: 'Hide Comments label.',
      args: [],
    );
  }

  /// `Hide comments button from watch screen.`
  String get hideCommentsButtonFromWatchScreen {
    return Intl.message(
      'Hide comments button from watch screen.',
      name: 'hideCommentsButtonFromWatchScreen',
      desc: 'Hide the comment button from video streaming screen.',
      args: [],
    );
  }

  /// `Hide Related`
  String get hideRelated {
    return Intl.message(
      'Hide Related',
      name: 'hideRelated',
      desc: 'Hide Related videos label.',
      args: [],
    );
  }

  /// `Hide related videos from watch screen`
  String get hideRelatedVideosFromWatchScreen {
    return Intl.message(
      'Hide related videos from watch screen',
      name: 'hideRelatedVideosFromWatchScreen',
      desc: 'Hide the related videos from video streaming screen.',
      args: [],
    );
  }

  /// `Share`
  String get share {
    return Intl.message(
      'Share',
      name: 'share',
      desc: 'Share label.',
      args: [],
    );
  }

  /// `Include title`
  String get includeTitle {
    return Intl.message(
      'Include title',
      name: 'includeTitle',
      desc: 'Include title along with url',
      args: [],
    );
  }

  /// `Instances`
  String get instances {
    return Intl.message(
      'Instances',
      name: 'instances',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ml'),
      Locale.fromSubtags(languageCode: 'tr'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
