import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/download/download_bloc.dart';
import 'package:fluxtube/application/settings/settings_bloc.dart';
import 'package:fluxtube/core/animations/animations.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/core/enums.dart';
import 'package:fluxtube/domain/download/models/download_item.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/presentation/download/widgets/download_item_card.dart';
import 'package:fluxtube/presentation/main_navigation/main_navigation.dart';
import 'package:fluxtube/presentation/main_navigation/main_navigation_layout.dart';

class DownloadsSection extends StatefulWidget {
  const DownloadsSection({super.key});

  @override
  State<DownloadsSection> createState() => _DownloadsSectionState();
}

class _DownloadsSectionState extends State<DownloadsSection> {
  bool _hasLoaded = false;

  /// 0 = Downloading, 1 = Completed, 2 = All
  int _filter = 2;

  @override
  void initState() {
    super.initState();
    final requested = downloadsTabNotifier.value;
    if (requested != null && requested >= 0 && requested < 3) {
      _filter = requested;
      downloadsTabNotifier.value = null;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoaded) {
      _hasLoaded = true;
      _loadDownloads();
    }
  }

  void _loadDownloads() {
    final profileName = context.read<SettingsBloc>().state.currentProfile;
    context.read<DownloadBloc>().add(
          DownloadEvent.getAllDownloads(profileName: profileName),
        );
  }

  int _completedCount(DownloadState state) => state.completedDownloads.length;

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var value = bytes.toDouble();
    var unit = 0;
    while (value >= 1024 && unit < units.length - 1) {
      value /= 1024;
      unit++;
    }
    return '${value >= 100 || unit == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1)} ${units[unit]}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final locals = S.of(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<DownloadBloc, DownloadState>(
          listenWhen: (previous, current) =>
              current.errorMessage != null &&
              current.errorMessage != previous.errorMessage,
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    locals
                        .downloadFailed(state.failedDownloadTitle ?? 'Unknown'),
                  ),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
        ),
        BlocListener<DownloadBloc, DownloadState>(
          listenWhen: (previous, current) =>
              previous.saveToDeviceStatus != current.saveToDeviceStatus,
          listener: (context, state) {
            if (state.saveToDeviceStatus == ApiStatus.loaded) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(locals.savedToDevice),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.success,
                ),
              );
            } else if (state.saveToDeviceStatus == ApiStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(locals.saveToDeviceFailed),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
        ),
      ],
      child: BlocBuilder<DownloadBloc, DownloadState>(
        builder: (context, state) {
          if (state.fetchDownloadsStatus == ApiStatus.loading ||
              state.fetchDownloadsStatus == ApiStatus.initial) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2.5),
            );
          }

          final downloads = switch (_filter) {
            0 => [...state.activeDownloads, ...state.pendingDownloads],
            1 => state.completedDownloads,
            _ => state.allDownloads,
          };
          final showProgress = _filter != 1;

          final totalBytes = state.completedDownloads.fold<int>(
            0,
            (sum, item) => sum + (item.totalBytes ?? item.downloadedBytes),
          );

          final bottomInset =
              AppSpacing.lg + MainNavigationLayout.navPadding(context).bottom;

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                sliver: SliverToBoxAdapter(
                  child: _StorageIndicatorCard(
                    usedLabel: locals.storageUsed(_formatBytes(totalBytes)),
                    itemCount:
                        locals.downloadsCount(_completedCount(state)),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      _buildFilterChip(context,
                          label: locals.downloading, value: 0),
                      AppSpacing.width8,
                      _buildFilterChip(context,
                          label: locals.completed, value: 1),
                      AppSpacing.width8,
                      _buildFilterChip(context, label: locals.all, value: 2),
                    ],
                  ),
                ),
              ),
              if (downloads.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(colorScheme, locals),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    bottomInset,
                  ),
                  sliver: SliverList.builder(
                    itemCount: downloads.length,
                    itemBuilder: (context, index) {
                      final item = downloads[index];
                      return AnimatedListItem(
                        index: index,
                        child: DownloadItemCard(
                          item: item,
                          showProgress: showProgress,
                          onDelete: () => _confirmDelete(item),
                          onPause: () => context.read<DownloadBloc>().add(
                                DownloadEvent.pauseDownload(
                                    downloadId: item.id!),
                              ),
                          onResume: () => context.read<DownloadBloc>().add(
                                DownloadEvent.resumeDownload(
                                    downloadId: item.id!),
                              ),
                          onCancel: () => context.read<DownloadBloc>().add(
                                DownloadEvent.cancelDownload(
                                    downloadId: item.id!),
                              ),
                          onSaveToDevice: () => context
                              .read<DownloadBloc>()
                              .add(
                                DownloadEvent.saveToDevice(downloadItem: item),
                              ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required int value,
  }) {
    final theme = Theme.of(context);
    final selected = _filter == value;
    return ScaleTap(
      enableHaptic: false,
      onTap: () => setState(() => _filter = value),
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        curve: AppAnimations.defaultCurve,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs + 2,
        ),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHigh,
          borderRadius: AppRadius.borderFull,
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: selected
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _confirmDelete(DownloadItem item) {
    final locals = S.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(locals.deleteDownload),
        content: Text(locals.deleteDownloadConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(locals.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              this.context.read<DownloadBloc>().add(
                    DownloadEvent.deleteDownload(downloadId: item.id!),
                  );
            },
            child: Text(
              locals.delete,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, S locals) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.arrow_down_circle,
            size: 64,
            color: colorScheme.onSurfaceVariant,
          ),
          AppSpacing.height20,
          Text(
            locals.noDownloads,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          AppSpacing.height8,
          Text(
            locals.noDownloadsHint,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StorageIndicatorCard extends StatelessWidget {
  const _StorageIndicatorCard({
    required this.usedLabel,
    required this.itemCount,
  });

  final String usedLabel;
  final String itemCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: AppRadius.borderLg,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.primaryContainer,
            ),
            child: Icon(
              CupertinoIcons.arrow_down_circle_fill,
              size: 22,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          AppSpacing.width12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  usedLabel,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  itemCount,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
