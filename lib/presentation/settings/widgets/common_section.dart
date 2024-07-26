import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:fluxtube/application/settings/settings_bloc.dart';
import 'package:fluxtube/core/model/language_model.dart';
import 'package:fluxtube/core/model/region_model.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:go_router/go_router.dart';

final _themeModes = [
  const DropdownMenuItem(
    value: "system",
    child: Text("System"),
  ),
  const DropdownMenuItem(
    value: "light",
    child: Text("Light"),
  ),
  const DropdownMenuItem(
    value: "dark",
    child: Text("Dark"),
  ),
];

SettingsSection commonSettingsSection(S locals, BuildContext context,
    LanguageModel language, RegionModel region, SettingsState state) {
  return SettingsSection(
    title: Text(
      locals.commonSettingsTitle,
      style: Theme.of(context).textTheme.bodyMedium,
    ),
    tiles: [
      SettingsTile(
        title: Text(locals.language),
        description: Text(language.name),
        leading: const Icon(Icons.language),
        onPressed: (BuildContext ctx) => context.go('/languages'),
      ),
      SettingsTile(
        title: Text(locals.region),
        description: Text(region.name),
        leading: const Icon(Icons.flag),
        onPressed: (ctx) => context.go('/regions'),
      ),
      SettingsTile(
        title: Text(locals.theme),
        leading: const Icon(Icons.dark_mode_rounded),
        trailing: DropdownButton(
            value: state.themeMode,
            items: _themeModes,
            onChanged: (themeMode) => BlocProvider.of<SettingsBloc>(context)
                .add(SettingsEvent.changeTheme(
                    themeMode: themeMode.toString()))),
      ),
    ],
  );
}
