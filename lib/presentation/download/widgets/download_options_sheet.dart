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
import 'package:fluxtube/domain/download/models/download_quality.dart';
import 'package:fluxtube/domain/watch/models/newpipe/newpipe_stream.dart';
import 'package:fluxtube/generated/l10n.dart';

class DownloadOptionsSheet extends StatefulWidget {
  final String videoId;
  final String title;
  final String channelName;
  final String? thumbnailUrl;
  final int? duration;
  final String serviceType;

  const DownloadOptionsSheet({
    super.key,
    required this.videoId,
    required this.title,
    required this.channelName,
    this.thumbnailUrl,
    this.duration,
    required this.serviceType,
  });

  /// Show download options using NewPipe streams (more reliable - uses same URLs as video playback)
  static Future<void> showWithStreams(
    BuildContext context, {
    required String videoId,
    required String title,
    required String channelName,
    String? thumbnailUrl,
    int? duration,
    required String serviceType,
    required List<NewPipeVideoStream> videoStreams,
    required List<NewPipeVideoStream> videoOnlyStreams,
    required List<NewPipeAudioStream> audioStreams,
  }) {
    // Use NewPipe streams directly - same URLs that work for video playback
    context.read<DownloadBloc>().add(DownloadEvent.setDownloadOptionsFromStreams(
          videoId: videoId,
          title: title,
          channelName: channelName,
          thumbnailUrl: thumbnailUrl,
          duration: duration,
          videoStreams: videoStreams,
          videoOnlyStreams: videoOnlyStreams,
          audioStreams: audioStreams,
        ));

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.scrim,
      builder: (context) => DownloadOptionsSheet(
        videoId: videoId,
        title: title,
        channelName: channelName,
        thumbnailUrl: thumbnailUrl,
        duration: duration,
        serviceType: serviceType,
      ),
    );
  }

  /// Show download options (deprecated - use showWithStreams instead)
  /// This method shows an error message since downloads now require NewPipe streams
  @Deprecated('Use showWithStreams with NewPipe streams instead')
  static Future<void> show(
    BuildContext context, {
    required String videoId,
    required String title,
    required String channelName,
    String? thumbnailUrl,
    int? duration,
    required String serviceType,
  }) {
    // Show error - downloads now require NewPipe service
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.scrim,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.exclamationmark_triangle,
                size: 48,
                color: AppColors.warning,
              ),
              AppSpacing.height16,
              Text(
                'Downloads require NewPipe Extractor service',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.onSurfaceDark : AppColors.onSurface,
                ),
              ),
              AppSpacing.height8,
              Text(
                'Please switch to NewPipe Extractor in Settings > YouTube Service to enable downloads.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark
                      ? AppColors.onSurfaceDark.withValues(alpha: 0.7)
                      : AppColors.onSurface.withValues(alpha: 0.7),
                ),
              ),
              AppSpacing.height24,
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  State<DownloadOptionsSheet> createState() => _DownloadOptionsSheetState();
}

class _DownloadOptionsSheetState extends State<DownloadOptionsSheet> {
  DownloadType _selectedType = DownloadType.videoWithAudio;
  VideoQualityOption? _selectedVideoQuality;
  AudioQualityOption? _selectedAudioQuality;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final locals = S.of(context);

    return BlocBuilder<DownloadBloc, DownloadState>(
      buildWhen: (previous, current) =>
          previous.fetchOptionsStatus != current.fetchOptionsStatus ||
          previous.downloadOptions != current.downloadOptions,
      builder: (context, state) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: AppRadius.topXl,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  margin: const EdgeInsets.only(top: AppSpacing.md),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.dividerDark : AppColors.divider,
                    borderRadius: AppRadius.borderFull,
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.arrow_down_circle_fill,
                        color: AppColors.primary,
                        size: AppIconSize.lg,
                      ),
                      AppSpacing.width12,
                      Text(
                        locals.download,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          CupertinoIcons.xmark_circle_fill,
                          color: isDark
                              ? AppColors.onSurfaceVariantDark
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Video preview
                _buildVideoPreview(isDark),

                AppSpacing.height16,

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: state.fetchOptionsStatus == ApiStatus.loading
                        ? _buildLoading()
                        : state.fetchOptionsStatus == ApiStatus.error
                            ? _buildError(state.errorMessage, isDark, locals)
                            : state.downloadOptions != null
                                ? _buildOptions(state.downloadOptions!, isDark, locals)
                                : _buildLoading(),
                  ),
                ),

                // Download button
                if (state.downloadOptions != null)
                  _buildDownloadButton(context, state.downloadOptions!, isDark, locals),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVideoPreview(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: AppRadius.borderMd,
            child: widget.thumbnailUrl != null
                ? ThumbnailImage.small(
                    url: widget.thumbnailUrl!,
                    width: 120,
                    height: 68,
                  )
                : Container(
                    width: 120,
                    height: 68,
                    color: isDark
                        ? AppColors.surfaceVariantDark
                        : AppColors.surfaceVariant,
                    child: const Icon(CupertinoIcons.play_rectangle),
                  ),
          ),
          AppSpacing.width12,
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.onSurfaceDark : AppColors.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.height4,
                Text(
                  widget.channelName,
                  style: TextStyle(
                    fontSize: AppFontSize.caption,
                    color: isDark
                        ? AppColors.onSurfaceVariantDark
                        : AppColors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.xxxl),
      child: Center(
        child: CircularProgressIndicator(strokeWidth: 2.5),
      ),
    );
  }

  Widget _buildError(String? error, bool isDark, S locals) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Icon(
            CupertinoIcons.exclamationmark_triangle,
            size: 48,
            color: AppColors.error,
          ),
          AppSpacing.height16,
          Text(
            error ?? locals.unknownError,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? AppColors.onSurfaceDark : AppColors.onSurface,
            ),
          ),
          AppSpacing.height16,
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildOptions(DownloadOptions options, bool isDark, S locals) {
    // Auto-select best quality on first build
    _selectedVideoQuality ??= options.bestVideoQuality;
    _selectedAudioQuality ??= options.bestAudioQuality;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Download type selector
        Text(
          locals.downloadType,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.onSurfaceDark : AppColors.onSurface,
          ),
        ),
        AppSpacing.height8,
        _buildTypeSelector(isDark, locals),

        AppSpacing.height20,

        // Video quality selector (if applicable)
        if (_selectedType != DownloadType.audioOnly && options.hasVideoOptions) ...[
          Text(
            locals.videoQuality,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.onSurfaceDark : AppColors.onSurface,
            ),
          ),
          AppSpacing.height8,
          _buildVideoQualitySelector(options.videoQualities, isDark),
          AppSpacing.height20,
        ],

        // Audio quality selector (if applicable)
        if (_selectedType != DownloadType.videoOnly && options.hasAudioOptions) ...[
          Text(
            locals.audioQuality,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.onSurfaceDark : AppColors.onSurface,
            ),
          ),
          AppSpacing.height8,
          _buildAudioQualitySelector(options.audioQualities, isDark),
          AppSpacing.height20,
        ],
      ],
    );
  }

  Widget _buildTypeSelector(bool isDark, S locals) {
    return Row(
      children: [
        _buildTypeChip(
          DownloadType.videoWithAudio,
          locals.videoWithAudio,
          CupertinoIcons.play_rectangle_fill,
          isDark,
        ),
        AppSpacing.width8,
        _buildTypeChip(
          DownloadType.videoOnly,
          locals.videoOnly,
          CupertinoIcons.videocam_fill,
          isDark,
        ),
        AppSpacing.width8,
        _buildTypeChip(
          DownloadType.audioOnly,
          locals.audioOnly,
          CupertinoIcons.music_note_2,
          isDark,
        ),
      ],
    );
  }

  Widget _buildTypeChip(
    DownloadType type,
    String label,
    IconData icon,
    bool isDark,
  ) {
    final isSelected = _selectedType == type;

    return Expanded(
      child: ScaleTap(
        onTap: () => setState(() => _selectedType = type),
        child: AnimatedContainer(
          duration: AppAnimations.fast,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.15)
                : isDark
                    ? AppColors.surfaceVariantDark
                    : AppColors.surfaceVariant,
            borderRadius: AppRadius.borderMd,
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppColors.primary
                    : isDark
                        ? AppColors.onSurfaceVariantDark
                        : AppColors.onSurfaceVariant,
                size: AppIconSize.md,
              ),
              AppSpacing.height4,
              Text(
                label,
                style: TextStyle(
                  fontSize: AppFontSize.caption,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? AppColors.primary
                      : isDark
                          ? AppColors.onSurfaceVariantDark
                          : AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoQualitySelector(
    List<VideoQualityOption> qualities,
    bool isDark,
  ) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 250),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
        borderRadius: AppRadius.borderMd,
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: qualities.length,
        itemBuilder: (context, index) {
          final quality = qualities[index];
          final isSelected = _selectedVideoQuality?.url == quality.url;
          final isLast = index == qualities.length - 1;
          return ScaleTap(
            onTap: () => setState(() => _selectedVideoQuality = quality),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
                border: isLast
                    ? null
                    : Border(
                        bottom: BorderSide(
                          color: isDark ? AppColors.dividerDark : AppColors.divider,
                          width: 0.5,
                        ),
                      ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? CupertinoIcons.checkmark_circle_fill
                        : CupertinoIcons.circle,
                    color: isSelected
                        ? AppColors.primary
                        : isDark
                            ? AppColors.onSurfaceVariantDark
                            : AppColors.onSurfaceVariant,
                    size: AppIconSize.sm,
                  ),
                  AppSpacing.width12,
                  Expanded(
                    child: Text(
                      quality.label,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isDark
                            ? AppColors.onSurfaceDark
                            : AppColors.onSurface,
                      ),
                    ),
                  ),
                  if (quality.formattedSize.isNotEmpty)
                    Text(
                      quality.formattedSize,
                      style: TextStyle(
                        fontSize: AppFontSize.caption,
                        color: isDark
                            ? AppColors.onSurfaceVariantDark
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAudioQualitySelector(
    List<AudioQualityOption> qualities,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
        borderRadius: AppRadius.borderMd,
      ),
      child: Column(
        children: qualities.take(3).map((quality) {
          final isSelected = _selectedAudioQuality?.url == quality.url;
          return ScaleTap(
            onTap: () => setState(() => _selectedAudioQuality = quality),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.dividerDark : AppColors.divider,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? CupertinoIcons.checkmark_circle_fill
                        : CupertinoIcons.circle,
                    color: isSelected
                        ? AppColors.primary
                        : isDark
                            ? AppColors.onSurfaceVariantDark
                            : AppColors.onSurfaceVariant,
                    size: AppIconSize.sm,
                  ),
                  AppSpacing.width12,
                  Expanded(
                    child: Text(
                      quality.displayLabel,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isDark
                            ? AppColors.onSurfaceDark
                            : AppColors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDownloadButton(
    BuildContext context,
    DownloadOptions options,
    bool isDark,
    S locals,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: ScaleTap(
        onTap: () => _startDownload(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: AppRadius.borderMd,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                CupertinoIcons.arrow_down_circle_fill,
                color: Colors.white,
              ),
              AppSpacing.width8,
              Text(
                locals.startDownload,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: AppFontSize.body1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startDownload(BuildContext context) {
    final profileName =
        context.read<SettingsBloc>().state.currentProfile;

    context.read<DownloadBloc>().add(
          DownloadEvent.startDownload(
            videoId: widget.videoId,
            title: widget.title,
            channelName: widget.channelName,
            downloadType: _selectedType,
            profileName: profileName,
            thumbnailUrl: widget.thumbnailUrl,
            duration: widget.duration,
            videoQuality: _selectedType != DownloadType.audioOnly
                ? _selectedVideoQuality
                : null,
            audioQuality: _selectedType != DownloadType.videoOnly
                ? _selectedAudioQuality
                : null,
          ),
        );

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.of(context).downloadStarted),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
