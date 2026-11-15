import 'package:flutter/material.dart';
import 'package:fluxtube/core/animations/animations.dart';
import 'package:fluxtube/core/constants.dart';

/// Whether the floating header should be visible. [MainNavigation] toggles
/// this based on scroll direction (and resets it on every tab switch); the
/// header itself animates in/out from it, and [MainNavigationLayout.headerSpacer]
/// reads it too so the space a tab page reserves for the header collapses in
/// lockstep instead of leaving a static empty gap once the header has slid
/// away. Lives here (rather than on `MainNavigationState`) so tab pages —
/// which already depend on this file for layout metrics — can read it
/// without depending on `main_navigation.dart` itself.
final ValueNotifier<bool> headerVisibleNotifier = ValueNotifier(true);

/// Layout metrics for the floating chrome in [MainNavigation].
///
/// The header and nav bar are `Stack` overlays that float above scrolling
/// content (not `Scaffold.appBar` / `bottomNavigationBar` slots), so every tab
/// page must pad its scrollables by these amounts to keep content clear of
/// the glass chrome.
abstract final class MainNavigationLayout {
  /// Height of the [FluxTubeAppBar] content row (excluding the safe area).
  static const double appBarHeight = 64;

  /// Total space a tab page must reserve at the top: safe area + header.
  static EdgeInsets headerPadding(BuildContext context) =>
      EdgeInsets.only(top: MediaQuery.paddingOf(context).top + appBarHeight);

  /// An animated stand-in for [headerPadding]'s top inset. Use this instead
  /// of a static `SizedBox`/`Padding` wherever a tab page reserves space for
  /// the floating header, so that space collapses/expands in sync with the
  /// header's own show/hide animation — otherwise the header slides away but
  /// the blank space it left behind just sits there unfilled.
  static Widget headerSpacer(BuildContext context) {
    final safeTop = MediaQuery.paddingOf(context).top;
    return ValueListenableBuilder<bool>(
      valueListenable: headerVisibleNotifier,
      builder: (context, visible, _) => AnimatedContainer(
        duration: AppAnimations.medium,
        curve: AppAnimations.defaultCurve,
        height: visible ? safeTop + appBarHeight : safeTop,
      ),
    );
  }

  /// Bottom clearance a tab page's scrollable should reserve.
  ///
  /// Deliberately *not* the nav pill's full height + gap: the pill is a
  /// small, content-width, glass dock now (not a full-width bar), so most of
  /// the screen's width has nothing floating over it near the bottom at all.
  /// Reserving the pill's full footprint as blank padding left a flat, dead
  /// strip of plain background between the content and the pill's margins —
  /// content should instead flow almost to the real bottom edge, with only
  /// the narrow pill itself gently overlapping the last sliver (visible
  /// through its blur), matching how floating docks look in the mock.
  static EdgeInsets navPadding(BuildContext context) => EdgeInsets.only(
        bottom: AppSpacing.lg + MediaQuery.paddingOf(context).bottom,
      );

  /// Combined top + bottom padding for a full scrollable tab page.
  static EdgeInsets pagePadding(BuildContext context) =>
      headerPadding(context) + navPadding(context);
}
