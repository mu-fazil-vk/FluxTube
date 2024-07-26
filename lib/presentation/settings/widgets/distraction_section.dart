import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:fluxtube/application/settings/settings_bloc.dart';
import 'package:fluxtube/generated/l10n.dart';

SettingsSection distractionFreeSettingsSection(
    S locals, BuildContext context, SettingsState state) {
  return SettingsSection(
    title: Text(
      locals.distractionFree,
      style: Theme.of(context).textTheme.bodyMedium,
    ),
    tiles: [
      SettingsTile.switchTile(
        initialValue: state.isHideComments,
        title: Text(locals.hideComments),
        description: Text(locals.hideCommentsButtonFromWatchScreen),
        leading: const Icon(CupertinoIcons.bubble_left_bubble_right_fill),
        onToggle: (_) {
          BlocProvider.of<SettingsBloc>(context)
              .add(SettingsEvent.toggleCommentVisibility());
        },
      ),
      SettingsTile.switchTile(
        initialValue: state.isHideRelated,
        title: Text(locals.hideRelated),
        description: Text(locals.hideRelatedVideosFromWatchScreen),
        leading: const Icon(Icons.video_settings),
        onToggle: (_) {
          BlocProvider.of<SettingsBloc>(context)
              .add(SettingsEvent.toggleRelatedVideoVisibility());
        },
      )
    ],
  );
}
