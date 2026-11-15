import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/settings/settings_bloc.dart';
import 'package:fluxtube/core/enums.dart';
import 'package:fluxtube/core/model/language_model.dart';
import 'package:fluxtube/core/model/region_model.dart';
import 'package:fluxtube/core/regions.dart';
import 'package:fluxtube/core/locals.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/presentation/settings/widgets/new_video_notification_tile.dart';
import 'package:fluxtube/presentation/settings/widgets/settings_components.dart';
import 'package:go_router/go_router.dart';

class CommonSettingsSection extends StatelessWidget {
  const CommonSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final locals = S.of(context);
    final scheme = Theme.of(context).colorScheme;

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final language = languages.firstWhere(
          (name) => name.code == state.defaultLanguage,
          orElse: () => LanguageModel(name: locals.unknown, code: locals.unknown),
        );
        final region = regions.firstWhere(
          (name) => name.code == state.defaultRegion,
          orElse: () => RegionModel(name: locals.unknown, code: locals.unknown),
        );

        return SettingsSectionCard(
          title: locals.commonSettingsTitle,
          children: [
            SettingsActionTile(
              icon: Icons.language,
              title: locals.language,
              subtitle: language.name,
              onTap: () => context.goNamed('languages'),
            ),
            SettingsActionTile(
              icon: Icons.flag_outlined,
              title: locals.region,
              subtitle: region.name,
              onTap: () => context.goNamed('regions'),
            ),
            // Only relevant for services that use them (not NewPipe).
            if (state.ytService != YouTubeServices.newpipe.name)
              SettingsActionTile(
                icon: Icons.web_stories_outlined,
                title: locals.instances,
                subtitle: state.instance,
                onTap: () => context.goNamed('instances'),
              ),
            SettingsActionTile(
              icon: Icons.dark_mode_outlined,
              title: locals.theme,
              trailing: DropdownButton<String>(
                value: state.themeMode,
                underline: const SizedBox.shrink(),
                dropdownColor: scheme.surfaceContainerHigh,
                items: _themeModes(locals),
                onChanged: (themeMode) => context
                    .read<SettingsBloc>()
                    .add(SettingsEvent.changeTheme(themeMode: themeMode.toString())),
              ),
            ),
            const NewVideoNotificationTile(),
          ],
        );
      },
    );
  }

  List<DropdownMenuItem<String>> _themeModes(S locals) => [
        DropdownMenuItem(value: "system", child: Text(locals.themeSystem)),
        DropdownMenuItem(value: "light", child: Text(locals.themeLight)),
        DropdownMenuItem(value: "dark", child: Text(locals.themeDark)),
        DropdownMenuItem(value: "oled", child: Text(locals.themeOled)),
        DropdownMenuItem(value: "dynamic", child: Text(locals.themeDynamic)),
      ];
}
