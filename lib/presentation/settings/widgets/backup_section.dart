import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/infrastructure/settings/newpipe_data_service.dart';
import 'package:fluxtube/core/di/injectable.dart';
import 'package:fluxtube/presentation/settings/widgets/settings_components.dart';
import 'package:share_plus/share_plus.dart' show ShareParams, SharePlus, XFile;

class BackupSettingsSection extends StatelessWidget {
  const BackupSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final locals = S.of(context);

    return BlocBuilder<SettingsBloc, SettingsState>(
      buildWhen: (previous, current) =>
          previous.currentProfile != current.currentProfile ||
          previous.lastExportedFilePath != current.lastExportedFilePath,
      builder: (context, settingsState) {
        final currentProfile = settingsState.currentProfile;

        return SettingsSectionCard(
          title: currentProfile != 'default'
              ? '${locals.backupRestore} · $currentProfile'
              : locals.backupRestore,
          children: [
            // NewPipe compatible export (ZIP)
            SettingsActionTile(
              icon: Icons.archive_outlined,
              title: locals.exportSubscriptions,
              subtitle:
                  'Export as NewPipe-compatible ZIP (subscriptions, history, saved)',
              onTap: () async => _exportAsZip(context, currentProfile, locals),
            ),
            // Import from NewPipe ZIP
            SettingsActionTile(
              icon: Icons.unarchive_outlined,
              title: locals.importSubscriptions,
              subtitle: 'Import from NewPipe or FluxTube ZIP file',
              onTap: () async => _importFromZip(context, currentProfile, locals),
            ),
            // Legacy JSON export (for backwards compatibility)
            SettingsActionTile(
              icon: Icons.upload_outlined,
              title: '${locals.exportSubscriptions} (JSON)',
              subtitle: locals.backupRestoreDescription,
              onTap: () async =>
                  _exportSubscriptionsJson(context, currentProfile, locals),
            ),
            // Legacy JSON import
            SettingsActionTile(
              icon: Icons.download_outlined,
              title: '${locals.importSubscriptions} (JSON)',
              subtitle: locals.selectFile,
              onTap: () async =>
                  _importSubscriptionsJson(context, currentProfile, locals),
            ),
          ],
        );
      },
    );
  }

  Future<void> _exportAsZip(
      BuildContext context, String currentProfile, S locals) async {
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 16),
            const Text('Exporting data...'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 10),
      ),
    );

    try {
      final dataService = getIt<NewPipeDataService>();
      final result = await dataService.exportAsNewPipeZip(
        profileName: currentProfile,
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Export failed: ${failure.toString()}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        (filePath) {
          // Update settings bloc with the exported file path
          BlocProvider.of<SettingsBloc>(context).add(
            SettingsEvent.setLastExportedFilePath(filePath: filePath),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(locals.exportSuccess),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: locals.share,
                onPressed: () async {
                  await SharePlus.instance.share(
                    ShareParams(files: [XFile(filePath)]),
                  );
                },
              ),
            ),
          );
        },
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export error: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _importFromZip(
      BuildContext context, String currentProfile, S locals) async {
    try {
      // Open file picker for ZIP files
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return; // User cancelled
      }

      final filePath = result.files.first.path;
      if (filePath == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(locals.importError),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      // Show import options dialog
      if (!context.mounted) return;
      final options = await _showImportOptionsDialog(context);
      if (options == null) return; // User cancelled

      // Show loading indicator
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 16),
                const Text('Importing data...'),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 30),
          ),
        );
      }

      final dataService = getIt<NewPipeDataService>();
      final importResult = await dataService.importFromNewPipeZip(
        zipPath: filePath,
        profileName: currentProfile,
        importSubscriptions: options['subscriptions'] ?? true,
        importSearchHistory: options['searchHistory'] ?? true,
        importWatchHistory: options['watchHistory'] ?? true,
        importPlaylists: options['playlists'] ?? true,
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();

      importResult.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Import failed: ${failure.toString()}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        (result) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Imported: ${result.subscriptionsImported} subscriptions, '
                '${result.searchHistoryImported} searches, '
                '${result.watchHistoryImported} history items, '
                '${result.playlistsImported} saved videos',
              ),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 5),
            ),
          );

          // Refresh subscriptions
          BlocProvider.of<SubscribeBloc>(context).add(
            const SubscribeEvent.getAllSubscribeList(),
          );
        },
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${locals.importError}: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<Map<String, bool>?> _showImportOptionsDialog(BuildContext context) async {
    bool importSubscriptions = true;
    bool importSearchHistory = true;
    bool importWatchHistory = true;
    bool importPlaylists = true;

    return showDialog<Map<String, bool>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Import Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CheckboxListTile(
                title: const Text('Subscriptions'),
                subtitle: const Text('YouTube channel subscriptions'),
                value: importSubscriptions,
                onChanged: (v) => setState(() => importSubscriptions = v ?? true),
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
              ),
              CheckboxListTile(
                title: const Text('Search History'),
                subtitle: const Text('Previous search queries'),
                value: importSearchHistory,
                onChanged: (v) => setState(() => importSearchHistory = v ?? true),
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
              ),
              CheckboxListTile(
                title: const Text('Watch History'),
                subtitle: const Text('Previously watched videos'),
                value: importWatchHistory,
                onChanged: (v) => setState(() => importWatchHistory = v ?? true),
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
              ),
              CheckboxListTile(
                title: const Text('Saved Videos'),
                subtitle: const Text('Playlist items as saved videos'),
                value: importPlaylists,
                onChanged: (v) => setState(() => importPlaylists = v ?? true),
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, {
                'subscriptions': importSubscriptions,
                'searchHistory': importSearchHistory,
                'watchHistory': importWatchHistory,
                'playlists': importPlaylists,
              }),
              child: const Text('Import'),
            ),
          ],
        ),
      ),
    );
  }

  // Legacy JSON export
  Future<void> _exportSubscriptionsJson(
      BuildContext context, String currentProfile, S locals) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 16),
            const Text('Exporting...'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

    final settingsBloc = BlocProvider.of<SettingsBloc>(context);
    settingsBloc.add(SettingsEvent.exportSubscriptions(profileName: currentProfile));

    await Future.delayed(const Duration(milliseconds: 800));

    final exportedFilePath = settingsBloc.state.lastExportedFilePath;

    if (context.mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(locals.exportSuccess),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          action: exportedFilePath != null
              ? SnackBarAction(
                  label: locals.share,
                  onPressed: () async {
                    await SharePlus.instance.share(
                      ShareParams(files: [XFile(exportedFilePath)]),
                    );
                  },
                )
              : null,
        ),
      );
    }
  }

  // Legacy JSON import
  Future<void> _importSubscriptionsJson(
      BuildContext context, String currentProfile, S locals) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final filePath = result.files.first.path;
      if (filePath == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(locals.importError),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 16),
                const Text('Importing...'),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      if (!context.mounted) return;
      BlocProvider.of<SettingsBloc>(context).add(
        SettingsEvent.importSubscriptions(
          filePath: filePath,
          profileName: currentProfile,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 800));

      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(locals.importSuccess),
            behavior: SnackBarBehavior.floating,
          ),
        );

        BlocProvider.of<SubscribeBloc>(context).add(
          const SubscribeEvent.getAllSubscribeList(),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${locals.importError}: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
