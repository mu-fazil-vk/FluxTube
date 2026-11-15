import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/settings/settings_bloc.dart';
import 'package:fluxtube/core/app_info.dart';
import 'package:fluxtube/core/services/update_checker.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/presentation/settings/utils/launch_url.dart';
import 'package:fluxtube/presentation/settings/widgets/settings_components.dart';
import 'package:go_router/go_router.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final locals = S.of(context);

    return SettingsSectionCard(
      title: locals.about,
      children: [
        SettingsActionTile(
          icon: Icons.code,
          title: locals.developer,
          subtitle: AppInfo.developerInfos.first.name,
          trailing: const Icon(CupertinoIcons.chat_bubble_2),
          onTap: () => urlLaunch(AppInfo.developerInfos.first.url),
        ),
        SettingsActionTile(
          icon: Icons.translate_rounded,
          title: locals.translators,
          onTap: () => context.goNamed('translators'),
        ),
        const _CheckForUpdatesTile(),
        BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) => SettingsActionTile(
            icon: CupertinoIcons.info,
            title: locals.version,
            subtitle: state.version ?? "",
            onLongPress: () => context.goNamed('debug'),
          ),
        ),
      ],
    );
  }
}

class _CheckForUpdatesTile extends StatefulWidget {
  const _CheckForUpdatesTile();

  @override
  State<_CheckForUpdatesTile> createState() => _CheckForUpdatesTileState();
}

class _CheckForUpdatesTileState extends State<_CheckForUpdatesTile> {
  bool _checking = false;

  Future<void> _check() async {
    if (_checking) return;
    setState(() => _checking = true);
    await UpdateChecker().checkManually(context);
    if (mounted) setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    return SettingsActionTile(
      icon: Icons.system_update_alt_rounded,
      title: 'Check for Updates',
      onTap: _check,
      trailing: _checking
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
    );
  }
}
