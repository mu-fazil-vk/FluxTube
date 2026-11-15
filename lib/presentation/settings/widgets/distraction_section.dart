import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/settings/settings_bloc.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/presentation/settings/widgets/settings_components.dart';

class DistractionFreeSettingsSection extends StatelessWidget {
  const DistractionFreeSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final locals = S.of(context);
    return BlocBuilder<SettingsBloc, SettingsState>(
      buildWhen: (previous, current) =>
          previous.isHideComments != current.isHideComments ||
          previous.isHideRelated != current.isHideRelated,
      builder: (context, state) {
        return SettingsSectionCard(
          title: locals.distractionFree,
          children: [
            SettingsSwitchTile(
              icon: CupertinoIcons.bubble_left_bubble_right_fill,
              title: locals.hideComments,
              subtitle: locals.hideCommentsButtonFromWatchScreen,
              value: state.isHideComments,
              onChanged: (_) => context
                  .read<SettingsBloc>()
                  .add(SettingsEvent.toggleCommentVisibility()),
            ),
            SettingsSwitchTile(
              icon: Icons.video_settings_outlined,
              title: locals.hideRelated,
              subtitle: locals.hideRelatedVideosFromWatchScreen,
              value: state.isHideRelated,
              onChanged: (_) => context
                  .read<SettingsBloc>()
                  .add(SettingsEvent.toggleRelatedVideoVisibility()),
            ),
          ],
        );
      },
    );
  }
}
