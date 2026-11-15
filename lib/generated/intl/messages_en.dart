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

  static String m3(name) => "Added to ${name}";

  static String m0(count) =>
      "${Intl.plural(count, zero: 'No subscribers', one: 'subscriber', other: 'subscribers')}";

  static String m4(name) => "Delete ${name}?";

  static String m5(title) => "Download failed: ${title}";

  static String m6(count) =>
      "${Intl.plural(count, one: '1 download', other: '${count} downloads')}";

  static String m1(count) =>
      "${Intl.plural(count, one: 'Reply', other: 'Replies')}";

  static String m7(count) => "${count} minutes";

  static String m8(count) => "${count} min";

  static String m9(amount) => "${amount} used";

  static String m10(count) => "${count} videos";

  static String m2(count) =>
      "${Intl.plural(count, zero: 'No views', one: 'view', other: 'views')}";

  static String m11(count) => "${count} this week";

  static String m12(channel) => "Most watched: ${channel}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("About"),
    "addProfile": MessageLookupByLibrary.simpleMessage("Add Profile"),
    "addToQueue": MessageLookupByLibrary.simpleMessage("Add to queue"),
    "addVideosHint": MessageLookupByLibrary.simpleMessage(
      "Long-press a video to save it to a playlist",
    ),
    "addedToPlayNext": MessageLookupByLibrary.simpleMessage(
      "Added to play next",
    ),
    "addedToPlaylist": m3,
    "addedToQueue": MessageLookupByLibrary.simpleMessage("Added to queue"),
    "all": MessageLookupByLibrary.simpleMessage("All"),
    "audio": MessageLookupByLibrary.simpleMessage("Audio"),
    "audioFocus": MessageLookupByLibrary.simpleMessage("Audio Focus"),
    "audioFocusDescription": MessageLookupByLibrary.simpleMessage(
      "Pause playback on interruptions",
    ),
    "audioOnly": MessageLookupByLibrary.simpleMessage("Audio Only"),
    "audioQuality": MessageLookupByLibrary.simpleMessage("Audio Quality"),
    "autoPip": MessageLookupByLibrary.simpleMessage("Auto Picture-in-Picture"),
    "autoPipDescription": MessageLookupByLibrary.simpleMessage(
      "Automatically enter PiP mode when pressing home button while video is playing",
    ),
    "autoScrollOff": MessageLookupByLibrary.simpleMessage("Auto-scroll off"),
    "autoScrollOn": MessageLookupByLibrary.simpleMessage("Auto-scroll on"),
    "backupRestore": MessageLookupByLibrary.simpleMessage("Backup & Restore"),
    "backupRestoreDescription": MessageLookupByLibrary.simpleMessage(
      "Export or import your subscriptions",
    ),
    "canada": MessageLookupByLibrary.simpleMessage("Canada"),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cancelled": MessageLookupByLibrary.simpleMessage("Cancelled"),
    "cannotDeleteDefault": MessageLookupByLibrary.simpleMessage(
      "Cannot delete default profile",
    ),
    "cannotRenameDefault": MessageLookupByLibrary.simpleMessage(
      "Cannot rename default profile",
    ),
    "categoryGaming": MessageLookupByLibrary.simpleMessage("Gaming"),
    "categoryMoviesAndShows": MessageLookupByLibrary.simpleMessage(
      "Movies & Shows",
    ),
    "categoryPodcasts": MessageLookupByLibrary.simpleMessage("Podcasts"),
    "channelSubscribers": m0,
    "channels": MessageLookupByLibrary.simpleMessage("Channels"),
    "checkConnectionAndRetry": MessageLookupByLibrary.simpleMessage(
      "Check your connection and try again",
    ),
    "clearAll": MessageLookupByLibrary.simpleMessage("Clear all"),
    "clearAllHistory": MessageLookupByLibrary.simpleMessage(
      "Clear all history",
    ),
    "clearAllHistoryConfirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to clear all watch history?",
    ),
    "clearAllSaved": MessageLookupByLibrary.simpleMessage("Clear all saved"),
    "clearAllSavedConfirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to remove all saved videos?",
    ),
    "clearLogs": MessageLookupByLibrary.simpleMessage("Clear logs"),
    "commentAuthorNotFound": MessageLookupByLibrary.simpleMessage("Not found"),
    "comments": MessageLookupByLibrary.simpleMessage("Comments"),
    "commentsDisabled": MessageLookupByLibrary.simpleMessage(
      "Comments are disabled",
    ),
    "commentsDisabledByCreator": MessageLookupByLibrary.simpleMessage(
      "The creator has turned off comments for this video",
    ),
    "commentsLoadFailed": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t load comments",
    ),
    "commonSettingsTitle": MessageLookupByLibrary.simpleMessage("Common"),
    "completed": MessageLookupByLibrary.simpleMessage("Completed"),
    "continueWatching": MessageLookupByLibrary.simpleMessage(
      "Continue Watching",
    ),
    "copiedToClipboard": MessageLookupByLibrary.simpleMessage(
      "Copied to clipboard",
    ),
    "copyLink": MessageLookupByLibrary.simpleMessage("Copy link"),
    "createAction": MessageLookupByLibrary.simpleMessage("Create"),
    "dateAdded": MessageLookupByLibrary.simpleMessage("Date added"),
    "debugConsole": MessageLookupByLibrary.simpleMessage("Debug Console"),
    "defaultProfile": MessageLookupByLibrary.simpleMessage("Default"),
    "defaultQuality": MessageLookupByLibrary.simpleMessage("Default Quality"),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "deleteDownload": MessageLookupByLibrary.simpleMessage("Delete Download"),
    "deleteDownloadConfirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this download?",
    ),
    "deletePlaylistAction": MessageLookupByLibrary.simpleMessage(
      "Delete playlist",
    ),
    "deletePlaylistConfirm": m4,
    "deletePlaylistTitle": MessageLookupByLibrary.simpleMessage(
      "Delete Playlist",
    ),
    "deleteProfile": MessageLookupByLibrary.simpleMessage("Delete Profile"),
    "deleteVideo": MessageLookupByLibrary.simpleMessage("Delete video"),
    "deleteVideoConfirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to remove this video?",
    ),
    "developer": MessageLookupByLibrary.simpleMessage("Developer"),
    "disablePipPlayer": MessageLookupByLibrary.simpleMessage(
      "Disable PIP player",
    ),
    "disableVideoHistory": MessageLookupByLibrary.simpleMessage(
      "Disable video history",
    ),
    "dislike": MessageLookupByLibrary.simpleMessage("Dislike"),
    "distractionFree": MessageLookupByLibrary.simpleMessage("Distraction Free"),
    "download": MessageLookupByLibrary.simpleMessage("Download"),
    "downloadFailed": m5,
    "downloadStarted": MessageLookupByLibrary.simpleMessage("Download started"),
    "downloadType": MessageLookupByLibrary.simpleMessage("Download Type"),
    "downloading": MessageLookupByLibrary.simpleMessage("Downloading"),
    "downloadingAudio": MessageLookupByLibrary.simpleMessage(
      "Downloading audio",
    ),
    "downloadingVideo": MessageLookupByLibrary.simpleMessage(
      "Downloading video",
    ),
    "downloads": MessageLookupByLibrary.simpleMessage("Downloads"),
    "downloadsCount": m6,
    "duration": MessageLookupByLibrary.simpleMessage("Duration"),
    "enableHlsPlayerDescription": MessageLookupByLibrary.simpleMessage(
      "Enable HLS player to unlock all quality options. Disable if errors occur.",
    ),
    "exportData": MessageLookupByLibrary.simpleMessage("Export Data"),
    "exportSubscriptions": MessageLookupByLibrary.simpleMessage(
      "Export Subscriptions",
    ),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("Export successful"),
    "failed": MessageLookupByLibrary.simpleMessage("Failed"),
    "failedToOpenFile": MessageLookupByLibrary.simpleMessage(
      "Failed to open file",
    ),
    "fileNotFound": MessageLookupByLibrary.simpleMessage("File not found"),
    "filterAll": MessageLookupByLibrary.simpleMessage("All"),
    "filterChannels": MessageLookupByLibrary.simpleMessage("Channels"),
    "filterMusic": MessageLookupByLibrary.simpleMessage("Music"),
    "filterPlaylists": MessageLookupByLibrary.simpleMessage("Playlists"),
    "filterVideos": MessageLookupByLibrary.simpleMessage("Videos"),
    "following": MessageLookupByLibrary.simpleMessage("Following"),
    "france": MessageLookupByLibrary.simpleMessage("France"),
    "heartedByCreator": MessageLookupByLibrary.simpleMessage(
      "Hearted by creator",
    ),
    "hideComments": MessageLookupByLibrary.simpleMessage("Hide Comments"),
    "hideCommentsButtonFromWatchScreen": MessageLookupByLibrary.simpleMessage(
      "Hide comments button from watch screen.",
    ),
    "hideRelated": MessageLookupByLibrary.simpleMessage("Hide Related"),
    "hideRelatedVideosFromWatchScreen": MessageLookupByLibrary.simpleMessage(
      "Hide related videos from watch screen",
    ),
    "history": MessageLookupByLibrary.simpleMessage("History"),
    "hlsPlayer": MessageLookupByLibrary.simpleMessage("Hls Player"),
    "home": MessageLookupByLibrary.simpleMessage("Home"),
    "homeFeedMode": MessageLookupByLibrary.simpleMessage("Home Feed"),
    "homeFeedModeAuto": MessageLookupByLibrary.simpleMessage("Auto"),
    "homeFeedModeAutoHint": MessageLookupByLibrary.simpleMessage(
      "Show subscriptions if available, otherwise trending",
    ),
    "homeFeedModeFeedOnly": MessageLookupByLibrary.simpleMessage(
      "Subscriptions",
    ),
    "homeFeedModeFeedOnlyHint": MessageLookupByLibrary.simpleMessage(
      "Only show videos from subscribed channels",
    ),
    "homeFeedModeTrendingOnly": MessageLookupByLibrary.simpleMessage(
      "Trending",
    ),
    "homeFeedModeTrendingOnlyHint": MessageLookupByLibrary.simpleMessage(
      "Always show trending videos only",
    ),
    "imageCacheLabel": MessageLookupByLibrary.simpleMessage("Image Cache"),
    "importData": MessageLookupByLibrary.simpleMessage("Import Data"),
    "importError": MessageLookupByLibrary.simpleMessage("Import failed"),
    "importSubscriptions": MessageLookupByLibrary.simpleMessage(
      "Import Subscriptions",
    ),
    "importSuccess": MessageLookupByLibrary.simpleMessage("Import successful"),
    "includeTitle": MessageLookupByLibrary.simpleMessage("Include title"),
    "india": MessageLookupByLibrary.simpleMessage("India"),
    "instances": MessageLookupByLibrary.simpleMessage("Instances"),
    "interaction": MessageLookupByLibrary.simpleMessage("Interaction"),
    "intro": MessageLookupByLibrary.simpleMessage("Intro"),
    "language": MessageLookupByLibrary.simpleMessage("Language"),
    "library": MessageLookupByLibrary.simpleMessage("Library"),
    "like": MessageLookupByLibrary.simpleMessage("Like"),
    "live": MessageLookupByLibrary.simpleMessage("Live"),
    "localPlaylists": MessageLookupByLibrary.simpleMessage("Playlists"),
    "logsLabel": MessageLookupByLibrary.simpleMessage("Logs"),
    "merging": MessageLookupByLibrary.simpleMessage("Merging"),
    "musicOfftopic": MessageLookupByLibrary.simpleMessage("Music: Non-Music"),
    "netherlands": MessageLookupByLibrary.simpleMessage("Netherlands"),
    "newNameHint": MessageLookupByLibrary.simpleMessage("New name"),
    "newPlaylist": MessageLookupByLibrary.simpleMessage("New Playlist"),
    "newPlaylistShort": MessageLookupByLibrary.simpleMessage("+ New"),
    "newProfileName": MessageLookupByLibrary.simpleMessage("New Profile Name"),
    "newVideoNotifications": MessageLookupByLibrary.simpleMessage(
      "New upload notifications",
    ),
    "newVideoNotificationsDescription": MessageLookupByLibrary.simpleMessage(
      "Get notified when channels you subscribe to upload",
    ),
    "noCommentsFound": MessageLookupByLibrary.simpleMessage(
      "No Comments Found",
    ),
    "noCommentsYet": MessageLookupByLibrary.simpleMessage(
      "There are no comments on this video yet",
    ),
    "noDownloads": MessageLookupByLibrary.simpleMessage("No Downloads"),
    "noDownloadsHint": MessageLookupByLibrary.simpleMessage(
      "Downloaded videos will appear here",
    ),
    "noHistory": MessageLookupByLibrary.simpleMessage("No watch history"),
    "noLogs": MessageLookupByLibrary.simpleMessage("No logs yet"),
    "noPlaylists": MessageLookupByLibrary.simpleMessage(
      "No playlists available",
    ),
    "noPlaylistsYet": MessageLookupByLibrary.simpleMessage(
      "No playlists yet.\nTap + to create one.",
    ),
    "noPlaylistsYetPicker": MessageLookupByLibrary.simpleMessage(
      "No playlists yet.\nTap + New to create one.",
    ),
    "noSavedVideos": MessageLookupByLibrary.simpleMessage("No saved videos"),
    "noShorts": MessageLookupByLibrary.simpleMessage(
      "Subscribe to channels to see their Shorts here",
    ),
    "noSubscriptions": MessageLookupByLibrary.simpleMessage("No Subscriptions"),
    "noSubscriptionsHint": MessageLookupByLibrary.simpleMessage(
      "Subscribe to channels to see their videos here",
    ),
    "noUploadDate": MessageLookupByLibrary.simpleMessage("No date"),
    "noUploaderName": MessageLookupByLibrary.simpleMessage("No name"),
    "noVideoAvailableChangedToHls": MessageLookupByLibrary.simpleMessage(
      "No video source available, automatically changed to hls",
    ),
    "noVideoDescription": MessageLookupByLibrary.simpleMessage(
      "No description",
    ),
    "noVideoTitle": MessageLookupByLibrary.simpleMessage("No title"),
    "noVideosFound": MessageLookupByLibrary.simpleMessage("No videos found"),
    "noVideosInPlaylist": MessageLookupByLibrary.simpleMessage("No videos yet"),
    "notificationsDenied": MessageLookupByLibrary.simpleMessage(
      "Notification permission was denied",
    ),
    "openInBrowser": MessageLookupByLibrary.simpleMessage("Open in Browser"),
    "openLinksExternally": MessageLookupByLibrary.simpleMessage(
      "Open links in external browser",
    ),
    "outro": MessageLookupByLibrary.simpleMessage("Outro"),
    "pause": MessageLookupByLibrary.simpleMessage("Pause"),
    "pauseOnCall": MessageLookupByLibrary.simpleMessage("Pause on Phone Call"),
    "pauseOnHeadphones": MessageLookupByLibrary.simpleMessage(
      "Pause on Headphone Disconnect",
    ),
    "paused": MessageLookupByLibrary.simpleMessage("Paused"),
    "pending": MessageLookupByLibrary.simpleMessage("Pending"),
    "pinned": MessageLookupByLibrary.simpleMessage("Pinned"),
    "platformLabel": MessageLookupByLibrary.simpleMessage("Platform"),
    "playAll": MessageLookupByLibrary.simpleMessage("Play all"),
    "playNext": MessageLookupByLibrary.simpleMessage("Play next"),
    "playlist": MessageLookupByLibrary.simpleMessage("Playlist"),
    "playlistNameHint": MessageLookupByLibrary.simpleMessage("Playlist name"),
    "playlistNotFound": MessageLookupByLibrary.simpleMessage(
      "Playlist not found",
    ),
    "playlists": MessageLookupByLibrary.simpleMessage("Playlists"),
    "profileInUse": MessageLookupByLibrary.simpleMessage("Active"),
    "profileName": MessageLookupByLibrary.simpleMessage("Profile Name"),
    "profiles": MessageLookupByLibrary.simpleMessage("Profiles"),
    "profilesDescription": MessageLookupByLibrary.simpleMessage(
      "Create separate profiles for different accounts or preferences",
    ),
    "quality1080p": MessageLookupByLibrary.simpleMessage("1080p"),
    "quality1440p": MessageLookupByLibrary.simpleMessage("1440p"),
    "quality144p": MessageLookupByLibrary.simpleMessage("144p"),
    "quality240p": MessageLookupByLibrary.simpleMessage("240p"),
    "quality360p": MessageLookupByLibrary.simpleMessage("360p"),
    "quality480p": MessageLookupByLibrary.simpleMessage("480p"),
    "quality720p": MessageLookupByLibrary.simpleMessage("720p"),
    "queue": MessageLookupByLibrary.simpleMessage("Queue"),
    "queueClear": MessageLookupByLibrary.simpleMessage("Clear"),
    "queueEmpty": MessageLookupByLibrary.simpleMessage("Queue is empty"),
    "queueShuffle": MessageLookupByLibrary.simpleMessage("Shuffle"),
    "readMoreText": MessageLookupByLibrary.simpleMessage("Read more"),
    "recentSearches": MessageLookupByLibrary.simpleMessage("Recent searches"),
    "refreshToLoad": MessageLookupByLibrary.simpleMessage(
      "Pull down to refresh",
    ),
    "region": MessageLookupByLibrary.simpleMessage("Region"),
    "relatedTitle": MessageLookupByLibrary.simpleMessage("Related"),
    "removeFromHistory": MessageLookupByLibrary.simpleMessage(
      "Remove from history",
    ),
    "removeFromQueue": MessageLookupByLibrary.simpleMessage(
      "Remove from queue",
    ),
    "removeFromSaved": MessageLookupByLibrary.simpleMessage(
      "Remove from saved",
    ),
    "renameAction": MessageLookupByLibrary.simpleMessage("Rename"),
    "renamePlaylistTitle": MessageLookupByLibrary.simpleMessage(
      "Rename Playlist",
    ),
    "renameProfile": MessageLookupByLibrary.simpleMessage("Rename Profile"),
    "repliesNotSupported": MessageLookupByLibrary.simpleMessage(
      "Replies are not available yet",
    ),
    "repliesPlural": m1,
    "resume": MessageLookupByLibrary.simpleMessage("Resume"),
    "retrieveDislikeCounts": MessageLookupByLibrary.simpleMessage(
      "Retrieve dislike counts",
    ),
    "retrieveDislikes": MessageLookupByLibrary.simpleMessage(
      "Retrieve Dislikes",
    ),
    "retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "saveToDevice": MessageLookupByLibrary.simpleMessage("Save to Device"),
    "saveToDeviceFailed": MessageLookupByLibrary.simpleMessage(
      "Failed to save to device",
    ),
    "saveToPlaylist": MessageLookupByLibrary.simpleMessage("Save to playlist"),
    "saved": MessageLookupByLibrary.simpleMessage("Saved"),
    "savedToDevice": MessageLookupByLibrary.simpleMessage("Saved to device"),
    "savedVideosTitle": MessageLookupByLibrary.simpleMessage("Saved Videos"),
    "savingToDevice": MessageLookupByLibrary.simpleMessage(
      "Saving to device...",
    ),
    "search": MessageLookupByLibrary.simpleMessage("Search"),
    "searchFilters": MessageLookupByLibrary.simpleMessage("Filters"),
    "searchForVideosChannels": MessageLookupByLibrary.simpleMessage(
      "Search for videos, channels, and playlists",
    ),
    "searchHistoryEnabled": MessageLookupByLibrary.simpleMessage(
      "Save Search History",
    ),
    "searchHistoryEnabledDescription": MessageLookupByLibrary.simpleMessage(
      "Save your search queries for quick access",
    ),
    "searchSavedVideos": MessageLookupByLibrary.simpleMessage(
      "Search saved videos...",
    ),
    "searchSubscriptions": MessageLookupByLibrary.simpleMessage(
      "Search subscriptions...",
    ),
    "searchYouTube": MessageLookupByLibrary.simpleMessage("Search YouTube..."),
    "seconds": MessageLookupByLibrary.simpleMessage("seconds"),
    "selectAll": MessageLookupByLibrary.simpleMessage("Select all"),
    "selectFile": MessageLookupByLibrary.simpleMessage("Select File"),
    "selectVideos": MessageLookupByLibrary.simpleMessage("Select videos"),
    "selected": MessageLookupByLibrary.simpleMessage("selected"),
    "selfPromotion": MessageLookupByLibrary.simpleMessage("Self Promotion"),
    "serviceExplode": MessageLookupByLibrary.simpleMessage("Explode"),
    "serviceInvidious": MessageLookupByLibrary.simpleMessage("Invidious"),
    "serviceInvidiousNote": MessageLookupByLibrary.simpleMessage(
      "Few public Invidious instances still allow apps; playback may fail if your instance blocks API access.",
    ),
    "serviceLimited": MessageLookupByLibrary.simpleMessage("Limited"),
    "serviceNewPipe": MessageLookupByLibrary.simpleMessage("NewPipe Extractor"),
    "servicePiped": MessageLookupByLibrary.simpleMessage("Piped"),
    "serviceRemovedNote": MessageLookupByLibrary.simpleMessage(
      "Piped and YouTube Explode were retired. YouTube now blocks the server IPs Piped instances run on, so no public instance can play video (its team is rebuilding on a new extractor). YouTube Explode stopped receiving fixes in May 2026 and only 360p still works. NewPipe Extractor does the same on-device extraction, is actively maintained, and plays up to 4K.",
    ),
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "share": MessageLookupByLibrary.simpleMessage("Share"),
    "shareLogs": MessageLookupByLibrary.simpleMessage("Share logs"),
    "shareVia": MessageLookupByLibrary.simpleMessage("Share via"),
    "shorts": MessageLookupByLibrary.simpleMessage("Shorts"),
    "showLessText": MessageLookupByLibrary.simpleMessage("Show less"),
    "showSearchHistory": MessageLookupByLibrary.simpleMessage(
      "Show Search History",
    ),
    "showSearchHistoryDescription": MessageLookupByLibrary.simpleMessage(
      "Display your recent searches in search screen",
    ),
    "skipInterval": MessageLookupByLibrary.simpleMessage("Skip Interval"),
    "skipIntervalDescription": MessageLookupByLibrary.simpleMessage(
      "Double-tap skip duration in seconds",
    ),
    "sleepTimer": MessageLookupByLibrary.simpleMessage("Sleep timer"),
    "sleepTimerCustom": MessageLookupByLibrary.simpleMessage("Custom"),
    "sleepTimerCustomTitle": MessageLookupByLibrary.simpleMessage(
      "Custom timer",
    ),
    "sleepTimerEndOfVideo": MessageLookupByLibrary.simpleMessage(
      "End of video",
    ),
    "sleepTimerEnded": MessageLookupByLibrary.simpleMessage(
      "Sleep timer ended",
    ),
    "sleepTimerEnterMinutes": MessageLookupByLibrary.simpleMessage(
      "Enter minutes",
    ),
    "sleepTimerMinutes": m7,
    "sleepTimerMinutesShort": m8,
    "sleepTimerOff": MessageLookupByLibrary.simpleMessage("Off"),
    "sleepTimerSet": MessageLookupByLibrary.simpleMessage("Set"),
    "sort": MessageLookupByLibrary.simpleMessage("Sort"),
    "sortBy": MessageLookupByLibrary.simpleMessage("Sort by"),
    "sponsor": MessageLookupByLibrary.simpleMessage("Sponsor"),
    "sponsorBlock": MessageLookupByLibrary.simpleMessage("SponsorBlock"),
    "sponsorBlockCategories": MessageLookupByLibrary.simpleMessage(
      "Skip Categories",
    ),
    "sponsorBlockDescription": MessageLookupByLibrary.simpleMessage(
      "Skip sponsored segments automatically",
    ),
    "startDownload": MessageLookupByLibrary.simpleMessage("Start Download"),
    "startSavingVideos": MessageLookupByLibrary.simpleMessage(
      "Start saving videos to watch later",
    ),
    "storageUsed": m9,
    "subscribe": MessageLookupByLibrary.simpleMessage("Subscribe"),
    "subscriptions": MessageLookupByLibrary.simpleMessage("Subscriptions"),
    "subtitleSize": MessageLookupByLibrary.simpleMessage("Subtitle Size"),
    "subtitleSizeDescription": MessageLookupByLibrary.simpleMessage(
      "Adjust the size of subtitles on video",
    ),
    "subtitleSizeExtraLarge": MessageLookupByLibrary.simpleMessage(
      "Extra Large",
    ),
    "subtitleSizeLarge": MessageLookupByLibrary.simpleMessage("Large"),
    "subtitleSizeMedium": MessageLookupByLibrary.simpleMessage("Medium"),
    "subtitleSizeSmall": MessageLookupByLibrary.simpleMessage("Small"),
    "swipeDownToDismissDisabled": MessageLookupByLibrary.simpleMessage(
      "\'Swipe down to dismiss\' disabled",
    ),
    "swipeUpToDismissEnabled": MessageLookupByLibrary.simpleMessage(
      "\'Swipe up to dismiss\' enabled",
    ),
    "switchProfile": MessageLookupByLibrary.simpleMessage("Switch Profile"),
    "switchRegion": MessageLookupByLibrary.simpleMessage(
      "Please consider switching to a different region for better results.",
    ),
    "theme": MessageLookupByLibrary.simpleMessage("Theme"),
    "themeDark": MessageLookupByLibrary.simpleMessage("Dark"),
    "themeDynamic": MessageLookupByLibrary.simpleMessage("Material You"),
    "themeLight": MessageLookupByLibrary.simpleMessage("Light"),
    "themeOled": MessageLookupByLibrary.simpleMessage("OLED Black"),
    "themeSystem": MessageLookupByLibrary.simpleMessage("System"),
    "thereIsNoSavedOrHistoryVideos": MessageLookupByLibrary.simpleMessage(
      "There are no saved/history videos",
    ),
    "thereIsNoSavedVideos": MessageLookupByLibrary.simpleMessage(
      "There are no saved videos",
    ),
    "title": MessageLookupByLibrary.simpleMessage("Title"),
    "today": MessageLookupByLibrary.simpleMessage("Today"),
    "translators": MessageLookupByLibrary.simpleMessage("Translators"),
    "trending": MessageLookupByLibrary.simpleMessage("Trending"),
    "unitedKingdom": MessageLookupByLibrary.simpleMessage("United Kingdom"),
    "unitedStates": MessageLookupByLibrary.simpleMessage("United States"),
    "unknown": MessageLookupByLibrary.simpleMessage("unknown"),
    "unknownError": MessageLookupByLibrary.simpleMessage(
      "An unknown error occurred",
    ),
    "unknownQuality": MessageLookupByLibrary.simpleMessage("Unknown Quality"),
    "unsubscribe": MessageLookupByLibrary.simpleMessage("Unsubscribe"),
    "unsubscribeConfirm": MessageLookupByLibrary.simpleMessage(
      "Unsubscribe from this channel?",
    ),
    "version": MessageLookupByLibrary.simpleMessage("Version"),
    "video": MessageLookupByLibrary.simpleMessage("Video"),
    "videoAudio": MessageLookupByLibrary.simpleMessage("Video+Audio"),
    "videoCountLabel": m10,
    "videoFit": MessageLookupByLibrary.simpleMessage("Video Fit"),
    "videoFitContain": MessageLookupByLibrary.simpleMessage("Contain"),
    "videoFitCover": MessageLookupByLibrary.simpleMessage("Cover"),
    "videoFitFill": MessageLookupByLibrary.simpleMessage("Fill"),
    "videoFitFitHeight": MessageLookupByLibrary.simpleMessage("Fit Height"),
    "videoFitFitWidth": MessageLookupByLibrary.simpleMessage("Fit Width"),
    "videoOnly": MessageLookupByLibrary.simpleMessage("Video Only"),
    "videoQuality": MessageLookupByLibrary.simpleMessage("Video Quality"),
    "videoViews": m2,
    "videoWithAudio": MessageLookupByLibrary.simpleMessage("Video + Audio"),
    "videos": MessageLookupByLibrary.simpleMessage("Videos"),
    "viewAll": MessageLookupByLibrary.simpleMessage("View All"),
    "views": MessageLookupByLibrary.simpleMessage("views"),
    "watchSomeVideos": MessageLookupByLibrary.simpleMessage(
      "Videos you watch will appear here",
    ),
    "watchStatsSaved": MessageLookupByLibrary.simpleMessage("saved"),
    "watchStatsThisWeek": m11,
    "watchStatsTitle": MessageLookupByLibrary.simpleMessage("Your watch stats"),
    "watchStatsTopChannel": m12,
    "watchStatsVideos": MessageLookupByLibrary.simpleMessage("videos"),
    "watchStatsWatched": MessageLookupByLibrary.simpleMessage("watched"),
    "youtubeService": MessageLookupByLibrary.simpleMessage("YouTube Service"),
  };
}
