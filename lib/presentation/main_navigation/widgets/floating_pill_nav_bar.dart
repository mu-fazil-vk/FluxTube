import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fluxtube/core/animations/animations.dart';
import 'package:fluxtube/core/constants.dart';

class PillNavItem {
  const PillNavItem(
      {required this.icon, required this.activeIcon, required this.label});

  final IconData icon;
  final IconData activeIcon;

  /// Not shown as visible text (the pill is icon-only) — used for the
  /// per-item [Tooltip]/[Semantics] label instead.
  final String label;
}

/// The "Floating Pill Navigation" component from the Kinetic Obsidian design
/// system: a small, icon-only glass dock that floats above content, sized to
/// its content rather than stretching edge-to-edge like a conventional
/// bottom bar.
class FloatingPillNavBar extends StatelessWidget {
  const FloatingPillNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<PillNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: AppSpacing.xxl + MediaQuery.of(context).padding.bottom,
      ),
      // No inner Align/Center here — the outer Align(bottomCenter) in
      // main_navigation.dart already centers this horizontally. An inner
      // Center would expand to fill all available loose space first (up to
      // the Stack's full height) before centering within itself, which pulls
      // the whole pill to screen-center instead of the bottom.
      child: ClipRRect(
        borderRadius: AppRadius.borderFull,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer.withValues(alpha: 0.55),
              borderRadius: AppRadius.borderFull,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.14),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < items.length; i++)
                  _PillNavItemWidget(
                    item: items[i],
                    isActive: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PillNavItemWidget extends StatelessWidget {
  const _PillNavItemWidget({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final PillNavItem item;
  final bool isActive;
  final VoidCallback onTap;

  static const double _tapTargetSize = 48;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isActive
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurfaceVariant;

    return Tooltip(
      message: item.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderFull,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: AnimatedContainer(
            duration: AppAnimations.medium,
            curve: AppAnimations.bounceCurve,
            width: _tapTargetSize,
            height: _tapTargetSize,
            decoration: BoxDecoration(
              color: isActive
                  ? colorScheme.primaryContainer.withValues(alpha: 0.9)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: AnimatedScale(
              scale: isActive ? 1.1 : 1.0,
              duration: AppAnimations.medium,
              curve: AppAnimations.bounceCurve,
              child: AnimatedSwitcher(
                duration: AppAnimations.fast,
                child: Icon(
                  isActive ? item.activeIcon : item.icon,
                  key: ValueKey(isActive),
                  color: color,
                  size: AppIconSize.md,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
