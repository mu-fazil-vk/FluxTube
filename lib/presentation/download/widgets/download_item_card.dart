import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluxtube/core/animations/animations.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/domain/download/models/download_item.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/widgets/thumbnail_image.dart';
import 'package:open_filex/open_filex.dart';

class DownloadItemCard extends StatelessWidget {
  const DownloadItemCard({
    super.key,
    required this.item,
    required this.showProgress,
    required this.onDelete,
    required this.onPause,
    required this.onResume,
    required this.onCancel,
    required this.onSaveToDevice,
  });

  final DownloadItem item;
  final bool showProgress;
  final VoidCallback onDelete;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onCancel;
  final VoidCallback onSaveToDevice;

  Future<void> _openFile(BuildContext context) async {
    if (item.status != DownloadStatus.completed || item.outputFilePath == null) {
      return;
    }
    final file = File(item.outputFilePath!);
    if (await file.exists()) {
      final result = await OpenFilex.open(item.outputFilePath!);
      if (result.type != ResultType.done && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('${S.of(context).failedToOpenFile}: ${result.message}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).fileNotFound),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final locals = S.of(context);

    return ScaleTap(
      onTap: () => _openFile(context),
      scaleDown: 0.98,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: AppRadius.borderLg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: AppRadius.borderMd,
                  child: Stack(
                    children: [
                      item.thumbnailUrl != null
                          ? ThumbnailImage.small(
                              url: item.thumbnailUrl!,
                              width: 100,
                              height: 56,
                              errorWidget: (_, __, ___) => _thumbnailPlaceholder(colorScheme),
                            )
                          : _thumbnailPlaceholder(colorScheme),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: _getStatusOverlayColor(colorScheme),
                          ),
                          child: Center(child: _getStatusIcon(colorScheme)),
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.width12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppSpacing.height4,
                      Text(
                        item.channelName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
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
                            _buildQualityBadge(colorScheme, item.videoQuality!),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildActions(),
              ],
            ),
            if (showProgress && item.isActive) ...[
              AppSpacing.height12,
              _buildProgressSection(context, locals, colorScheme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _thumbnailPlaceholder(ColorScheme colorScheme) {
    return Container(
      width: 100,
      height: 56,
      color: colorScheme.surfaceContainerHigh,
      child: Icon(
        CupertinoIcons.play_rectangle,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  Color _getStatusOverlayColor(ColorScheme colorScheme) {
    switch (item.status) {
      case DownloadStatus.completed:
        return colorScheme.primary.withValues(alpha: 0.3);
      case DownloadStatus.failed:
        return colorScheme.error.withValues(alpha: 0.3);
      case DownloadStatus.paused:
        return colorScheme.tertiary.withValues(alpha: 0.3);
      case DownloadStatus.downloading:
      case DownloadStatus.merging:
        return Colors.transparent;
      default:
        return Colors.black.withValues(alpha: 0.2);
    }
  }

  Widget? _getStatusIcon(ColorScheme colorScheme) {
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

  Widget _buildQualityBadge(ColorScheme colorScheme, String quality) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.15),
        borderRadius: AppRadius.borderXs,
      ),
      child: Text(
        quality,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildActions() {
    return PopupMenuButton<String>(
      icon: Icon(
        CupertinoIcons.ellipsis_vertical,
        size: AppIconSize.sm,
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
            onSaveToDevice();
            break;
        }
      },
      itemBuilder: (context) {
        final locals = S.of(context);
        final colorScheme = Theme.of(context).colorScheme;
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
              Icon(CupertinoIcons.trash, color: colorScheme.error),
              AppSpacing.width8,
              Text(locals.delete,
                  style: TextStyle(color: colorScheme.error)),
            ],
          ),
        ));

        return items;
      },
    );
  }

  Widget _buildProgressSection(
      BuildContext context, S locals, ColorScheme colorScheme) {
    final theme = Theme.of(context);
    final isVideoWithAudio = item.downloadType == DownloadType.videoWithAudio;
    final phaseText = _getPhaseText(locals);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isVideoWithAudio &&
            phaseText != null &&
            item.status != DownloadStatus.merging) ...[
          Text(
            phaseText,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          AppSpacing.height4,
        ],
        if (isVideoWithAudio && item.status != DownloadStatus.merging) ...[
          _buildDualProgressBar(
            progress: item.videoProgress,
            color: colorScheme.primary,
            colorScheme: colorScheme,
          ),
          AppSpacing.height4,
          _buildDualProgressBar(
            progress: item.audioProgress,
            color: colorScheme.tertiary,
            colorScheme: colorScheme,
          ),
        ] else if (item.status == DownloadStatus.merging) ...[
          ClipRRect(
            borderRadius: AppRadius.borderXs,
            child: LinearProgressIndicator(
              value: null,
              backgroundColor: colorScheme.surfaceContainerHigh,
              valueColor:
                  AlwaysStoppedAnimation<Color>(colorScheme.tertiary),
              minHeight: 4,
            ),
          ),
        ] else ...[
          ClipRRect(
            borderRadius: AppRadius.borderXs,
            child: LinearProgressIndicator(
              value: item.progress,
              backgroundColor: colorScheme.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              minHeight: 4,
            ),
          ),
        ],
        AppSpacing.height8,
        Row(
          children: [
            if (item.status == DownloadStatus.merging)
              Text(
                locals.merging,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.tertiary,
                ),
              )
            else
              Text(
                '${(item.progress * 100).toStringAsFixed(1)}%',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            AppSpacing.width12,
            if (item.status != DownloadStatus.merging)
              Text(
                '${item.formattedDownloadedSize} / ${item.formattedTotalSize}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            const Spacer(),
            if (item.formattedSpeed.isNotEmpty)
              Text(
                item.formattedSpeed,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            if (item.formattedEta.isNotEmpty) ...[
              AppSpacing.width8,
              Text(
                'ETA: ${item.formattedEta}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
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
    required double progress,
    required Color color,
    required ColorScheme colorScheme,
  }) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: AppRadius.borderXs,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: colorScheme.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? colorScheme.primary : color,
              ),
              minHeight: 3,
            ),
          ),
        ),
      ],
    );
  }
}
