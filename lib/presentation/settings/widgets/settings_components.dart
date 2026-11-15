import 'package:flutter/material.dart';
import 'package:fluxtube/core/animations/animations.dart';
import 'package:fluxtube/core/constants.dart';

/// Shared building blocks for the Settings screen, matching the Kinetic
/// Obsidian design system's "surface-container card" treatment (see
/// REDESIGN.md) — a titled section is a rounded `surfaceContainer` card
/// housing a column of icon-leading tiles, replacing the old flat
/// `ListTile`-in-a-`Column` layout.
class SettingsSectionCard extends StatelessWidget {
  const SettingsSectionCard({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.sm),
          child: Text(
            title,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: AppRadius.borderLg,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: AppSpacing.lg + AppIconSize.xl + AppSpacing.md,
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// A leading icon in a soft circular badge, matching the mock's row style
/// (e.g. the SponsorBlock / Background Play rows in `settings_profiles`).
class _SettingsLeadingIcon extends StatelessWidget {
  const _SettingsLeadingIcon({required this.icon, this.color});

  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: AppIconSize.xl,
      height: AppIconSize.xl,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: AppIconSize.sm, color: color ?? scheme.onSurfaceVariant),
    );
  }
}

/// A tappable settings row — icon, title, optional subtitle, optional
/// trailing widget (chevron by default when [onTap] is set).
class SettingsActionTile extends StatelessWidget {
  const SettingsActionTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.iconColor,
    this.titleColor,
    this.onTap,
    this.onLongPress,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color? iconColor;
  final Color? titleColor;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ScaleTap(
      enableHaptic: false,
      scaleDown: 0.99,
      // Rows whose control is a trailing widget (dropdown, switch) have no
      // row action of their own; don't animate them as if they did.
      enabled: onTap != null || onLongPress != null,
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            _SettingsLeadingIcon(icon: icon, color: iconColor),
            AppSpacing.width12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? scheme.onSurface,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty)
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant, size: AppIconSize.sm),
          ],
        ),
      ),
    );
  }
}

/// A settings row with a trailing [Switch] instead of a chevron/arrow.
class SettingsSwitchTile extends StatelessWidget {
  const SettingsSwitchTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SettingsActionTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      onTap: () => onChanged(!value),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: scheme.onPrimary,
        activeTrackColor: scheme.primary,
      ),
    );
  }
}
