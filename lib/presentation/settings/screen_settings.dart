import 'package:flutter/material.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/presentation/settings/widgets/profile_header.dart';

import 'widgets/widgets.dart';

class ScreenSettings extends StatelessWidget {
  const ScreenSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final locals = S.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      // Settings is reached by pushing this screen from the header avatar
      // (it's no longer a bottom-nav tab), so — unlike the tab pages — it
      // needs a normal AppBar with the back button Navigator provides by
      // default, rather than the tab pages' floating chrome.
      appBar: AppBar(
        title: Text(locals.settings),
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SettingsProfileHeader(),
              AppSpacing.height24,
              const CommonSettingsSection(),
              AppSpacing.height24,
              const ProfilesSettingsSection(),
              AppSpacing.height24,
              const DistractionFreeSettingsSection(),
              AppSpacing.height24,
              const VideoSettingsSection(),
              AppSpacing.height24,
              const PlaybackSettingsSection(),
              AppSpacing.height24,
              const SponsorBlockSettingsSection(),
              AppSpacing.height24,
              const BackupSettingsSection(),
              AppSpacing.height24,
              const AboutSection(),
            ],
          ),
        ),
      ),
    );
  }
}
