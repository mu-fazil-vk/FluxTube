import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/presentation/settings/widgets/settings_components.dart';

class ProfilesSettingsSection extends StatelessWidget {
  const ProfilesSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final locals = S.of(context);
    final scheme = Theme.of(context).colorScheme;

    return BlocBuilder<SettingsBloc, SettingsState>(
      buildWhen: (previous, current) =>
          previous.profiles != current.profiles ||
          previous.currentProfile != current.currentProfile,
      builder: (context, state) {
        return SettingsSectionCard(
          title: locals.profiles,
          children: [
            for (final profile in state.profiles)
              _ProfileRow(
                profile: profile,
                isSelected: state.currentProfile == profile,
                isDefault: profile == 'default',
                onSwitch: () {
                  context
                      .read<SettingsBloc>()
                      .add(SettingsEvent.switchProfile(profileName: profile));
                  context
                      .read<SubscribeBloc>()
                      .add(SubscribeEvent.getAllSubscribeList(profileName: profile));
                  context
                      .read<SavedBloc>()
                      .add(SavedEvent.getAllVideoInfoList(profileName: profile));
                },
                onRename: () => _showRenameProfileDialog(context, profile, locals),
                onDelete: () => _showDeleteConfirmation(context, profile, locals),
              ),
            SettingsActionTile(
              icon: Icons.add,
              title: locals.addProfile,
              iconColor: scheme.primary,
              titleColor: scheme.primary,
              onTap: () => _showAddProfileDialog(context, locals),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, String profile, S locals) {
    final scheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: scheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
        title: Text(locals.deleteProfile),
        content: Text('Delete profile "$profile"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(locals.cancel),
          ),
          TextButton(
            onPressed: () {
              context
                  .read<SettingsBloc>()
                  .add(SettingsEvent.deleteProfile(profileName: profile));
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: scheme.error),
            child: Text(locals.delete),
          ),
        ],
      ),
    );
  }

  void _showAddProfileDialog(BuildContext context, S locals) {
    final scheme = Theme.of(context).colorScheme;
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: scheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
        title: Text(locals.addProfile),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: locals.profileName,
            hintText: 'Enter profile name',
            border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(locals.cancel),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                context
                    .read<SettingsBloc>()
                    .add(SettingsEvent.addProfile(profileName: name));
              }
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: scheme.primary),
            child: Text(locals.createAction),
          ),
        ],
      ),
    );
  }

  void _showRenameProfileDialog(BuildContext context, String oldName, S locals) {
    final scheme = Theme.of(context).colorScheme;
    final controller = TextEditingController(text: oldName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: scheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
        title: Text(locals.renameProfile),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: locals.newProfileName,
            hintText: 'Enter new name',
            border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(locals.cancel),
          ),
          FilledButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != oldName) {
                context.read<SettingsBloc>().add(
                    SettingsEvent.renameProfile(oldName: oldName, newName: newName));
              }
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: scheme.primary),
            child: Text(locals.renameAction),
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.profile,
    required this.isSelected,
    required this.isDefault,
    required this.onSwitch,
    required this.onRename,
    required this.onDelete,
  });

  final String profile;
  final bool isSelected;
  final bool isDefault;
  final VoidCallback onSwitch;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locals = S.of(context);

    return SettingsActionTile(
      icon: isSelected ? Icons.person : Icons.person_outline,
      iconColor: isSelected ? scheme.primary : null,
      titleColor: isSelected ? scheme.primary : null,
      title: isDefault ? locals.defaultProfile : profile,
      subtitle: isSelected ? locals.profileInUse : null,
      onTap: isSelected ? null : onSwitch,
      trailing: isDefault
          ? (isSelected ? Icon(Icons.check_circle, color: scheme.primary, size: AppIconSize.sm) : null)
          : PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: scheme.onSurfaceVariant),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
              onSelected: (value) {
                if (value == 'rename') {
                  onRename();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  value: 'rename',
                  child: Row(
                    children: [
                      const Icon(Icons.edit_outlined, size: 20),
                      AppSpacing.width12,
                      Text(locals.renameProfile),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 20, color: scheme.error),
                      AppSpacing.width12,
                      Text(locals.deleteProfile, style: TextStyle(color: scheme.error)),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
