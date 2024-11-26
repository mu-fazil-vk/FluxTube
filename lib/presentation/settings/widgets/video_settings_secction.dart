import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/settings/settings_bloc.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/core/enums.dart';
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

final _services = [
  const DropdownMenuItem(
    value: YouTubeServices.piped,
    child: Text("Piped"),
  ),
  const DropdownMenuItem(
    value: YouTubeServices.explode,
    child: Text("Explode"),
  ),
  const DropdownMenuItem(
    value: YouTubeServices.iframe,
    child: Text("IFrame"),
  ),
  const DropdownMenuItem(
    value: YouTubeServices.invidious,
    child: Text("Invidious"),
  ),
];

class VideoSettingsSecction extends StatelessWidget {
  const VideoSettingsSecction({super.key});

  @override
  Widget build(BuildContext context) {
    final locals = S.of(context);
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              locals.video,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 16),
            ),
            kHeightBox10,
            ListTile(
              title: Text(locals.defaultQuality,
                  style: Theme.of(context).textTheme.titleMedium),
              leading: const Icon(Icons.hd_sharp),
              trailing: DropdownButton(
                  value: state.defaultQuality,
                  items: _qualities,
                  onChanged: (quality) => BlocProvider.of<SettingsBloc>(context)
                      .add(SettingsEvent.getDefaultQuality(
                          quality: quality.toString()))),
            ),
            ListTile(
              title: Text("YouTube Service",
                  style: Theme.of(context).textTheme.titleMedium),
              leading: const Icon(Icons.network_cell),
              trailing: DropdownButton(
                  value: YouTubeServices.values
                      .firstWhere((e) => e.name == state.ytService),
                  items: _services,
                  onChanged: (service) {
                    BlocProvider.of<SettingsBloc>(context)
                        .add(SettingsEvent.setYTService(service: service!));
                    if (state.ytService != YouTubeServices.piped.name) {
                      BlocProvider.of<SettingsBloc>(context)
                          .add(SettingsEvent.fetchInvidiousInstances());
                    } else {
                      BlocProvider.of<SettingsBloc>(context)
                          .add(SettingsEvent.fetchPipedInstances());
                    }
                  }),
            ),
            ListTile(
              title: Text(locals.hlsPlayer,
                  style: Theme.of(context).textTheme.titleMedium),
              subtitle: Text(locals.enableHlsPlayerDescription),
              leading: const Icon(CupertinoIcons.play),
              trailing: Switch(
                value: state.isHlsPlayer,
                onChanged: (_) {
                  BlocProvider.of<SettingsBloc>(context)
                      .add(SettingsEvent.toggleHlsPlayer());
                },
              ),
            ),
            ListTile(
              title: Text(locals.history,
                  style: Theme.of(context).textTheme.titleMedium),
              subtitle: Text(locals.disableVideoHistory),
              leading: const Icon(Icons.history),
              trailing: Switch(
                value: !state.isHistoryVisible,
                onChanged: (_) {
                  BlocProvider.of<SettingsBloc>(context)
                      .add(SettingsEvent.toggleHistoryVisibility());
                },
              ),
            ),
            ListTile(
              title: Text(locals.retrieveDislikes,
                  style: Theme.of(context).textTheme.titleMedium),
              subtitle: Text(locals.retrieveDislikeCounts),
              leading: const Icon(CupertinoIcons.hand_thumbsdown),
              trailing: Switch(
                value: state.isDislikeVisible,
                onChanged: (_) {
                  BlocProvider.of<SettingsBloc>(context)
                      .add(SettingsEvent.toggleDislikeVisibility());
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// SettingsSection videoSettingsSection(
//     S locals, BuildContext context, SettingsState state) {
//   return SettingsSection(
//     title: Text(
//       locals.video,
//       style: Theme.of(context).textTheme.bodyMedium,
//     ),
//     tiles: [
//       SettingsTile(
//         title: Text(locals.defaultQuality),
//         leading: const Icon(Icons.hd_sharp),
//         trailing: DropdownButton(
//             value: state.defaultQuality,
//             items: _qualities,
//             onChanged: (quality) => BlocProvider.of<SettingsBloc>(context).add(
//                 SettingsEvent.getDefaultQuality(quality: quality.toString()))),
//       ),
//       SettingsTile(
//         title: const Text("YouTube Service"),
//         leading: const Icon(Icons.network_cell),
//         trailing: DropdownButton(
//             value: YouTubeServices.values
//                 .firstWhere((e) => e.name == state.ytService),
//             items: _services,
//             onChanged: (service) {
//               BlocProvider.of<SettingsBloc>(context)
//                   .add(SettingsEvent.setYTService(service: service!));
//               if (state.ytService != YouTubeServices.piped.name) {
//                 BlocProvider.of<SettingsBloc>(context)
//                     .add(SettingsEvent.fetchInvidiousInstances());
//               } else {
//                 BlocProvider.of<SettingsBloc>(context)
//                     .add(SettingsEvent.fetchPipedInstances());
//               }
//             }),
//       ),
//       SettingsTile.switchTile(
//         initialValue: state.isHlsPlayer,
//         title: Text(locals.hlsPlayer),
//         description: Text(locals.enableHlsPlayerDescription),
//         leading: const Icon(CupertinoIcons.play),
//         onToggle: (_) {
//           BlocProvider.of<SettingsBloc>(context)
//               .add(SettingsEvent.toggleHlsPlayer());
//         },
//       ),
//       SettingsTile.switchTile(
//         initialValue: !state.isHistoryVisible,
//         title: Text(locals.history),
//         description: Text(locals.disableVideoHistory),
//         leading: const Icon(Icons.history),
//         onToggle: (_) {
//           BlocProvider.of<SettingsBloc>(context)
//               .add(SettingsEvent.toggleHistoryVisibility());
//         },
//       ),
//       SettingsTile.switchTile(
//         initialValue: state.isDislikeVisible,
//         title: Text(locals.retrieveDislikes),
//         description: Text(locals.retrieveDislikeCounts),
//         leading: const Icon(CupertinoIcons.hand_thumbsdown),
//         onToggle: (_) {
//           BlocProvider.of<SettingsBloc>(context)
//               .add(SettingsEvent.toggleDislikeVisibility());
//         },
//       ),
//     ],
//   );
// }
