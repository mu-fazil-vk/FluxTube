import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:fluxtube/core/app_info.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:fluxtube/core/locals.dart';
import 'package:fluxtube/core/model/language_model.dart';
import 'package:fluxtube/core/model/region_model.dart';
import 'package:fluxtube/core/regions.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/presentation/settings/functions/launch_url.dart';
import 'package:go_router/go_router.dart';

import '../../application/settings/settings_bloc.dart';
import '../../widgets/custom_app_bar.dart';

class ScreenSettings extends StatelessWidget {
  ScreenSettings({super.key});

  final _qualities = [
    const DropdownMenuItem(
      value: "144p",
      child: Text("144p"),
    ),
    const DropdownMenuItem(
      value: "240p",
      child: Text("240p"),
    ),
    const DropdownMenuItem(
      value: "360p",
      child: Text("360p"),
    ),
    const DropdownMenuItem(
      value: "480p",
      child: Text("480p"),
    ),
    const DropdownMenuItem(
      value: "720p",
      child: Text("720p"),
    ),
    const DropdownMenuItem(
      value: "1080p",
      child: Text("1080p"),
    ),
    const DropdownMenuItem(
      value: "1440p",
      child: Text("1440p"),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final locals = S.of(context);
    BlocProvider.of<SettingsBloc>(context)
        .add(SettingsEvent.initializeSettings());
    return SafeArea(
        child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  CustomAppBar(
                    title: locals.settings,
                  )
                ],
            body: BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, state) {
                // get language name by using language code
                final language = languages.firstWhere(
                  (name) => name.code == state.defaultLanguage,
                  orElse: () =>
                      LanguageModel(name: locals.unknown, code: locals.unknown),
                );
                // get region name by using region code
                final region = regions.firstWhere(
                  (name) => name.code == state.defaultRegion,
                  orElse: () =>
                      RegionModel(name: locals.unknown, code: locals.unknown),
                );
                return SettingsList(
                  lightTheme: const SettingsThemeData(
                      settingsListBackground: kWhiteColor),
                  darkTheme:
                      SettingsThemeData(settingsListBackground: kDarkColor),
                  sections: [
                    // COMMON SETTINGS
                    SettingsSection(
                      title: Text(
                        locals.commonSettingsTitle,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      tiles: [
                        SettingsTile(
                          title: Text(locals.language),
                          description: Text(language.name),
                          leading: const Icon(Icons.language),
                          onPressed: (BuildContext ctx) =>
                              context.go('/languages'),
                        ),
                        SettingsTile(
                          title: Text(locals.region),
                          description: Text(region.name),
                          leading: const Icon(Icons.flag),
                          onPressed: (ctx) => context.go('/regions'),
                        ),
                        SettingsTile.switchTile(
                          initialValue: state.isDarkTheme,
                          title: Text(locals.theme),
                          leading: const Icon(Icons.dark_mode_rounded),
                          onToggle: (_) {
                            BlocProvider.of<SettingsBloc>(context)
                                .add(SettingsEvent.toggleTheme());
                          },
                        ),
                      ],
                    ),

                    // VIDEO SETTINGS
                    SettingsSection(
                      title: Text(
                        locals.video,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      tiles: [
                        SettingsTile(
                          title: Text(locals.defaultQuality),
                          leading: const Icon(Icons.hd_sharp),
                          trailing: DropdownButton(
                              value: state.defaultQuality,
                              items: _qualities,
                              onChanged: (quality) =>
                                  BlocProvider.of<SettingsBloc>(context).add(
                                      SettingsEvent.getDefaultQuality(
                                          quality: quality.toString()))),
                        ),
                        SettingsTile.switchTile(
                          initialValue: state.isHlsPlayer,
                          title: Text(locals.hlsPlayer),
                          description: Text(locals.enableHlsPlayerDescription),
                          leading: const Icon(CupertinoIcons.play),
                          onToggle: (_) {
                            BlocProvider.of<SettingsBloc>(context)
                                .add(SettingsEvent.toggleHlsPlayer());
                          },
                        ),
                        SettingsTile.switchTile(
                          initialValue: !state.isHistoryVisible,
                          title: Text(locals.history),
                          description: Text(locals.disableVideoHistory),
                          leading: const Icon(Icons.history),
                          onToggle: (_) {
                            BlocProvider.of<SettingsBloc>(context)
                                .add(SettingsEvent.toggleHistoryVisibility());
                          },
                        ),
                        SettingsTile.switchTile(
                          initialValue: state.isDislikeVisible,
                          title: Text(locals.retrieveDislikes),
                          description: Text(locals.retrieveDislikeCounts),
                          leading: const Icon(CupertinoIcons.hand_thumbsdown),
                          onToggle: (_) {
                            BlocProvider.of<SettingsBloc>(context)
                                .add(SettingsEvent.toggleDislikeVisibility());
                          },
                        ),
                      ],
                    ),
                    // ABOUT SECTION
                    SettingsSection(
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
                          onPressed: (BuildContext ctx) =>
                              context.go('/translators'),
                        ),
                        SettingsTile(
                          title: Text(locals.version),
                          description: Text(state.version ?? ""),
                          leading: const Icon(CupertinoIcons.info),
                          onPressed: (BuildContext context) {},
                        ),
                      ],
                    ),
                  ],
                );
              },
            )));
  }
}
