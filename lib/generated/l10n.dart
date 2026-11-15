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
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
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
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Home`
  String get home {
    return Intl.message('Home', name: 'home', desc: 'Home label', args: []);
  }

  /// `System`
  String get themeSystem {
    return Intl.message('System', name: 'themeSystem', desc: '', args: []);
  }

  /// `Light`
  String get themeLight {
    return Intl.message('Light', name: 'themeLight', desc: '', args: []);
  }

  /// `Dark`
  String get themeDark {
    return Intl.message('Dark', name: 'themeDark', desc: '', args: []);
  }

  /// `OLED Black`
  String get themeOled {
    return Intl.message('OLED Black', name: 'themeOled', desc: '', args: []);
  }

  /// `Material You`
  String get themeDynamic {
    return Intl.message(
      'Material You',
      name: 'themeDynamic',
      desc: '',
      args: [],
    );
  }

  /// `YouTube Service`
  String get youtubeService {
    return Intl.message(
      'YouTube Service',
      name: 'youtubeService',
      desc: '',
      args: [],
    );
  }

  /// `Piped`
  String get servicePiped {
    return Intl.message('Piped', name: 'servicePiped', desc: '', args: []);
  }

  /// `Explode`
  String get serviceExplode {
    return Intl.message('Explode', name: 'serviceExplode', desc: '', args: []);
  }

  /// `Invidious`
  String get serviceInvidious {
    return Intl.message(
      'Invidious',
      name: 'serviceInvidious',
      desc: '',
      args: [],
    );
  }

  /// `NewPipe Extractor`
  String get serviceNewPipe {
    return Intl.message(
      'NewPipe Extractor',
      name: 'serviceNewPipe',
      desc: '',
      args: [],
    );
  }

  /// `144p`
  String get quality144p {
    return Intl.message('144p', name: 'quality144p', desc: '', args: []);
  }

  /// `240p`
  String get quality240p {
    return Intl.message('240p', name: 'quality240p', desc: '', args: []);
  }

  /// `360p`
  String get quality360p {
    return Intl.message('360p', name: 'quality360p', desc: '', args: []);
  }

  /// `480p`
  String get quality480p {
    return Intl.message('480p', name: 'quality480p', desc: '', args: []);
  }

  /// `720p`
  String get quality720p {
    return Intl.message('720p', name: 'quality720p', desc: '', args: []);
  }

  /// `1080p`
  String get quality1080p {
    return Intl.message('1080p', name: 'quality1080p', desc: '', args: []);
  }

  /// `1440p`
  String get quality1440p {
    return Intl.message('1440p', name: 'quality1440p', desc: '', args: []);
  }

  /// `Filters`
  String get searchFilters {
    return Intl.message('Filters', name: 'searchFilters', desc: '', args: []);
  }

  /// `All`
  String get filterAll {
    return Intl.message('All', name: 'filterAll', desc: '', args: []);
  }

  /// `Videos`
  String get filterVideos {
    return Intl.message('Videos', name: 'filterVideos', desc: '', args: []);
  }

  /// `Channels`
  String get filterChannels {
    return Intl.message('Channels', name: 'filterChannels', desc: '', args: []);
  }

  /// `Playlists`
  String get filterPlaylists {
    return Intl.message(
      'Playlists',
      name: 'filterPlaylists',
      desc: '',
      args: [],
    );
  }

  /// `Playlist`
  String get playlist {
    return Intl.message('Playlist', name: 'playlist', desc: '', args: []);
  }

  /// `Music`
  String get filterMusic {
    return Intl.message('Music', name: 'filterMusic', desc: '', args: []);
  }

  /// `Video Fit`
  String get videoFit {
    return Intl.message('Video Fit', name: 'videoFit', desc: '', args: []);
  }

  /// `Contain`
  String get videoFitContain {
    return Intl.message('Contain', name: 'videoFitContain', desc: '', args: []);
  }

  /// `Cover`
  String get videoFitCover {
    return Intl.message('Cover', name: 'videoFitCover', desc: '', args: []);
  }

  /// `Fill`
  String get videoFitFill {
    return Intl.message('Fill', name: 'videoFitFill', desc: '', args: []);
  }

  /// `Fit Width`
  String get videoFitFitWidth {
    return Intl.message(
      'Fit Width',
      name: 'videoFitFitWidth',
      desc: '',
      args: [],
    );
  }

  /// `Fit Height`
  String get videoFitFitHeight {
    return Intl.message(
      'Fit Height',
      name: 'videoFitFitHeight',
      desc: '',
      args: [],
    );
  }

  /// `Skip Interval`
  String get skipInterval {
    return Intl.message(
      'Skip Interval',
      name: 'skipInterval',
      desc: '',
      args: [],
    );
  }

  /// `Double-tap skip duration in seconds`
  String get skipIntervalDescription {
    return Intl.message(
      'Double-tap skip duration in seconds',
      name: 'skipIntervalDescription',
      desc: '',
      args: [],
    );
  }

  /// `seconds`
  String get seconds {
    return Intl.message('seconds', name: 'seconds', desc: '', args: []);
  }

  /// `SponsorBlock`
  String get sponsorBlock {
    return Intl.message(
      'SponsorBlock',
      name: 'sponsorBlock',
      desc: '',
      args: [],
    );
  }

  /// `Skip sponsored segments automatically`
  String get sponsorBlockDescription {
    return Intl.message(
      'Skip sponsored segments automatically',
      name: 'sponsorBlockDescription',
      desc: '',
      args: [],
    );
  }

  /// `Skip Categories`
  String get sponsorBlockCategories {
    return Intl.message(
      'Skip Categories',
      name: 'sponsorBlockCategories',
      desc: '',
      args: [],
    );
  }

  /// `Sponsor`
  String get sponsor {
    return Intl.message('Sponsor', name: 'sponsor', desc: '', args: []);
  }

  /// `Intro`
  String get intro {
    return Intl.message('Intro', name: 'intro', desc: '', args: []);
  }

  /// `Outro`
  String get outro {
    return Intl.message('Outro', name: 'outro', desc: '', args: []);
  }

  /// `Self Promotion`
  String get selfPromotion {
    return Intl.message(
      'Self Promotion',
      name: 'selfPromotion',
      desc: '',
      args: [],
    );
  }

  /// `Interaction`
  String get interaction {
    return Intl.message('Interaction', name: 'interaction', desc: '', args: []);
  }

  /// `Music: Non-Music`
  String get musicOfftopic {
    return Intl.message(
      'Music: Non-Music',
      name: 'musicOfftopic',
      desc: '',
      args: [],
    );
  }

  /// `Open in Browser`
  String get openInBrowser {
    return Intl.message(
      'Open in Browser',
      name: 'openInBrowser',
      desc: '',
      args: [],
    );
  }

  /// `Open links in external browser`
  String get openLinksExternally {
    return Intl.message(
      'Open links in external browser',
      name: 'openLinksExternally',
      desc: '',
      args: [],
    );
  }

  /// `Export Data`
  String get exportData {
    return Intl.message('Export Data', name: 'exportData', desc: '', args: []);
  }

  /// `Import Data`
  String get importData {
    return Intl.message('Import Data', name: 'importData', desc: '', args: []);
  }

  /// `Export Subscriptions`
  String get exportSubscriptions {
    return Intl.message(
      'Export Subscriptions',
      name: 'exportSubscriptions',
      desc: '',
      args: [],
    );
  }

  /// `Import Subscriptions`
  String get importSubscriptions {
    return Intl.message(
      'Import Subscriptions',
      name: 'importSubscriptions',
      desc: '',
      args: [],
    );
  }

  /// `Backup & Restore`
  String get backupRestore {
    return Intl.message(
      'Backup & Restore',
      name: 'backupRestore',
      desc: '',
      args: [],
    );
  }

  /// `Export or import your subscriptions`
  String get backupRestoreDescription {
    return Intl.message(
      'Export or import your subscriptions',
      name: 'backupRestoreDescription',
      desc: '',
      args: [],
    );
  }

  /// `Export successful`
  String get exportSuccess {
    return Intl.message(
      'Export successful',
      name: 'exportSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Import successful`
  String get importSuccess {
    return Intl.message(
      'Import successful',
      name: 'importSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Import failed`
  String get importError {
    return Intl.message(
      'Import failed',
      name: 'importError',
      desc: '',
      args: [],
    );
  }

  /// `Select File`
  String get selectFile {
    return Intl.message('Select File', name: 'selectFile', desc: '', args: []);
  }

  /// `Home Feed`
  String get homeFeedMode {
    return Intl.message('Home Feed', name: 'homeFeedMode', desc: '', args: []);
  }

  /// `Auto`
  String get homeFeedModeAuto {
    return Intl.message('Auto', name: 'homeFeedModeAuto', desc: '', args: []);
  }

  /// `Subscriptions`
  String get homeFeedModeFeedOnly {
    return Intl.message(
      'Subscriptions',
      name: 'homeFeedModeFeedOnly',
      desc: '',
      args: [],
    );
  }

  /// `Trending`
  String get homeFeedModeTrendingOnly {
    return Intl.message(
      'Trending',
      name: 'homeFeedModeTrendingOnly',
      desc: '',
      args: [],
    );
  }

  /// `Show subscriptions if available, otherwise trending`
  String get homeFeedModeAutoHint {
    return Intl.message(
      'Show subscriptions if available, otherwise trending',
      name: 'homeFeedModeAutoHint',
      desc: '',
      args: [],
    );
  }

  /// `Only show videos from subscribed channels`
  String get homeFeedModeFeedOnlyHint {
    return Intl.message(
      'Only show videos from subscribed channels',
      name: 'homeFeedModeFeedOnlyHint',
      desc: '',
      args: [],
    );
  }

  /// `Always show trending videos only`
  String get homeFeedModeTrendingOnlyHint {
    return Intl.message(
      'Always show trending videos only',
      name: 'homeFeedModeTrendingOnlyHint',
      desc: '',
      args: [],
    );
  }

  /// `No Subscriptions`
  String get noSubscriptions {
    return Intl.message(
      'No Subscriptions',
      name: 'noSubscriptions',
      desc: '',
      args: [],
    );
  }

  /// `Subscribe to channels to see their videos here`
  String get noSubscriptionsHint {
    return Intl.message(
      'Subscribe to channels to see their videos here',
      name: 'noSubscriptionsHint',
      desc: '',
      args: [],
    );
  }

  /// `Profiles`
  String get profiles {
    return Intl.message('Profiles', name: 'profiles', desc: '', args: []);
  }

  /// `Create separate profiles for different accounts or preferences`
  String get profilesDescription {
    return Intl.message(
      'Create separate profiles for different accounts or preferences',
      name: 'profilesDescription',
      desc: '',
      args: [],
    );
  }

  /// `Add Profile`
  String get addProfile {
    return Intl.message('Add Profile', name: 'addProfile', desc: '', args: []);
  }

  /// `Delete Profile`
  String get deleteProfile {
    return Intl.message(
      'Delete Profile',
      name: 'deleteProfile',
      desc: '',
      args: [],
    );
  }

  /// `Rename Profile`
  String get renameProfile {
    return Intl.message(
      'Rename Profile',
      name: 'renameProfile',
      desc: '',
      args: [],
    );
  }

  /// `Switch Profile`
  String get switchProfile {
    return Intl.message(
      'Switch Profile',
      name: 'switchProfile',
      desc: '',
      args: [],
    );
  }

  /// `Profile Name`
  String get profileName {
    return Intl.message(
      'Profile Name',
      name: 'profileName',
      desc: '',
      args: [],
    );
  }

  /// `New Profile Name`
  String get newProfileName {
    return Intl.message(
      'New Profile Name',
      name: 'newProfileName',
      desc: '',
      args: [],
    );
  }

  /// `Default`
  String get defaultProfile {
    return Intl.message('Default', name: 'defaultProfile', desc: '', args: []);
  }

  /// `Active`
  String get profileInUse {
    return Intl.message('Active', name: 'profileInUse', desc: '', args: []);
  }

  /// `Cannot delete default profile`
  String get cannotDeleteDefault {
    return Intl.message(
      'Cannot delete default profile',
      name: 'cannotDeleteDefault',
      desc: '',
      args: [],
    );
  }

  /// `Cannot rename default profile`
  String get cannotRenameDefault {
    return Intl.message(
      'Cannot rename default profile',
      name: 'cannotRenameDefault',
      desc: '',
      args: [],
    );
  }

  /// `Audio Focus`
  String get audioFocus {
    return Intl.message('Audio Focus', name: 'audioFocus', desc: '', args: []);
  }

  /// `Pause playback on interruptions`
  String get audioFocusDescription {
    return Intl.message(
      'Pause playback on interruptions',
      name: 'audioFocusDescription',
      desc: '',
      args: [],
    );
  }

  /// `Pause on Phone Call`
  String get pauseOnCall {
    return Intl.message(
      'Pause on Phone Call',
      name: 'pauseOnCall',
      desc: '',
      args: [],
    );
  }

  /// `Pause on Headphone Disconnect`
  String get pauseOnHeadphones {
    return Intl.message(
      'Pause on Headphone Disconnect',
      name: 'pauseOnHeadphones',
      desc: '',
      args: [],
    );
  }

  /// `Subtitle Size`
  String get subtitleSize {
    return Intl.message(
      'Subtitle Size',
      name: 'subtitleSize',
      desc: '',
      args: [],
    );
  }

  /// `Adjust the size of subtitles on video`
  String get subtitleSizeDescription {
    return Intl.message(
      'Adjust the size of subtitles on video',
      name: 'subtitleSizeDescription',
      desc: '',
      args: [],
    );
  }

  /// `Small`
  String get subtitleSizeSmall {
    return Intl.message('Small', name: 'subtitleSizeSmall', desc: '', args: []);
  }

  /// `Medium`
  String get subtitleSizeMedium {
    return Intl.message(
      'Medium',
      name: 'subtitleSizeMedium',
      desc: '',
      args: [],
    );
  }

  /// `Large`
  String get subtitleSizeLarge {
    return Intl.message('Large', name: 'subtitleSizeLarge', desc: '', args: []);
  }

  /// `Extra Large`
  String get subtitleSizeExtraLarge {
    return Intl.message(
      'Extra Large',
      name: 'subtitleSizeExtraLarge',
      desc: '',
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

  /// `Gaming`
  String get categoryGaming {
    return Intl.message(
      'Gaming',
      name: 'categoryGaming',
      desc: 'Home category chip: gaming kiosk',
      args: [],
    );
  }

  /// `Movies & Shows`
  String get categoryMoviesAndShows {
    return Intl.message(
      'Movies & Shows',
      name: 'categoryMoviesAndShows',
      desc: 'Home category chip: movies and shows trailers kiosk',
      args: [],
    );
  }

  /// `Podcasts`
  String get categoryPodcasts {
    return Intl.message(
      'Podcasts',
      name: 'categoryPodcasts',
      desc: 'Home category chip: podcasts kiosk',
      args: [],
    );
  }

  /// `Saved`
  String get saved {
    return Intl.message('Saved', name: 'saved', desc: 'Saved label', args: []);
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Limited`
  String get serviceLimited {
    return Intl.message('Limited', name: 'serviceLimited', desc: '', args: []);
  }

  /// `Piped and YouTube Explode were retired. YouTube now blocks the server IPs Piped instances run on, so no public instance can play video (its team is rebuilding on a new extractor). YouTube Explode stopped receiving fixes in May 2026 and only 360p still works. NewPipe Extractor does the same on-device extraction, is actively maintained, and plays up to 4K.`
  String get serviceRemovedNote {
    return Intl.message(
      'Piped and YouTube Explode were retired. YouTube now blocks the server IPs Piped instances run on, so no public instance can play video (its team is rebuilding on a new extractor). YouTube Explode stopped receiving fixes in May 2026 and only 360p still works. NewPipe Extractor does the same on-device extraction, is actively maintained, and plays up to 4K.',
      name: 'serviceRemovedNote',
      desc: '',
      args: [],
    );
  }

  /// `Few public Invidious instances still allow apps; playback may fail if your instance blocks API access.`
  String get serviceInvidiousNote {
    return Intl.message(
      'Few public Invidious instances still allow apps; playback may fail if your instance blocks API access.',
      name: 'serviceInvidiousNote',
      desc: '',
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
    return Intl.message('Theme', name: 'theme', desc: 'Theme label', args: []);
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
    return Intl.message('About', name: 'about', desc: 'About label', args: []);
  }

  /// `Video`
  String get video {
    return Intl.message('Video', name: 'video', desc: 'Video label', args: []);
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
    return Intl.message('Retry', name: 'retry', desc: 'Retry label', args: []);
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
    return Intl.message('Canada', name: 'canada', desc: '', args: []);
  }

  /// `France`
  String get france {
    return Intl.message('France', name: 'france', desc: '', args: []);
  }

  /// `India`
  String get india {
    return Intl.message('India', name: 'india', desc: '', args: []);
  }

  /// `Netherlands`
  String get netherlands {
    return Intl.message('Netherlands', name: 'netherlands', desc: '', args: []);
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
    return Intl.message('Share', name: 'share', desc: 'Share label.', args: []);
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
    return Intl.message('Instances', name: 'instances', desc: '', args: []);
  }

  /// `Please consider switching to a different region for better results.`
  String get switchRegion {
    return Intl.message(
      'Please consider switching to a different region for better results.',
      name: 'switchRegion',
      desc: '',
      args: [],
    );
  }

  /// `'Swipe down to dismiss' disabled`
  String get swipeDownToDismissDisabled {
    return Intl.message(
      '\'Swipe down to dismiss\' disabled',
      name: 'swipeDownToDismissDisabled',
      desc: '',
      args: [],
    );
  }

  /// `'Swipe up to dismiss' enabled`
  String get swipeUpToDismissEnabled {
    return Intl.message(
      '\'Swipe up to dismiss\' enabled',
      name: 'swipeUpToDismissEnabled',
      desc: '',
      args: [],
    );
  }

  /// `No Comments Found`
  String get noCommentsFound {
    return Intl.message(
      'No Comments Found',
      name: 'noCommentsFound',
      desc: '',
      args: [],
    );
  }

  /// `Comments are disabled`
  String get commentsDisabled {
    return Intl.message(
      'Comments are disabled',
      name: 'commentsDisabled',
      desc: '',
      args: [],
    );
  }

  /// `Replies are not available yet`
  String get repliesNotSupported {
    return Intl.message(
      'Replies are not available yet',
      name: 'repliesNotSupported',
      desc: '',
      args: [],
    );
  }

  /// `Pinned`
  String get pinned {
    return Intl.message('Pinned', name: 'pinned', desc: '', args: []);
  }

  /// `Disable PIP player`
  String get disablePipPlayer {
    return Intl.message(
      'Disable PIP player',
      name: 'disablePipPlayer',
      desc: '',
      args: [],
    );
  }

  /// `Videos`
  String get videos {
    return Intl.message('Videos', name: 'videos', desc: '', args: []);
  }

  /// `Shorts`
  String get shorts {
    return Intl.message('Shorts', name: 'shorts', desc: '', args: []);
  }

  /// `Playlists`
  String get playlists {
    return Intl.message('Playlists', name: 'playlists', desc: '', args: []);
  }

  /// `Subscribe to channels to see their Shorts here`
  String get noShorts {
    return Intl.message(
      'Subscribe to channels to see their Shorts here',
      name: 'noShorts',
      desc: '',
      args: [],
    );
  }

  /// `No playlists available`
  String get noPlaylists {
    return Intl.message(
      'No playlists available',
      name: 'noPlaylists',
      desc: '',
      args: [],
    );
  }

  /// `Library`
  String get library {
    return Intl.message('Library', name: 'library', desc: '', args: []);
  }

  /// `Sort by`
  String get sortBy {
    return Intl.message('Sort by', name: 'sortBy', desc: '', args: []);
  }

  /// `Date added`
  String get dateAdded {
    return Intl.message('Date added', name: 'dateAdded', desc: '', args: []);
  }

  /// `Title`
  String get title {
    return Intl.message('Title', name: 'title', desc: '', args: []);
  }

  /// `Duration`
  String get duration {
    return Intl.message('Duration', name: 'duration', desc: '', args: []);
  }

  /// `selected`
  String get selected {
    return Intl.message('selected', name: 'selected', desc: '', args: []);
  }

  /// `Select all`
  String get selectAll {
    return Intl.message('Select all', name: 'selectAll', desc: '', args: []);
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Sort`
  String get sort {
    return Intl.message('Sort', name: 'sort', desc: '', args: []);
  }

  /// `Select videos`
  String get selectVideos {
    return Intl.message(
      'Select videos',
      name: 'selectVideos',
      desc: '',
      args: [],
    );
  }

  /// `Clear all saved`
  String get clearAllSaved {
    return Intl.message(
      'Clear all saved',
      name: 'clearAllSaved',
      desc: '',
      args: [],
    );
  }

  /// `Clear all history`
  String get clearAllHistory {
    return Intl.message(
      'Clear all history',
      name: 'clearAllHistory',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to remove all saved videos?`
  String get clearAllSavedConfirm {
    return Intl.message(
      'Are you sure you want to remove all saved videos?',
      name: 'clearAllSavedConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to clear all watch history?`
  String get clearAllHistoryConfirm {
    return Intl.message(
      'Are you sure you want to clear all watch history?',
      name: 'clearAllHistoryConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Clear all`
  String get clearAll {
    return Intl.message('Clear all', name: 'clearAll', desc: '', args: []);
  }

  /// `Search saved videos...`
  String get searchSavedVideos {
    return Intl.message(
      'Search saved videos...',
      name: 'searchSavedVideos',
      desc: '',
      args: [],
    );
  }

  /// `No saved videos`
  String get noSavedVideos {
    return Intl.message(
      'No saved videos',
      name: 'noSavedVideos',
      desc: '',
      args: [],
    );
  }

  /// `Start saving videos to watch later`
  String get startSavingVideos {
    return Intl.message(
      'Start saving videos to watch later',
      name: 'startSavingVideos',
      desc: '',
      args: [],
    );
  }

  /// `No watch history`
  String get noHistory {
    return Intl.message(
      'No watch history',
      name: 'noHistory',
      desc: '',
      args: [],
    );
  }

  /// `Videos you watch will appear here`
  String get watchSomeVideos {
    return Intl.message(
      'Videos you watch will appear here',
      name: 'watchSomeVideos',
      desc: '',
      args: [],
    );
  }

  /// `Delete video`
  String get deleteVideo {
    return Intl.message(
      'Delete video',
      name: 'deleteVideo',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to remove this video?`
  String get deleteVideoConfirm {
    return Intl.message(
      'Are you sure you want to remove this video?',
      name: 'deleteVideoConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Remove from saved`
  String get removeFromSaved {
    return Intl.message(
      'Remove from saved',
      name: 'removeFromSaved',
      desc: '',
      args: [],
    );
  }

  /// `Remove from history`
  String get removeFromHistory {
    return Intl.message(
      'Remove from history',
      name: 'removeFromHistory',
      desc: '',
      args: [],
    );
  }

  /// `views`
  String get views {
    return Intl.message('views', name: 'views', desc: '', args: []);
  }

  /// `Subscriptions`
  String get subscriptions {
    return Intl.message(
      'Subscriptions',
      name: 'subscriptions',
      desc: '',
      args: [],
    );
  }

  /// `Channels`
  String get channels {
    return Intl.message('Channels', name: 'channels', desc: '', args: []);
  }

  /// `Search subscriptions...`
  String get searchSubscriptions {
    return Intl.message(
      'Search subscriptions...',
      name: 'searchSubscriptions',
      desc: '',
      args: [],
    );
  }

  /// `No videos found`
  String get noVideosFound {
    return Intl.message(
      'No videos found',
      name: 'noVideosFound',
      desc: '',
      args: [],
    );
  }

  /// `Pull down to refresh`
  String get refreshToLoad {
    return Intl.message(
      'Pull down to refresh',
      name: 'refreshToLoad',
      desc: '',
      args: [],
    );
  }

  /// `Unsubscribe`
  String get unsubscribe {
    return Intl.message('Unsubscribe', name: 'unsubscribe', desc: '', args: []);
  }

  /// `Unsubscribe from this channel?`
  String get unsubscribeConfirm {
    return Intl.message(
      'Unsubscribe from this channel?',
      name: 'unsubscribeConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message('Search', name: 'search', desc: '', args: []);
  }

  /// `Search YouTube...`
  String get searchYouTube {
    return Intl.message(
      'Search YouTube...',
      name: 'searchYouTube',
      desc: '',
      args: [],
    );
  }

  /// `Search for videos, channels, and playlists`
  String get searchForVideosChannels {
    return Intl.message(
      'Search for videos, channels, and playlists',
      name: 'searchForVideosChannels',
      desc: '',
      args: [],
    );
  }

  /// `Recent searches`
  String get recentSearches {
    return Intl.message(
      'Recent searches',
      name: 'recentSearches',
      desc: '',
      args: [],
    );
  }

  /// `Save Search History`
  String get searchHistoryEnabled {
    return Intl.message(
      'Save Search History',
      name: 'searchHistoryEnabled',
      desc: '',
      args: [],
    );
  }

  /// `Save your search queries for quick access`
  String get searchHistoryEnabledDescription {
    return Intl.message(
      'Save your search queries for quick access',
      name: 'searchHistoryEnabledDescription',
      desc: '',
      args: [],
    );
  }

  /// `Show Search History`
  String get showSearchHistory {
    return Intl.message(
      'Show Search History',
      name: 'showSearchHistory',
      desc: '',
      args: [],
    );
  }

  /// `Display your recent searches in search screen`
  String get showSearchHistoryDescription {
    return Intl.message(
      'Display your recent searches in search screen',
      name: 'showSearchHistoryDescription',
      desc: '',
      args: [],
    );
  }

  /// `Copy link`
  String get copyLink {
    return Intl.message(
      'Copy link',
      name: 'copyLink',
      desc: 'Copy link button label',
      args: [],
    );
  }

  /// `Share via`
  String get shareVia {
    return Intl.message(
      'Share via',
      name: 'shareVia',
      desc: 'Share via apps button label',
      args: [],
    );
  }

  /// `Copied to clipboard`
  String get copiedToClipboard {
    return Intl.message(
      'Copied to clipboard',
      name: 'copiedToClipboard',
      desc: 'Snackbar message when link is copied',
      args: [],
    );
  }

  /// `Like`
  String get like {
    return Intl.message(
      'Like',
      name: 'like',
      desc: 'Like button label when count is unavailable',
      args: [],
    );
  }

  /// `Dislike`
  String get dislike {
    return Intl.message(
      'Dislike',
      name: 'dislike',
      desc: 'Dislike button label when count is unavailable',
      args: [],
    );
  }

  /// `Download`
  String get download {
    return Intl.message(
      'Download',
      name: 'download',
      desc: 'Download button label',
      args: [],
    );
  }

  /// `Downloads`
  String get downloads {
    return Intl.message(
      'Downloads',
      name: 'downloads',
      desc: 'Downloads screen title',
      args: [],
    );
  }

  /// `Downloading`
  String get downloading {
    return Intl.message(
      'Downloading',
      name: 'downloading',
      desc: 'Downloading status label',
      args: [],
    );
  }

  /// `Completed`
  String get completed {
    return Intl.message(
      'Completed',
      name: 'completed',
      desc: 'Completed status label',
      args: [],
    );
  }

  /// `Pending`
  String get pending {
    return Intl.message(
      'Pending',
      name: 'pending',
      desc: 'Pending status label',
      args: [],
    );
  }

  /// `Paused`
  String get paused {
    return Intl.message(
      'Paused',
      name: 'paused',
      desc: 'Paused status label',
      args: [],
    );
  }

  /// `Failed`
  String get failed {
    return Intl.message(
      'Failed',
      name: 'failed',
      desc: 'Failed status label',
      args: [],
    );
  }

  /// `Cancelled`
  String get cancelled {
    return Intl.message(
      'Cancelled',
      name: 'cancelled',
      desc: 'Cancelled status label',
      args: [],
    );
  }

  /// `Merging`
  String get merging {
    return Intl.message(
      'Merging',
      name: 'merging',
      desc: 'Merging audio and video status',
      args: [],
    );
  }

  /// `Downloading video`
  String get downloadingVideo {
    return Intl.message(
      'Downloading video',
      name: 'downloadingVideo',
      desc: 'Phase indicator when downloading video track',
      args: [],
    );
  }

  /// `Downloading audio`
  String get downloadingAudio {
    return Intl.message(
      'Downloading audio',
      name: 'downloadingAudio',
      desc: 'Phase indicator when downloading audio track',
      args: [],
    );
  }

  /// `No Downloads`
  String get noDownloads {
    return Intl.message(
      'No Downloads',
      name: 'noDownloads',
      desc: 'Empty downloads state title',
      args: [],
    );
  }

  /// `Downloaded videos will appear here`
  String get noDownloadsHint {
    return Intl.message(
      'Downloaded videos will appear here',
      name: 'noDownloadsHint',
      desc: 'Empty downloads state hint',
      args: [],
    );
  }

  /// `Download Type`
  String get downloadType {
    return Intl.message(
      'Download Type',
      name: 'downloadType',
      desc: 'Download type selector label',
      args: [],
    );
  }

  /// `Video + Audio`
  String get videoWithAudio {
    return Intl.message(
      'Video + Audio',
      name: 'videoWithAudio',
      desc: 'Video with audio download type',
      args: [],
    );
  }

  /// `Video Only`
  String get videoOnly {
    return Intl.message(
      'Video Only',
      name: 'videoOnly',
      desc: 'Video only download type',
      args: [],
    );
  }

  /// `Audio Only`
  String get audioOnly {
    return Intl.message(
      'Audio Only',
      name: 'audioOnly',
      desc: 'Audio only download type',
      args: [],
    );
  }

  /// `Audio`
  String get audio {
    return Intl.message(
      'Audio',
      name: 'audio',
      desc: 'Audio badge label',
      args: [],
    );
  }

  /// `Video+Audio`
  String get videoAudio {
    return Intl.message(
      'Video+Audio',
      name: 'videoAudio',
      desc: 'Video with audio badge label',
      args: [],
    );
  }

  /// `Video Quality`
  String get videoQuality {
    return Intl.message(
      'Video Quality',
      name: 'videoQuality',
      desc: 'Video quality selector label',
      args: [],
    );
  }

  /// `Audio Quality`
  String get audioQuality {
    return Intl.message(
      'Audio Quality',
      name: 'audioQuality',
      desc: 'Audio quality selector label',
      args: [],
    );
  }

  /// `Start Download`
  String get startDownload {
    return Intl.message(
      'Start Download',
      name: 'startDownload',
      desc: 'Start download button label',
      args: [],
    );
  }

  /// `Download started`
  String get downloadStarted {
    return Intl.message(
      'Download started',
      name: 'downloadStarted',
      desc: 'Download started snackbar message',
      args: [],
    );
  }

  /// `Delete Download`
  String get deleteDownload {
    return Intl.message(
      'Delete Download',
      name: 'deleteDownload',
      desc: 'Delete download dialog title',
      args: [],
    );
  }

  /// `Are you sure you want to delete this download?`
  String get deleteDownloadConfirm {
    return Intl.message(
      'Are you sure you want to delete this download?',
      name: 'deleteDownloadConfirm',
      desc: 'Delete download confirmation message',
      args: [],
    );
  }

  /// `Pause`
  String get pause {
    return Intl.message(
      'Pause',
      name: 'pause',
      desc: 'Pause button label',
      args: [],
    );
  }

  /// `Resume`
  String get resume {
    return Intl.message(
      'Resume',
      name: 'resume',
      desc: 'Resume button label',
      args: [],
    );
  }

  /// `All`
  String get all {
    return Intl.message('All', name: 'all', desc: 'All tab label', args: []);
  }

  /// `An unknown error occurred`
  String get unknownError {
    return Intl.message(
      'An unknown error occurred',
      name: 'unknownError',
      desc: 'Unknown error message',
      args: [],
    );
  }

  /// `Failed to open file`
  String get failedToOpenFile {
    return Intl.message(
      'Failed to open file',
      name: 'failedToOpenFile',
      desc: 'Error message when file cannot be opened',
      args: [],
    );
  }

  /// `File not found`
  String get fileNotFound {
    return Intl.message(
      'File not found',
      name: 'fileNotFound',
      desc: 'Error message when downloaded file is missing',
      args: [],
    );
  }

  /// `Download failed: {title}`
  String downloadFailed(String title) {
    return Intl.message(
      'Download failed: $title',
      name: 'downloadFailed',
      desc: 'Error message when download fails',
      args: [title],
    );
  }

  /// `Auto Picture-in-Picture`
  String get autoPip {
    return Intl.message(
      'Auto Picture-in-Picture',
      name: 'autoPip',
      desc: 'Setting to enable auto PiP when pressing home button',
      args: [],
    );
  }

  /// `Automatically enter PiP mode when pressing home button while video is playing`
  String get autoPipDescription {
    return Intl.message(
      'Automatically enter PiP mode when pressing home button while video is playing',
      name: 'autoPipDescription',
      desc: 'Description for auto PiP setting',
      args: [],
    );
  }

  /// `Save to Device`
  String get saveToDevice {
    return Intl.message(
      'Save to Device',
      name: 'saveToDevice',
      desc: 'Save downloaded file to device storage',
      args: [],
    );
  }

  /// `Saving to device...`
  String get savingToDevice {
    return Intl.message(
      'Saving to device...',
      name: 'savingToDevice',
      desc: 'Message shown while saving file to device',
      args: [],
    );
  }

  /// `Saved to device`
  String get savedToDevice {
    return Intl.message(
      'Saved to device',
      name: 'savedToDevice',
      desc: 'Success message when file is saved to device',
      args: [],
    );
  }

  /// `Failed to save to device`
  String get saveToDeviceFailed {
    return Intl.message(
      'Failed to save to device',
      name: 'saveToDeviceFailed',
      desc: 'Error message when save to device fails',
      args: [],
    );
  }

  /// `New upload notifications`
  String get newVideoNotifications {
    return Intl.message(
      'New upload notifications',
      name: 'newVideoNotifications',
      desc: 'Setting for subscription upload notifications',
      args: [],
    );
  }

  /// `Get notified when channels you subscribe to upload`
  String get newVideoNotificationsDescription {
    return Intl.message(
      'Get notified when channels you subscribe to upload',
      name: 'newVideoNotificationsDescription',
      desc: 'Description for upload notification setting',
      args: [],
    );
  }

  /// `Notification permission was denied`
  String get notificationsDenied {
    return Intl.message(
      'Notification permission was denied',
      name: 'notificationsDenied',
      desc: 'Shown when the notification permission is refused',
      args: [],
    );
  }

  /// `Queue`
  String get queue {
    return Intl.message(
      'Queue',
      name: 'queue',
      desc: 'Playback queue title',
      args: [],
    );
  }

  /// `Queue is empty`
  String get queueEmpty {
    return Intl.message(
      'Queue is empty',
      name: 'queueEmpty',
      desc: 'Empty playback queue',
      args: [],
    );
  }

  /// `Shuffle`
  String get queueShuffle {
    return Intl.message(
      'Shuffle',
      name: 'queueShuffle',
      desc: 'Shuffles the upcoming queue',
      args: [],
    );
  }

  /// `Clear`
  String get queueClear {
    return Intl.message(
      'Clear',
      name: 'queueClear',
      desc: 'Clears the playback queue',
      args: [],
    );
  }

  /// `Remove from queue`
  String get removeFromQueue {
    return Intl.message(
      'Remove from queue',
      name: 'removeFromQueue',
      desc: 'Removes one queue entry',
      args: [],
    );
  }

  /// `Play next`
  String get playNext {
    return Intl.message(
      'Play next',
      name: 'playNext',
      desc: 'Queues a video directly after the current one',
      args: [],
    );
  }

  /// `Add to queue`
  String get addToQueue {
    return Intl.message(
      'Add to queue',
      name: 'addToQueue',
      desc: 'Appends a video to the queue',
      args: [],
    );
  }

  /// `Added to queue`
  String get addedToQueue {
    return Intl.message(
      'Added to queue',
      name: 'addedToQueue',
      desc: 'Confirmation for queue append',
      args: [],
    );
  }

  /// `Added to play next`
  String get addedToPlayNext {
    return Intl.message(
      'Added to play next',
      name: 'addedToPlayNext',
      desc: 'Confirmation for play next',
      args: [],
    );
  }

  /// `Save to playlist`
  String get saveToPlaylist {
    return Intl.message(
      'Save to playlist',
      name: 'saveToPlaylist',
      desc: 'Playlist picker title',
      args: [],
    );
  }

  /// `Playlists`
  String get localPlaylists {
    return Intl.message(
      'Playlists',
      name: 'localPlaylists',
      desc: 'Local playlists screen title',
      args: [],
    );
  }

  /// `New Playlist`
  String get newPlaylist {
    return Intl.message(
      'New Playlist',
      name: 'newPlaylist',
      desc: 'New playlist dialog title',
      args: [],
    );
  }

  /// `+ New`
  String get newPlaylistShort {
    return Intl.message(
      '+ New',
      name: 'newPlaylistShort',
      desc: 'Compact create-playlist action',
      args: [],
    );
  }

  /// `Playlist name`
  String get playlistNameHint {
    return Intl.message(
      'Playlist name',
      name: 'playlistNameHint',
      desc: 'Playlist name field hint',
      args: [],
    );
  }

  /// `Create`
  String get createAction {
    return Intl.message(
      'Create',
      name: 'createAction',
      desc: 'Confirms creation',
      args: [],
    );
  }

  /// `Rename`
  String get renameAction {
    return Intl.message(
      'Rename',
      name: 'renameAction',
      desc: 'Renames an item',
      args: [],
    );
  }

  /// `Rename Playlist`
  String get renamePlaylistTitle {
    return Intl.message(
      'Rename Playlist',
      name: 'renamePlaylistTitle',
      desc: 'Rename playlist dialog title',
      args: [],
    );
  }

  /// `New name`
  String get newNameHint {
    return Intl.message(
      'New name',
      name: 'newNameHint',
      desc: 'New name field hint',
      args: [],
    );
  }

  /// `Delete Playlist`
  String get deletePlaylistTitle {
    return Intl.message(
      'Delete Playlist',
      name: 'deletePlaylistTitle',
      desc: 'Delete playlist dialog title',
      args: [],
    );
  }

  /// `Delete playlist`
  String get deletePlaylistAction {
    return Intl.message(
      'Delete playlist',
      name: 'deletePlaylistAction',
      desc: 'Deletes a playlist',
      args: [],
    );
  }

  /// `Delete {name}?`
  String deletePlaylistConfirm(String name) {
    return Intl.message(
      'Delete $name?',
      name: 'deletePlaylistConfirm',
      desc: 'Confirms deleting a named playlist',
      args: [name],
    );
  }

  /// `No playlists yet.\nTap + to create one.`
  String get noPlaylistsYet {
    return Intl.message(
      'No playlists yet.\nTap + to create one.',
      name: 'noPlaylistsYet',
      desc: 'Empty local playlists screen',
      args: [],
    );
  }

  /// `No playlists yet.\nTap + New to create one.`
  String get noPlaylistsYetPicker {
    return Intl.message(
      'No playlists yet.\nTap + New to create one.',
      name: 'noPlaylistsYetPicker',
      desc: 'Empty playlist picker',
      args: [],
    );
  }

  /// `Added to {name}`
  String addedToPlaylist(String name) {
    return Intl.message(
      'Added to $name',
      name: 'addedToPlaylist',
      desc: 'Confirms adding a video to a named playlist',
      args: [name],
    );
  }

  /// `Play all`
  String get playAll {
    return Intl.message(
      'Play all',
      name: 'playAll',
      desc: 'Plays every video in a playlist',
      args: [],
    );
  }

  /// `Playlist not found`
  String get playlistNotFound {
    return Intl.message(
      'Playlist not found',
      name: 'playlistNotFound',
      desc: 'Missing playlist',
      args: [],
    );
  }

  /// `No videos yet`
  String get noVideosInPlaylist {
    return Intl.message(
      'No videos yet',
      name: 'noVideosInPlaylist',
      desc: 'Empty playlist',
      args: [],
    );
  }

  /// `Long-press a video to save it to a playlist`
  String get addVideosHint {
    return Intl.message(
      'Long-press a video to save it to a playlist',
      name: 'addVideosHint',
      desc: 'Hint for filling an empty playlist',
      args: [],
    );
  }

  /// `{count} videos`
  String videoCountLabel(int count) {
    return Intl.message(
      '$count videos',
      name: 'videoCountLabel',
      desc: 'Number of videos',
      args: [count],
    );
  }

  /// `Debug Console`
  String get debugConsole {
    return Intl.message(
      'Debug Console',
      name: 'debugConsole',
      desc: 'Debug console screen title',
      args: [],
    );
  }

  /// `Share logs`
  String get shareLogs {
    return Intl.message(
      'Share logs',
      name: 'shareLogs',
      desc: 'Shares the collected log file',
      args: [],
    );
  }

  /// `Clear logs`
  String get clearLogs {
    return Intl.message(
      'Clear logs',
      name: 'clearLogs',
      desc: 'Clears collected logs',
      args: [],
    );
  }

  /// `Auto-scroll on`
  String get autoScrollOn {
    return Intl.message(
      'Auto-scroll on',
      name: 'autoScrollOn',
      desc: 'Log auto-scroll enabled',
      args: [],
    );
  }

  /// `Auto-scroll off`
  String get autoScrollOff {
    return Intl.message(
      'Auto-scroll off',
      name: 'autoScrollOff',
      desc: 'Log auto-scroll disabled',
      args: [],
    );
  }

  /// `No logs yet`
  String get noLogs {
    return Intl.message(
      'No logs yet',
      name: 'noLogs',
      desc: 'Empty log console',
      args: [],
    );
  }

  /// `Logs`
  String get logsLabel {
    return Intl.message(
      'Logs',
      name: 'logsLabel',
      desc: 'Log count label',
      args: [],
    );
  }

  /// `Image Cache`
  String get imageCacheLabel {
    return Intl.message(
      'Image Cache',
      name: 'imageCacheLabel',
      desc: 'Image cache size label',
      args: [],
    );
  }

  /// `Platform`
  String get platformLabel {
    return Intl.message(
      'Platform',
      name: 'platformLabel',
      desc: 'Operating system label',
      args: [],
    );
  }

  /// `Sleep timer`
  String get sleepTimer {
    return Intl.message(
      'Sleep timer',
      name: 'sleepTimer',
      desc: 'Sleep timer setting',
      args: [],
    );
  }

  /// `Off`
  String get sleepTimerOff {
    return Intl.message(
      'Off',
      name: 'sleepTimerOff',
      desc: 'Sleep timer disabled',
      args: [],
    );
  }

  /// `End of video`
  String get sleepTimerEndOfVideo {
    return Intl.message(
      'End of video',
      name: 'sleepTimerEndOfVideo',
      desc: 'Sleep timer stops when the video ends',
      args: [],
    );
  }

  /// `{count} minutes`
  String sleepTimerMinutes(int count) {
    return Intl.message(
      '$count minutes',
      name: 'sleepTimerMinutes',
      desc: 'Sleep timer duration',
      args: [count],
    );
  }

  /// `{count} min`
  String sleepTimerMinutesShort(int count) {
    return Intl.message(
      '$count min',
      name: 'sleepTimerMinutesShort',
      desc: 'Compact sleep timer duration',
      args: [count],
    );
  }

  /// `Custom`
  String get sleepTimerCustom {
    return Intl.message(
      'Custom',
      name: 'sleepTimerCustom',
      desc: 'Custom sleep timer duration',
      args: [],
    );
  }

  /// `Custom timer`
  String get sleepTimerCustomTitle {
    return Intl.message(
      'Custom timer',
      name: 'sleepTimerCustomTitle',
      desc: 'Custom timer dialog title',
      args: [],
    );
  }

  /// `Enter minutes`
  String get sleepTimerEnterMinutes {
    return Intl.message(
      'Enter minutes',
      name: 'sleepTimerEnterMinutes',
      desc: 'Custom timer field hint',
      args: [],
    );
  }

  /// `Set`
  String get sleepTimerSet {
    return Intl.message(
      'Set',
      name: 'sleepTimerSet',
      desc: 'Confirms the custom timer',
      args: [],
    );
  }

  /// `Sleep timer ended`
  String get sleepTimerEnded {
    return Intl.message(
      'Sleep timer ended',
      name: 'sleepTimerEnded',
      desc: 'Sleep timer fired',
      args: [],
    );
  }

  /// `Following`
  String get following {
    return Intl.message(
      'Following',
      name: 'following',
      desc: 'Header for the subscribed-channels avatar row',
      args: [],
    );
  }

  /// `Today`
  String get today {
    return Intl.message(
      'Today',
      name: 'today',
      desc: 'Filter chip: videos uploaded today',
      args: [],
    );
  }

  /// `Live`
  String get live {
    return Intl.message(
      'Live',
      name: 'live',
      desc: 'Filter chip / badge for live streams',
      args: [],
    );
  }

  /// `Continue Watching`
  String get continueWatching {
    return Intl.message(
      'Continue Watching',
      name: 'continueWatching',
      desc: 'Filter chip: partially watched videos',
      args: [],
    );
  }

  /// `View All`
  String get viewAll {
    return Intl.message(
      'View All',
      name: 'viewAll',
      desc: 'Link to open a full section listing',
      args: [],
    );
  }

  /// `{amount} used`
  String storageUsed(String amount) {
    return Intl.message(
      '$amount used',
      name: 'storageUsed',
      desc: 'Aggregate storage consumed by downloads, e.g. 2.4 GB used',
      args: [amount],
    );
  }

  /// `Comments`
  String get comments {
    return Intl.message(
      'Comments',
      name: 'comments',
      desc: 'Comments section title',
      args: [],
    );
  }

  /// `Couldn't load comments`
  String get commentsLoadFailed {
    return Intl.message(
      'Couldn\'t load comments',
      name: 'commentsLoadFailed',
      desc: 'Comments failed to load',
      args: [],
    );
  }

  /// `Check your connection and try again`
  String get checkConnectionAndRetry {
    return Intl.message(
      'Check your connection and try again',
      name: 'checkConnectionAndRetry',
      desc: 'Generic retry hint',
      args: [],
    );
  }

  /// `The creator has turned off comments for this video`
  String get commentsDisabledByCreator {
    return Intl.message(
      'The creator has turned off comments for this video',
      name: 'commentsDisabledByCreator',
      desc: 'Comments disabled explanation',
      args: [],
    );
  }

  /// `There are no comments on this video yet`
  String get noCommentsYet {
    return Intl.message(
      'There are no comments on this video yet',
      name: 'noCommentsYet',
      desc: 'Empty comments explanation',
      args: [],
    );
  }

  /// `Hearted by creator`
  String get heartedByCreator {
    return Intl.message(
      'Hearted by creator',
      name: 'heartedByCreator',
      desc: 'Comment liked by the video\'s creator',
      args: [],
    );
  }

  /// `{count, plural, =1{1 download} other{{count} downloads}}`
  String downloadsCount(int count) {
    return Intl.plural(
      count,
      one: '1 download',
      other: '$count downloads',
      name: 'downloadsCount',
      desc: 'Number of completed downloads',
      args: [count],
    );
  }

  /// `Your watch stats`
  String get watchStatsTitle {
    return Intl.message(
      'Your watch stats',
      name: 'watchStatsTitle',
      desc: 'Library watch stats card title',
      args: [],
    );
  }

  /// `watched`
  String get watchStatsWatched {
    return Intl.message(
      'watched',
      name: 'watchStatsWatched',
      desc: 'Label under total watch time',
      args: [],
    );
  }

  /// `videos`
  String get watchStatsVideos {
    return Intl.message(
      'videos',
      name: 'watchStatsVideos',
      desc: 'Label under watched video count',
      args: [],
    );
  }

  /// `saved`
  String get watchStatsSaved {
    return Intl.message(
      'saved',
      name: 'watchStatsSaved',
      desc: 'Label under saved video count',
      args: [],
    );
  }

  /// `Most watched: {channel}`
  String watchStatsTopChannel(String channel) {
    return Intl.message(
      'Most watched: $channel',
      name: 'watchStatsTopChannel',
      desc: 'Most watched channel line',
      args: [channel],
    );
  }

  /// `{count} this week`
  String watchStatsThisWeek(int count) {
    return Intl.message(
      '$count this week',
      name: 'watchStatsThisWeek',
      desc: 'Videos watched in the last 7 days',
      args: [count],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
      Locale.fromSubtags(languageCode: 'fr'),
      Locale.fromSubtags(languageCode: 'ja'),
      Locale.fromSubtags(languageCode: 'ko'),
      Locale.fromSubtags(languageCode: 'ml'),
      Locale.fromSubtags(languageCode: 'pl'),
      Locale.fromSubtags(languageCode: 'pt'),
      Locale.fromSubtags(languageCode: 'ru'),
      Locale.fromSubtags(languageCode: 'tr'),
      Locale.fromSubtags(languageCode: 'zh'),
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
