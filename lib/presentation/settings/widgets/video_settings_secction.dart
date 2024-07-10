import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:fluxtube/application/settings/settings_bloc.dart';
import 'package:fluxtube/generated/l10n.dart';

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
  
SettingsSection videoSettingsSection(
      S locals, BuildContext context, SettingsState state) {
    return SettingsSection(
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
              onChanged: (quality) => BlocProvider.of<SettingsBloc>(context)
                  .add(SettingsEvent.getDefaultQuality(
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
    );
  }