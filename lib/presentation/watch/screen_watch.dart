import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/presentation/watch/explode_screen_watch.dart';
import 'package:fluxtube/presentation/watch/iframe_screen_watch.dart';
import 'package:fluxtube/presentation/watch/piped_screen_watch.dart';

class ScreenWatch extends StatelessWidget {
  const ScreenWatch({
    super.key,
    required this.id,
    required this.channelId,
  });

  final String id;
  final String channelId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
      if (settingsState.ytService == 'piped') {
        return PipedScreenWatch(id: id, channelId: channelId);
      } else if (settingsState.ytService == 'explode') {
        return ExplodeScreenWatch(id: id, channelId: channelId);
      } else {
        return IFramScreenWatch(id: id, channelId: channelId);
      }
    });
  }
}
