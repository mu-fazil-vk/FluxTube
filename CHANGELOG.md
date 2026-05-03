## Changelog

### v0.9.1

###### Playback Improvements

- Added a playback queue controller to keep playback state more consistent across navigation and player surfaces.
- Improved NewPipe ExoPlayer integration for native Android playback.
- Refined stream resolution and quality handling for NewPipe playback.
- Improved global player and PiP behavior when moving between watch screens and app navigation.

###### UI & Reliability

- Added a shared thumbnail image widget for more consistent thumbnail loading and fallback behavior.
- Refined watch screen layouts, related video sections, comments, and player overlays across supported backends.
- Improved video data loading and source handling across channel, playlist, search, trending, and watch flows.

###### Release & Build

- Added GitHub Actions workflow to build signed Android APKs on the main branch.
- Added automated draft GitHub releases with universal and split APK artifacts.
- Added signing certificate verification in CI to prevent accidental releases with the wrong Android key.

### v0.9.0

###### New Features

- **Download System**: Full video/audio download support with quality selection, progress tracking, and notification updates.
  - Download videos in multiple qualities (up to 4K)
  - Download audio-only (MP3/AAC)
  - FFmpeg merging for high-quality video+audio streams
  - Download notifications with thumbnails and progress
  - "Save to Device" option to copy downloads to public storage (Movies/Music folders)
  - **All YouTube services supported** (NewPipe Extractor, Piped, Invidious, Explode)
- **Background Playback**: Continue listening when app is minimized with full notification controls.
  - Play/pause, seek forward/backward from notification
  - Media session integration for headphone/car controls
  - Track metadata and thumbnail in notification
- **Android System Picture-in-Picture**: Native PiP support.
  - Auto-enters PiP when pressing home while video is playing
  - Shows only video player in PiP window (no app UI)
  - Configurable in settings (enable/disable auto-PiP)
- **Audio Selection Supported**: You can now switch between audio tracks when multiple tracks are available (NewPipe Extractor and Piped).
- **Database Migration**: Migrated from Isar to Drift (SQLite) for better reliability and performance.
- **SponsorBlock Integration**: Automatically skip sponsored segments, intros, outros, and more. Configurable categories in settings.
- **Multiple User Profiles**: Create separate profiles with isolated subscriptions, history, and saved videos. Switch instantly between profiles.
- **NewPipe-Compatible Backup/Restore**: Export and import data as NewPipe-compatible ZIP files. Selective import options for subscriptions, history, and saved videos.
- **Deep Linking & Share Intent**: Open YouTube links directly in FluxTube from browsers or share menu. Supports watch URLs, shorts, channels, and @handles.
- **NewPipe Extractor**: Native YouTube extraction without third-party instances. Recommended service for best reliability.
- **Channel Page Tabs**: Browse Videos, Shorts, and Playlists separately on channel pages.
- **Playlist Support**: View and browse YouTube playlists.
- **Search History**: Save and manage search queries with privacy controls.
- **Comment Replies**: Fetch and view nested comment replies (NewPipe backend).

###### Video Player Enhancements

- **Unified MediaKit Player**: Consolidated video player across all backends for consistency.
- **Video Fit Modes**: Choose from Contain, Cover, Fill, Fit Width, or Fit Height.
- **Audio Selection Supported**: Switching audio tracks.
- **Customizable Skip Interval**: Double-tap to skip 5, 10, 15, 30, or 60 seconds.
- **Subtitle Size Settings**: Adjust subtitle size (Small, Medium, Large, Extra Large).
- **Live Stream Support**: Improved handling and UI for live streams.
- **Player Controls Overlay**: Redesigned with better gestures and visual feedback.

###### Settings & Privacy

- **Distraction-Free Mode**: Hide comments and/or related videos from watch screen.
- **Open Links in Browser**: Option to open external links in system browser.
- **Home Feed Mode**: Choose between Auto, Subscriptions Only, or Trending Only.
- **Search History Privacy**: Enable/disable search history saving and visibility.
- **Disable PiP Option**: Turn off picture-in-picture if not needed.
- **Auto-PiP Setting**: Enable/disable automatic PiP when leaving app.

###### Library & Saved Videos

- **Redesigned Library Screen**: Unified interface for saved videos and history.
- **Bulk Selection**: Select multiple videos for batch deletion.
- **Sorting Options**: Sort by date added, title, or duration.
- **Search Within Library**: Find saved videos quickly.
- **Downloads Screen**: View and manage all downloads with type badges (Video/Audio/Video+Audio).

###### Improvements

- **Auto-Check Instances**: Automatic failover when an instance becomes unavailable.
- **Improved Error Handling**: Inline error widgets with retry and instance switching.
- **Better Search UX**: Improved suggestions, fixed shorts thumbnails.
- **Thumbnail Quality**: Higher resolution thumbnails for NewPipe.
- **12 Language Updates**: Updated translations with 80+ new strings.
- **Performance Optimizations**: Faster loading, reduced memory usage.
- **Animation System**: New smooth animations for lists and transitions.
- **Multi-threaded Downloads**: Faster download speeds with CPN parameter optimization.

###### Bug Fixes

- Fixed video player dispose error when navigating away.
- Fixed search suggestions UI glitches.
- Fixed shorts thumbnail aspect ratios.
- Fixed channel navigation issues.
- Fixed comments loading states.
- Fixed video loading lag.
- Fixed player readiness checks and audio track synchronization.
- Fixed multiple shorts playing simultaneously when scrolling.
- Fixed "Like"/"Dislike" showing "-1" when counts unavailable.
- Fixed FlutterJNI crash on app exit.
- Fixed audio as primary source for merging streams.

###### Technical Changes

- Migrated database from Isar to Drift (SQLite).
- Added audio_service for background playback.
- Added native Android PiP via method channel.
- Created stream helpers for all YouTube services (Piped, Invidious, Explode).
- Removed legacy OmniPlayer and iframe player implementations.
- Removed redundant PiP player variants.
- Removed unused code and files (dash_manifest_generator, settings_db).
- Added user preferences tracking infrastructure.
- Updated dependencies (media_kit, drift, freezed, etc.).
- Added Kotlin NewPipe handler for native stream extraction.

###### Note

- Some legacy settings may need to be reconfigured after update.
- Downloads require storage permission on Android.

### v0.8.3

- The signing key was changed to the previous one.

### v0.8.2

- Changed the Piped API to primary.
- Added history listing based on time.
- Added French and Polish languages.
- Minor improvements.

### v0.8.1

- Added Arabic, Japanese and Korean Languages.
- Replaced pip package with custom.
- Adeded Draggable to iFrame pip.
- Added pip disable option.
- pip updated
- Maintain playback position in pip fixed.
- Removed `native_dio_adapter` to remove Cronet.

### v0.8.0

- Added Invidious service.
- Replaced pip package with custom.
- Optimized code.
- Removed unwanted fetching.
- Router fixed
- Default service changed to iFrame
- All the pip modes are draggable except iFrame.
- Default hls changed to false.
- Settings ui package changed to custom for more optimization.

### v0.7.1

- Added explode service.
- Added iFrame service.
- Added more regions.
- Merged Chinese and Portuguese (Brazil).
- Performance optimized.

### v0.7.0

- Added instances selection.
- Added Russian language.
- Added picture in picture support.
- Added shimmer effect.
- Added view on YouTube button for channels.
- Fixed related videos duration issue.
- Fixed #26 issue.

### v0.6.9

- Added Turkish language.
- Added distraction-free section in settings.
- Added option to hide the title when sharing.
- Fixed related videos title issue.

### v0.6.8

- google_fonts replaced with local fonts.
- Added open in YouTube button.
- Added system theme.

### v0.6.7

- Removed cleartextTraffic.
- Reenabled HLS cache.

### v0.6.6

- Added channel on appear on search result.
- Added Channel view screen.
- Added channel videos auto loading on scroll.
- Added Channel view from Comments.
- Minor bug fixes.
- Reply comment bottomsheet dissmiss button removed.

### v0.6.5

- subtitle added
- files organized
- unlimited comments & comments replies added
- unlimited search result scroll added
- bug on search suggession fixed
- tumbnail image cache added

### v0.6.0

- video player changed, `river player -> better player`.
- video saving bug fixed.
- performance optimization.
- dislike button on light theme fixed.
- subtitle configuration 60% completed.

### v0.5.0

- Initial release.
