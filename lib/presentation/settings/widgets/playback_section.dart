import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/settings/settings_bloc.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/presentation/settings/widgets/settings_components.dart';

class PlaybackSettingsSection extends StatelessWidget {
  const PlaybackSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final locals = S.of(context);
    return BlocBuilder<SettingsBloc, SettingsState>(
      buildWhen: (previous, current) =>
          previous.isAudioFocusEnabled != current.isAudioFocusEnabled ||
          previous.openLinksInBrowser != current.openLinksInBrowser,
      builder: (context, state) {
        return SettingsSectionCard(
          title: locals.audioFocus,
          children: [
            SettingsSwitchTile(
              icon: Icons.phone_paused_outlined,
              title: locals.pauseOnCall,
              subtitle: locals.audioFocusDescription,
              value: state.isAudioFocusEnabled,
              onChanged: (_) => context
                  .read<SettingsBloc>()
                  .add(SettingsEvent.toggleAudioFocus()),
            ),
            SettingsSwitchTile(
              icon: Icons.open_in_browser_outlined,
              title: locals.openInBrowser,
              subtitle: locals.openLinksExternally,
              value: state.openLinksInBrowser,
              onChanged: (_) => context
                  .read<SettingsBloc>()
                  .add(SettingsEvent.toggleOpenLinksInBrowser()),
            ),
          ],
        );
      },
    );
  }
}
