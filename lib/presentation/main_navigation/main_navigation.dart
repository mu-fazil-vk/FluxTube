import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/animations/animations.dart';
import 'package:fluxtube/core/deep_link_handler.dart';
import 'package:fluxtube/core/player/global_player_controller.dart';
import 'package:fluxtube/core/services/pip_service.dart';
import 'package:fluxtube/core/services/update_checker.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/presentation/main_navigation/main_navigation_layout.dart';
import 'package:fluxtube/presentation/main_navigation/widgets/floating_pill_nav_bar.dart';
import 'package:fluxtube/presentation/main_navigation/widgets/fluxtube_app_bar.dart';
import 'package:fluxtube/presentation/shorts/shorts_tab_page.dart';

import '../home/screen_home.dart';
import '../saved/screen_saved.dart';
import '../subscriptions/screen_subscriptions.dart';

/// Fixed tab indices — Settings is reached via the profile avatar in
/// [FluxTubeAppBar], not a tab, and Downloads/Trending are folded into
/// Library/Home respectively, so there is no longer a variable tab count to
/// track (the pre-redesign version of this file re-indexed tabs at runtime
/// depending on whether the active backend supported Trending).
const _homeIndex = 0;
const _shortsIndex = 1;
const _libraryIndex = 3;

/// Public alias of the Shorts tab's index, so [ShortsTabPage] can tell
/// (via [indexChangeNotifier]) whether it's the currently active tab, to
/// pause its video when the user swipes to another tab instead of letting
/// it keep playing offstage inside the `IndexedStack`.
const shortsTabIndex = _shortsIndex;

ValueNotifier<int> indexChangeNotifier = ValueNotifier(_homeIndex);

/// Notifier for the Library tab's Downloads section sub-tab selection.
/// 0 = Downloading, 1 = Completed, 2 = All
ValueNotifier<int?> downloadsTabNotifier = ValueNotifier(null);

/// Navigate to the Library tab (Downloads now lives there, not its own tab).
/// [downloadsTabIndex] - optional sub-tab (0=Downloading, 1=Completed, 2=All)
void navigateToDownloadsTab({int? downloadsTabIndex}) {
  if (downloadsTabIndex != null) {
    downloadsTabNotifier.value = downloadsTabIndex;
  }
  indexChangeNotifier.value = _libraryIndex;
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  MainNavigationState createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {
  bool _hasShownInstanceFailedSnackbar = false;
  final DeepLinkHandler _deepLinkHandler = DeepLinkHandler();
  final Map<String, Widget> _pageCache = {};

  // Header show/hide is driven by `headerVisibleNotifier` (declared in
  // main_navigation_layout.dart, not here) so tab pages can read it too and
  // collapse the space they reserve for the header in lockstep — see
  // MainNavigationLayout.headerSpacer.

  void _onTabChanged() => headerVisibleNotifier.value = true;

  bool _onContentScroll(ScrollNotification notification) {
    final metrics = notification.metrics;
    // Horizontal rails (category chips, Continue Watching, shorts) must not
    // toggle the header.
    if (metrics.axis != Axis.vertical) return false;
    // At the top there is nothing left to scroll, so no "forward" user scroll
    // ever arrives — without this the header could stay hidden for good.
    if (metrics.pixels <= metrics.minScrollExtent + 8) {
      headerVisibleNotifier.value = true;
      return false;
    }
    if (notification is UserScrollNotification) {
      switch (notification.direction) {
        case ScrollDirection.reverse: // scrolling down -> hide
          headerVisibleNotifier.value = false;
        case ScrollDirection.forward: // scrolling up -> reveal
          headerVisibleNotifier.value = true;
        case ScrollDirection.idle:
          break;
      }
    }
    return false;
  }

  Widget _cachedPage(String key, Widget page) {
    return _pageCache.putIfAbsent(key, () => page);
  }

  List<Widget> _pages() => [
        _cachedPage('home', const ScreenHome()),
        _cachedPage('shorts', const ShortsTabPage()),
        _cachedPage('subscriptions', const ScreenSubscriptions()),
        _cachedPage('library', const ScreenSaved()),
      ];

  List<PillNavItem> _tabItems(S locals) => [
        PillNavItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: locals.home,
        ),
        PillNavItem(
          icon: Icons.bolt_outlined,
          activeIcon: Icons.bolt,
          label: locals.shorts,
        ),
        PillNavItem(
          icon: Icons.subscriptions_outlined,
          activeIcon: Icons.subscriptions,
          label: locals.subscriptions,
        ),
        PillNavItem(
          icon: Icons.video_library_outlined,
          activeIcon: Icons.video_library,
          label: locals.library,
        ),
      ];

  @override
  void initState() {
    super.initState();
    indexChangeNotifier.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _deepLinkHandler.init(context);
      UpdateChecker().checkOnStartup(context);
    });
  }

  @override
  void dispose() {
    indexChangeNotifier.removeListener(_onTabChanged);
    _deepLinkHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locals = S.of(context);
    final pages = _pages();
    final items = _tabItems(locals);

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
          final safeIndex = index.clamp(0, pages.length - 1);
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
              extendBody: true,
              body: Stack(
                children: [
                  NotificationListener<ScrollNotification>(
                    onNotification: _onContentScroll,
                    child: _LazyIndexedStack(index: safeIndex, children: pages),
                  ),
                  // Only Home has the floating wordmark/search/profile bar —
                  // every other tab already carries its own header UI
                  // (Subscriptions/Library have their own search rows and
                  // app bars; Shorts is full-bleed with its own overlay).
                  if (safeIndex == _homeIndex)
                    Align(
                      alignment: Alignment.topCenter,
                      child: ValueListenableBuilder<bool>(
                        valueListenable: headerVisibleNotifier,
                        builder: (context, visible, child) => AnimatedSlide(
                          offset: visible ? Offset.zero : const Offset(0, -1),
                          duration: AppAnimations.medium,
                          curve: AppAnimations.defaultCurve,
                          child: AnimatedOpacity(
                            opacity: visible ? 1 : 0,
                            duration: AppAnimations.medium,
                            curve: AppAnimations.defaultCurve,
                            child: child,
                          ),
                        ),
                        child: const FluxTubeAppBar(),
                      ),
                    ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: FloatingPillNavBar(
                      items: items,
                      currentIndex: safeIndex,
                      onTap: (i) => indexChangeNotifier.value = i,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
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
