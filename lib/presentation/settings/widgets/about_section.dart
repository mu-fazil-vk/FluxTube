import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:fluxtube/application/settings/settings_bloc.dart';
import 'package:fluxtube/core/app_info.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/presentation/settings/functions/launch_url.dart';
import 'package:go_router/go_router.dart';

SettingsSection aboutSection(
    S locals, BuildContext context, SettingsState state) {
  return SettingsSection(
    title: Text(
      locals.about,
      style: Theme.of(context).textTheme.bodyMedium,
    ),
    tiles: [
      SettingsTile(
        title: Text(locals.developer),
        description: Text(AppInfo.developerInfos.first.name),
        leading: const Icon(Icons.code),
        trailing: const Icon(CupertinoIcons.chat_bubble_2),
        onPressed: (BuildContext context) =>
            urlLaunch(AppInfo.developerInfos.first.url),
      ),
      SettingsTile(
        title: Text(locals.translators),
        leading: const Icon(Icons.translate_rounded),
        onPressed: (BuildContext ctx) => context.goNamed('translators'),
      ),
      SettingsTile(
        title: Text(locals.version),
        description: Text(state.version ?? ""),
        leading: const Icon(CupertinoIcons.info),
        onPressed: (BuildContext context) {},
      ),
    ],
  );
}
