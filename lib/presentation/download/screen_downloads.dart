import 'dart:io';

import 'package:fluxtube/widgets/thumbnail_image.dart';
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
import 'package:fluxtube/presentation/main_navigation/main_navigation.dart';
import 'package:open_filex/open_filex.dart';

class ScreenDownloads extends StatefulWidget {
  const ScreenDownloads({super.key});

  @override
  State<ScreenDownloads> createState() => _ScreenDownloadsState();
}

class _ScreenDownloadsState extends State<ScreenDownloads>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Listen for external tab change requests (from notifications)
    downloadsTabNotifier.addListener(_onTabChangeRequested);
  }

  void _onTabChangeRequested() {
    final requestedTab = downloadsTabNotifier.value;
    if (requestedTab != null && requestedTab >= 0 && requestedTab < 3) {
      _tabController.animateTo(requestedTab);
      // Clear the notifier after handling
      downloadsTabNotifier.value = null;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoaded) {
      _hasLoaded = true;
      _loadDownloads();
      // Check if there's a pending tab request on first load
      _onTabChangeRequested();
    }
  }

  void _loadDownloads() {
    final profileName = context.read<SettingsBloc>().state.currentProfile;
    context.read<DownloadBloc>().add(
          DownloadEvent.getAllDownloads(profileName: profileName),
        );
  }

  @override
  void dispose() {
    downloadsTabNotifier.removeListener(_onTabChangeRequested);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final locals = S.of(context);

    return SafeArea(
      child: MultiBlocListener(
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
                      locals.downloadFailed(state.failedDownloadTitle ?? 'Unknown'),
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
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              floating: true,
              snap: true,
              title: Text(
                locals.downloads,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              bottom: TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: isDark
                    ? AppColors.onSurfaceVariantDark
                    : AppColors.onSurfaceVariant,
                indicatorColor: AppColors.primary,
                tabs: [
                  Tab(text: locals.downloading),
                  Tab(text: locals.completed),
                  Tab(text: locals.all),
                ],
              ),
            ),
          ],
          body: BlocBuilder<DownloadBloc, DownloadState>(
            builder: (context, state) {
            if (state.fetchDownloadsStatus == ApiStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(strokeWidth: 2.5),
              );
            }

            return TabBarView(
              controller: _tabController,
              children: [
                // Downloading tab
                _buildDownloadsList(
                  [...state.activeDownloads, ...state.pendingDownloads],
                  isDark,
                  locals,
                  showProgress: true,
                ),
                // Completed tab
                _buildDownloadsList(
                  state.completedDownloads,
                  isDark,
                  locals,
                  showProgress: false,
                ),
                // All tab
                _buildDownloadsList(
                  state.allDownloads,
                  isDark,
                  locals,
                  showProgress: true,
                ),
              ],
            );
          },
        ),
        ),
      ),
    );
  }

  Widget _buildDownloadsList(
    List<DownloadItem> downloads,
    bool isDark,
    S locals, {
    required bool showProgress,
  }) {
    if (downloads.isEmpty) {
      return _buildEmptyState(isDark, locals);
    }

    return RefreshIndicator(
      onRefresh: () async => _loadDownloads(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        itemCount: downloads.length,
        itemBuilder: (context, index) {
          final item = downloads[index];
          return AnimatedListItem(
            index: index,
            child: _DownloadItemCard(
              item: item,
              isDark: isDark,
              showProgress: showProgress,
              onTap: () => _onItemTap(item),
              onDelete: () => _onDelete(item),
              onPause: () => _onPause(item),
              onResume: () => _onResume(item),
              onCancel: () => _onCancel(item),
              onSaveToDevice: () => _onSaveToDevice(item),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, S locals) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.arrow_down_circle,
            size: 64,
            color: isDark
                ? AppColors.onSurfaceVariantDark
                : AppColors.onSurfaceVariant,
          ),
          AppSpacing.height20,
          Text(
            locals.noDownloads,
            style: TextStyle(
              fontSize: AppFontSize.subtitle,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.onSurfaceDark : AppColors.onSurface,
            ),
          ),
          AppSpacing.height8,
          Text(
            locals.noDownloadsHint,
            style: TextStyle(
              color: isDark
                  ? AppColors.onSurfaceVariantDark
                  : AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _onItemTap(DownloadItem item) async {
    if (item.status == DownloadStatus.completed && item.outputFilePath != null) {
      final file = File(item.outputFilePath!);
      if (await file.exists()) {
        // Use open_filex to properly open files on Android (handles FileProvider)
        final result = await OpenFilex.open(item.outputFilePath!);
        if (result.type != ResultType.done && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${S.of(context).failedToOpenFile}: ${result.message}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).fileNotFound),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _onDelete(DownloadItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).deleteDownload),
        content: Text(S.of(context).deleteDownloadConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<DownloadBloc>().add(
                    DownloadEvent.deleteDownload(downloadId: item.id!),
                  );
            },
            child: Text(
              S.of(context).delete,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _onPause(DownloadItem item) {
    context.read<DownloadBloc>().add(
          DownloadEvent.pauseDownload(downloadId: item.id!),
        );
  }

  void _onResume(DownloadItem item) {
    context.read<DownloadBloc>().add(
          DownloadEvent.resumeDownload(downloadId: item.id!),
        );
  }

  void _onCancel(DownloadItem item) {
    context.read<DownloadBloc>().add(
          DownloadEvent.cancelDownload(downloadId: item.id!),
        );
  }

  Future<void> _onSaveToDevice(DownloadItem item) async {
    if (item.outputFilePath == null) return;

    final locals = S.of(context);

    // Show saving indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(locals.savingToDevice),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );

    context.read<DownloadBloc>().add(
          DownloadEvent.saveToDevice(downloadItem: item),
        );
  }
}

class _DownloadItemCard extends StatelessWidget {
  final DownloadItem item;
  final bool isDark;
  final bool showProgress;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onCancel;
  final VoidCallback? onSaveToDevice;

  const _DownloadItemCard({
    required this.item,
    required this.isDark,
    required this.showProgress,
    required this.onTap,
    required this.onDelete,
    required this.onPause,
    required this.onResume,
    required this.onCancel,
    this.onSaveToDevice,
  });

  @override
  Widget build(BuildContext context) {
    final locals = S.of(context);

    return ScaleTap(
      onTap: onTap,
      scaleDown: 0.98,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
          borderRadius: AppRadius.borderMd,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: AppRadius.borderSm,
                  child: Stack(
                    children: [
                      item.thumbnailUrl != null
                          ? ThumbnailImage.small(
                              url: item.thumbnailUrl!,
                              width: 100,
                              height: 56,
                              errorWidget: (_, __, ___) => _thumbnailPlaceholder(),
                            )
                          : _thumbnailPlaceholder(),
                      // Status overlay
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: _getStatusOverlayColor(),
                          ),
                          child: Center(
                            child: _getStatusIcon(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.width12,
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.onSurfaceDark
                              : AppColors.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppSpacing.height4,
                      Text(
                        item.channelName,
                        style: TextStyle(
                          fontSize: AppFontSize.caption,
                          color: isDark
                              ? AppColors.onSurfaceVariantDark
                              : AppColors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppSpacing.height4,
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _buildStatusBadge(locals),
                          _buildDownloadTypeBadge(locals),
                          if (item.videoQuality != null)
                            _buildQualityBadge(item.videoQuality!),
                        ],
                      ),
                    ],
                  ),
                ),
                // Actions
                _buildActions(),
              ],
            ),

            // Progress bar
            if (showProgress && item.isActive) ...[
              AppSpacing.height12,
              _buildProgressSection(locals),
            ],
          ],
        ),
      ),
    );
  }

  Widget _thumbnailPlaceholder() {
    return Container(
      width: 100,
      height: 56,
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      child: Icon(
        CupertinoIcons.play_rectangle,
        color: isDark
            ? AppColors.onSurfaceVariantDark
            : AppColors.onSurfaceVariant,
      ),
    );
  }

  Color _getStatusOverlayColor() {
    switch (item.status) {
      case DownloadStatus.completed:
        return AppColors.success.withValues(alpha: 0.3);
      case DownloadStatus.failed:
        return AppColors.error.withValues(alpha: 0.3);
      case DownloadStatus.paused:
        return AppColors.warning.withValues(alpha: 0.3);
      case DownloadStatus.downloading:
      case DownloadStatus.merging:
        return Colors.transparent;
      default:
        return Colors.black.withValues(alpha: 0.2);
    }
  }

  Widget? _getStatusIcon() {
    switch (item.status) {
      case DownloadStatus.completed:
        return const Icon(
          CupertinoIcons.checkmark_circle_fill,
          color: Colors.white,
          size: 24,
        );
      case DownloadStatus.failed:
        return const Icon(
          CupertinoIcons.exclamationmark_circle_fill,
          color: Colors.white,
          size: 24,
        );
      case DownloadStatus.paused:
        return const Icon(
          CupertinoIcons.pause_circle_fill,
          color: Colors.white,
          size: 24,
        );
      case DownloadStatus.downloading:
        return SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            value: item.progress,
            strokeWidth: 2,
            color: Colors.white,
          ),
        );
      default:
        return null;
    }
  }

  Widget _buildStatusBadge(S locals) {
    Color color;
    String text;

    switch (item.status) {
      case DownloadStatus.pending:
        color = AppColors.warning;
        text = locals.pending;
        break;
      case DownloadStatus.downloading:
        color = AppColors.primary;
        text = locals.downloading;
        break;
      case DownloadStatus.paused:
        color = AppColors.warning;
        text = locals.paused;
        break;
      case DownloadStatus.completed:
        color = AppColors.success;
        text = locals.completed;
        break;
      case DownloadStatus.failed:
        color = AppColors.error;
        text = locals.failed;
        break;
      case DownloadStatus.cancelled:
        color = AppColors.disabled;
        text = locals.cancelled;
        break;
      case DownloadStatus.merging:
        color = AppColors.primary;
        text = locals.merging;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppRadius.borderXs,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildDownloadTypeBadge(S locals) {
    Color color;
    String text;
    IconData icon;

    switch (item.downloadType) {
      case DownloadType.videoOnly:
        color = AppColors.primary;
        text = locals.video;
        icon = CupertinoIcons.videocam_fill;
        break;
      case DownloadType.audioOnly:
        color = AppColors.warning;
        text = locals.audio;
        icon = CupertinoIcons.music_note_2;
        break;
      case DownloadType.videoWithAudio:
        color = AppColors.success;
        text = locals.videoAudio;
        icon = CupertinoIcons.film;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppRadius.borderXs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          AppSpacing.width4,
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityBadge(String quality) {
    final color = isDark
        ? AppColors.onSurfaceVariantDark
        : AppColors.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppRadius.borderXs,
      ),
      child: Text(
        quality,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildActions() {
    return PopupMenuButton<String>(
      icon: Icon(
        CupertinoIcons.ellipsis_vertical,
        color: isDark
            ? AppColors.onSurfaceVariantDark
            : AppColors.onSurfaceVariant,
      ),
      onSelected: (value) {
        switch (value) {
          case 'pause':
            onPause();
            break;
          case 'resume':
            onResume();
            break;
          case 'cancel':
            onCancel();
            break;
          case 'delete':
            onDelete();
            break;
          case 'save_to_device':
            onSaveToDevice?.call();
            break;
        }
      },
      itemBuilder: (context) {
        final locals = S.of(context);
        final items = <PopupMenuEntry<String>>[];

        if (item.canPause) {
          items.add(PopupMenuItem(
            value: 'pause',
            child: Row(
              children: [
                const Icon(CupertinoIcons.pause),
                AppSpacing.width8,
                Text(locals.pause),
              ],
            ),
          ));
        }

        if (item.canResume) {
          items.add(PopupMenuItem(
            value: 'resume',
            child: Row(
              children: [
                const Icon(CupertinoIcons.play),
                AppSpacing.width8,
                Text(locals.resume),
              ],
            ),
          ));
        }

        if (item.isActive) {
          items.add(PopupMenuItem(
            value: 'cancel',
            child: Row(
              children: [
                const Icon(CupertinoIcons.xmark),
                AppSpacing.width8,
                Text(locals.cancel),
              ],
            ),
          ));
        }

        // Save to device option for completed downloads
        if (item.status == DownloadStatus.completed) {
          items.add(PopupMenuItem(
            value: 'save_to_device',
            child: Row(
              children: [
                const Icon(CupertinoIcons.square_arrow_down),
                AppSpacing.width8,
                Text(locals.saveToDevice),
              ],
            ),
          ));
        }

        items.add(PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              const Icon(CupertinoIcons.trash, color: AppColors.error),
              AppSpacing.width8,
              Text(locals.delete, style: const TextStyle(color: AppColors.error)),
            ],
          ),
        ));

        return items;
      },
    );
  }

  Widget _buildProgressSection(S locals) {
    // For video+audio downloads, show dual progress bars
    final isVideoWithAudio = item.downloadType == DownloadType.videoWithAudio;
    final phaseText = _getPhaseText(locals);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Phase indicator for video+audio downloads (not when merging - shown in stats row)
        if (isVideoWithAudio && phaseText != null && item.status != DownloadStatus.merging) ...[
          Text(
            phaseText,
            style: TextStyle(
              fontSize: AppFontSize.caption,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          AppSpacing.height4,
        ],
        // Progress bar(s)
        if (isVideoWithAudio && item.status != DownloadStatus.merging) ...[
          // Video progress
          _buildDualProgressBar(
            label: locals.downloadingVideo,
            progress: item.videoProgress,
            color: AppColors.primary,
          ),
          AppSpacing.height4,
          // Audio progress
          _buildDualProgressBar(
            label: locals.downloadingAudio,
            progress: item.audioProgress,
            color: AppColors.warning,
          ),
        ] else if (item.status == DownloadStatus.merging) ...[
          // Merging - show indeterminate progress
          ClipRRect(
            borderRadius: AppRadius.borderXs,
            child: LinearProgressIndicator(
              value: null, // Indeterminate
              backgroundColor: isDark
                  ? AppColors.surfaceDark
                  : AppColors.surface,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.warning),
              minHeight: 4,
            ),
          ),
        ] else ...[
          // Single progress bar for video-only or audio-only
          ClipRRect(
            borderRadius: AppRadius.borderXs,
            child: LinearProgressIndicator(
              value: item.progress,
              backgroundColor: isDark
                  ? AppColors.surfaceDark
                  : AppColors.surface,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 4,
            ),
          ),
        ],
        AppSpacing.height8,
        // Stats row
        Row(
          children: [
            if (item.status == DownloadStatus.merging)
              Text(
                locals.merging,
                style: TextStyle(
                  fontSize: AppFontSize.caption,
                  fontWeight: FontWeight.w600,
                  color: AppColors.warning,
                ),
              )
            else
              Text(
                '${(item.progress * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: AppFontSize.caption,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            AppSpacing.width12,
            if (item.status != DownloadStatus.merging)
              Text(
                '${item.formattedDownloadedSize} / ${item.formattedTotalSize}',
                style: TextStyle(
                  fontSize: AppFontSize.caption,
                  color: isDark
                      ? AppColors.onSurfaceVariantDark
                      : AppColors.onSurfaceVariant,
                ),
              ),
            const Spacer(),
            if (item.formattedSpeed.isNotEmpty)
              Text(
                item.formattedSpeed,
                style: TextStyle(
                  fontSize: AppFontSize.caption,
                  color: isDark
                      ? AppColors.onSurfaceVariantDark
                      : AppColors.onSurfaceVariant,
                ),
              ),
            if (item.formattedEta.isNotEmpty) ...[
              AppSpacing.width8,
              Text(
                'ETA: ${item.formattedEta}',
                style: TextStyle(
                  fontSize: AppFontSize.caption,
                  color: isDark
                      ? AppColors.onSurfaceVariantDark
                      : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  String? _getPhaseText(S locals) {
    if (item.status == DownloadStatus.merging) {
      return locals.merging;
    }
    switch (item.currentPhase) {
      case 'video':
        return locals.downloadingVideo;
      case 'audio':
        return locals.downloadingAudio;
      case 'merging':
        return locals.merging;
      default:
        return null;
    }
  }

  Widget _buildDualProgressBar({
    required String label,
    required double progress,
    required Color color,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 50,
          child: Text(
            progress >= 1.0 ? '100%' : '${(progress * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 10,
              color: isDark
                  ? AppColors.onSurfaceVariantDark
                  : AppColors.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: AppRadius.borderXs,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: isDark
                  ? AppColors.surfaceDark
                  : AppColors.surface,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? AppColors.success : color,
              ),
              minHeight: 3,
            ),
          ),
        ),
      ],
    );
  }
}
