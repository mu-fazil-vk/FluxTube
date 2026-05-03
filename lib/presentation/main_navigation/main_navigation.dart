import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:fluxtube/core/deep_link_handler.dart';
import 'package:fluxtube/core/enums.dart';
import 'package:fluxtube/core/player/global_player_controller.dart';
import 'package:fluxtube/core/services/pip_service.dart';
import 'package:fluxtube/generated/l10n.dart';

import '../download/screen_downloads.dart';
import '../home/screen_home.dart';
import '../saved/screen_saved.dart';
import '../settings/screen_settings.dart';
import '../subscriptions/screen_subscriptions.dart';
import '../trending/screen_trending.dart';

ValueNotifier<int> indexChangeNotifier = ValueNotifier(0);

/// Notifier for downloads screen tab selection
/// 0 = Downloading, 1 = Completed, 2 = All
ValueNotifier<int?> downloadsTabNotifier = ValueNotifier(null);

/// Pending navigation info
String? _pendingNavigation;
int? _pendingDownloadsTab;

/// Navigate to the Downloads tab
/// [downloadsTabIndex] - optional tab index within Downloads screen (0=Downloading, 1=Completed, 2=All)
void navigateToDownloadsTab({int? downloadsTabIndex}) {
  _pendingNavigation = 'downloads';
  _pendingDownloadsTab = downloadsTabIndex;
  // Set the downloads tab notifier if specified
  if (downloadsTabIndex != null) {
    downloadsTabNotifier.value = downloadsTabIndex;
  }
  // Set index to a known downloads position (will be adjusted by MainNavigation if needed)
  // Downloads is at index 4 with trending, index 3 without
  // Use index 4, the MainNavigation will handle pending navigation and find correct index
  indexChangeNotifier.value = 4;
}

/// Get and clear pending navigation target
String? consumePendingNavigation() {
  final target = _pendingNavigation;
  _pendingNavigation = null;
  return target;
}

/// Get and clear pending downloads tab index
int? consumePendingDownloadsTab() {
  final tab = _pendingDownloadsTab;
  _pendingDownloadsTab = null;
  return tab;
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  MainNavigationState createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {
  bool _hasShownInstanceFailedSnackbar = false;
  final DeepLinkHandler _deepLinkHandler = DeepLinkHandler();
  bool? _previousShowTrending;
  final Map<String, Widget> _pageCache = {};

  List<Widget> _getPages(bool showTrending) {
    if (showTrending) {
      return [
        _cachedPage('home', const ScreenHome()),
        _cachedPage('trending', const ScreenTrending()),
        _cachedPage('subscriptions', const ScreenSubscriptions()),
        _cachedPage('saved', const ScreenSaved()),
        _cachedPage('downloads', const ScreenDownloads()),
        _cachedPage('settings', const ScreenSettings()),
      ];
    } else {
      return [
        _cachedPage('home', const ScreenHome()),
        _cachedPage('subscriptions', const ScreenSubscriptions()),
        _cachedPage('saved', const ScreenSaved()),
        _cachedPage('downloads', const ScreenDownloads()),
        _cachedPage('settings', const ScreenSettings()),
      ];
    }
  }

  Widget _cachedPage(String key, Widget page) {
    return _pageCache.putIfAbsent(key, () => page);
  }

  List<TabItem> _getTabItems(S locals, bool showTrending) {
    if (showTrending) {
      return [
        TabItem(
            icon: CupertinoIcons.house_fill, title: locals.home, key: "home"),
        TabItem(
            icon: CupertinoIcons.flame_fill,
            title: locals.trending,
            key: "trending"),
        TabItem(
            icon: CupertinoIcons.person_2_fill,
            title: locals.subscriptions,
            key: "subscriptions"),
        TabItem(
            icon: CupertinoIcons.bookmark_fill,
            title: locals.saved,
            key: "saved"),
        TabItem(
            icon: CupertinoIcons.arrow_down_circle_fill,
            title: locals.downloads,
            key: "downloads"),
        TabItem(
            icon: CupertinoIcons.settings,
            title: locals.settings,
            key: "settings"),
      ];
    } else {
      return [
        TabItem(
            icon: CupertinoIcons.house_fill, title: locals.home, key: "home"),
        TabItem(
            icon: CupertinoIcons.person_2_fill,
            title: locals.subscriptions,
            key: "subscriptions"),
        TabItem(
            icon: CupertinoIcons.bookmark_fill,
            title: locals.saved,
            key: "saved"),
        TabItem(
            icon: CupertinoIcons.arrow_down_circle_fill,
            title: locals.downloads,
            key: "downloads"),
        TabItem(
            icon: CupertinoIcons.settings,
            title: locals.settings,
            key: "settings"),
      ];
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _deepLinkHandler.init(context);
    });
  }

  @override
  void dispose() {
    _deepLinkHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locals = S.of(context);

    return BlocBuilder<SettingsBloc, SettingsState>(
      buildWhen: (previous, current) =>
          previous.ytService != current.ytService ||
          previous.userInstanceFailed != current.userInstanceFailed,
      builder: (context, settingsState) {
        // Disable trending tab for NewPipe Extractor service
        final showTrending =
            settingsState.ytService != YouTubeServices.newpipe.name;
        final pages = _getPages(showTrending);
        final items = _getTabItems(locals, showTrending);

        final maxIndex = pages.length - 1;

        // Adjust index when transitioning between services with different tab counts
        if (_previousShowTrending != null &&
            _previousShowTrending != showTrending) {
          final currentIndex = indexChangeNotifier.value;
          int newIndex;

          if (showTrending && !_previousShowTrending!) {
            // Switching FROM NewPipe (4 tabs) TO other service (5 tabs)
            // Indices after Home need to shift up by 1 to account for Trending tab
            // 0 (Home) -> 0 (Home)
            // 1 (Subscriptions) -> 2 (Subscriptions)
            // 2 (Saved) -> 3 (Saved)
            // 3 (Settings) -> 4 (Settings)
            newIndex = currentIndex == 0 ? 0 : currentIndex + 1;
          } else {
            // Switching FROM other service (5 tabs) TO NewPipe (4 tabs)
            // Indices after Trending need to shift down by 1
            // 0 (Home) -> 0 (Home)
            // 1 (Trending) -> 0 (Home) - Trending doesn't exist, go to Home
            // 2 (Subscriptions) -> 1 (Subscriptions)
            // 3 (Saved) -> 2 (Saved)
            // 4 (Settings) -> 3 (Settings)
            if (currentIndex <= 1) {
              newIndex = 0;
            } else {
              newIndex = currentIndex - 1;
            }
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            indexChangeNotifier.value = newIndex;
          });
        }
        _previousShowTrending = showTrending;

        return BlocListener<SettingsBloc, SettingsState>(
          listenWhen: (previous, current) =>
              !previous.userInstanceFailed && current.userInstanceFailed,
          listener: (context, state) {
            if (state.userInstanceFailed && !_hasShownInstanceFailedSnackbar) {
              _hasShownInstanceFailedSnackbar = true;
              final failedName =
                  state.failedInstanceName ?? 'Your preferred instance';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '$failedName is not responding. Switched to a working instance.',
                  ),
                  duration: const Duration(seconds: 4),
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: 'OK',
                    onPressed: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    },
                  ),
                ),
              );
            }
          },
          child: ValueListenableBuilder(
            valueListenable: indexChangeNotifier,
            builder: (BuildContext context, int index, Widget? _) {
              // Check for pending navigation from notification tap
              final pendingNav = consumePendingNavigation();
              if (pendingNav == 'downloads') {
                // Find downloads tab index by key
                final downloadsIndex =
                    items.indexWhere((item) => item.key == 'downloads');
                if (downloadsIndex >= 0) {
                  // Get the pending downloads tab before navigating
                  final pendingDownloadsTab = consumePendingDownloadsTab();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    indexChangeNotifier.value = downloadsIndex;
                    // Set the downloads tab after navigation
                    if (pendingDownloadsTab != null) {
                      downloadsTabNotifier.value = pendingDownloadsTab;
                    }
                  });
                }
              }

              // Ensure index is within bounds
              final safeIndex = index.clamp(0, maxIndex);
              // Update the notifier if index was out of bounds (e.g., when trending tab is removed)
              if (index != safeIndex) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  indexChangeNotifier.value = safeIndex;
                });
              }
              return PopScope(
                canPop: false,
                onPopInvokedWithResult: (didPop, _) async {
                  if (didPop) return;
                  final watchState = context.read<WatchBloc>().state;
                  if (watchState.isPipEnabled &&
                      watchState.selectedVideoBasicDetails != null) {
                    final pipService = PipService();
                    await pipService.setVideoPlaying(true);
                    await pipService.setAspectRatio(16, 9);
                    final entered = await pipService.enterPipMode();
                    if (entered) return;
                  }
                  // Stop the player before exiting to prevent FlutterJNI crash
                  final globalPlayer = GlobalPlayerController();
                  if (globalPlayer.hasActivePlayer) {
                    globalPlayer.disposePlayer();
                    // Small delay to ensure player is fully stopped
                    await Future.delayed(const Duration(milliseconds: 100));
                  }
                  // Exit the app
                  SystemNavigator.pop();
                },
                child: Scaffold(
                  body: SafeArea(
                    child: _LazyIndexedStack(
                      index: safeIndex,
                      children: pages,
                    ),
                  ),
                  bottomNavigationBar: BottomBarSalomon(
                    items: items,
                    top: 25,
                    bottom: 25,
                    iconSize: 26,
                    heightItem: 50,
                    backgroundColor: kTransparentColor,
                    color: kGreyColor!,
                    colorSelected: kRedColor,
                    backgroundSelected: kGreyOpacityColor!,
                    indexSelected: safeIndex,
                    titleStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      overflow: TextOverflow.ellipsis,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    onTap: (int index) => indexChangeNotifier.value = index,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _LazyIndexedStack extends StatefulWidget {
  const _LazyIndexedStack({
    required this.index,
    required this.children,
  });

  final int index;
  final List<Widget> children;

  @override
  State<_LazyIndexedStack> createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<_LazyIndexedStack> {
  late List<bool> _built;

  @override
  void initState() {
    super.initState();
    _built = List<bool>.filled(widget.children.length, false);
    _built[widget.index] = true;
  }

  @override
  void didUpdateWidget(covariant _LazyIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_built.length != widget.children.length) {
      _built = List<bool>.generate(
        widget.children.length,
        (index) => index < oldWidget.children.length && index < _built.length
            ? _built[index]
            : false,
      );
    }
    _built[widget.index] = true;
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.index,
      children: [
        for (var i = 0; i < widget.children.length; i++)
          _built[i] ? widget.children[i] : const SizedBox.shrink(),
      ],
    );
  }
}
