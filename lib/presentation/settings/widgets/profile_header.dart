import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/animations/animations.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/generated/l10n.dart';

/// Replaces the Stitch mock's fake account header (name/handle/"Premium
/// Plus" badge/watch-time & ads-skipped stats/"Sign Out") with what actually
/// exists: FluxTube has no accounts, only local on-device profiles
/// (`SettingsState.currentProfile`/`profiles`). Full add/rename/delete
/// management already lives in [ProfilesSettingsSection] further down this
/// screen — this header is a quick-glance summary plus a fast switcher, not
/// a duplicate of that management UI.
class SettingsProfileHeader extends StatelessWidget {
  const SettingsProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locals = S.of(context);

    return BlocBuilder<SettingsBloc, SettingsState>(
      buildWhen: (previous, current) =>
          previous.currentProfile != current.currentProfile ||
          previous.profiles != current.profiles,
      builder: (context, state) {
        final hasMultipleProfiles = state.profiles.length > 1;

        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: scheme.surfaceContainer,
            borderRadius: AppRadius.borderLg,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: scheme.primary,
                child: Icon(Icons.person, size: 30, color: scheme.onPrimary),
              ),
              AppSpacing.width16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.currentProfile,
                      style: theme.textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSpacing.height4,
                    Text(
                      locals.profilesDescription,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasMultipleProfiles)
                ScaleTap(
                  enableHaptic: false,
                  onTap: () => _showQuickSwitcher(context, state),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHigh,
                      borderRadius: AppRadius.borderFull,
                    ),
                    child: Text(
                      locals.switchProfile,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showQuickSwitcher(BuildContext context, SettingsState state) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locals = S.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: scheme.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.topLg),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: scheme.outlineVariant,
                borderRadius: AppRadius.borderFull,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  locals.switchProfile,
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            AppSpacing.height12,
            for (final profile in state.profiles)
              ListTile(
                leading: Icon(
                  Icons.person,
                  color: profile == state.currentProfile ? scheme.primary : scheme.onSurfaceVariant,
                ),
                title: Text(profile),
                trailing: profile == state.currentProfile
                    ? Icon(Icons.check, color: scheme.primary)
                    : null,
                onTap: () {
                  if (profile != state.currentProfile) {
                    // Mirrors ProfilesSettingsSection's switch handler: the
                    // profile switch itself doesn't reload per-profile data,
                    // so Subscriptions/Saved have to be told explicitly or
                    // they'd keep showing the previous profile's data.
                    context
                        .read<SettingsBloc>()
                        .add(SettingsEvent.switchProfile(profileName: profile));
                    context
                        .read<SubscribeBloc>()
                        .add(SubscribeEvent.getAllSubscribeList(profileName: profile));
                    context
                        .read<SavedBloc>()
                        .add(SavedEvent.getAllVideoInfoList(profileName: profile));
                  }
                  Navigator.pop(sheetContext);
                },
              ),
            AppSpacing.height16,
          ],
        ),
      ),
    );
  }
}
