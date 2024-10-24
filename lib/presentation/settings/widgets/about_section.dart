import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/settings/settings_bloc.dart';
import 'package:fluxtube/core/app_info.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/presentation/settings/utils/launch_url.dart';
import 'package:go_router/go_router.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).about,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
        ),
        ListTile(
          title: Text(S.of(context).developer,
              style: Theme.of(context).textTheme.titleMedium),
          subtitle: Text(AppInfo.developerInfos.first.name),
          leading: const Icon(Icons.code),
          trailing: const Icon(CupertinoIcons.chat_bubble_2),
          onTap: () => urlLaunch(AppInfo.developerInfos.first.url),
        ),
        ListTile(
          title: Text(S.of(context).translators,
              style: Theme.of(context).textTheme.titleMedium),
          leading: const Icon(Icons.translate_rounded),
          onTap: () => context.goNamed('translators'),
        ),
        BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            return ListTile(
              title: Text(S.of(context).version,
                  style: Theme.of(context).textTheme.titleMedium),
              subtitle: Text(state.version ?? ""),
              leading: const Icon(CupertinoIcons.info),
            );
          },
        ),
      ],
    );
  }
}

// SettingsSection aboutSection(
//     S locals, BuildContext context, SettingsState state) {
//   return SettingsSection(
//     title: Text(
//       locals.about,
//       style: Theme.of(context).textTheme.bodyMedium,
//     ),
//     tiles: [
//       SettingsTile(
//         title: Text(locals.developer),
//         description: Text(AppInfo.developerInfos.first.name),
//         leading: const Icon(Icons.code),
//         trailing: const Icon(CupertinoIcons.chat_bubble_2),
//         onPressed: (BuildContext context) =>
//             urlLaunch(AppInfo.developerInfos.first.url),
//       ),
//       SettingsTile(
//         title: Text(locals.translators),
//         leading: const Icon(Icons.translate_rounded),
//         onPressed: (BuildContext ctx) => context.goNamed('translators'),
//       ),
//       SettingsTile(
//         title: Text(locals.version),
//         description: Text(state.version ?? ""),
//         leading: const Icon(CupertinoIcons.info),
//         onPressed: (BuildContext context) {},
//       ),
//     ],
//   );
// }
