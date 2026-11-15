import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/core/player/global_player_controller.dart';
import 'package:fluxtube/core/strings.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:share_plus/share_plus.dart';

/// Modern share bottom sheet with multiple sharing options
class ShareBottomSheet extends StatefulWidget {
  const ShareBottomSheet({
    super.key,
    required this.videoId,
    required this.videoTitle,
    this.thumbnailUrl,
  });

  final String videoId;
  final String videoTitle;
  final String? thumbnailUrl;

  /// Show the share bottom sheet
  static Future<void> show(
    BuildContext context, {
    required String videoId,
    required String videoTitle,
    String? thumbnailUrl,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.scrim,
      builder: (context) => ShareBottomSheet(
        videoId: videoId,
        videoTitle: videoTitle,
        thumbnailUrl: thumbnailUrl,
      ),
    );
  }

  @override
  State<ShareBottomSheet> createState() => _ShareBottomSheetState();
}

class _ShareBottomSheetState extends State<ShareBottomSheet> {
  bool _includeTitle = false;
  bool _includeTimestamp = false;
  late final int _positionSeconds = _currentPositionSeconds();

  int _currentPositionSeconds() {
    final player = GlobalPlayerController();
    if (player.currentVideoId != widget.videoId) return 0;
    return player.livePosition.inSeconds;
  }

  String get _videoUrl => _includeTimestamp && _positionSeconds > 0
      ? '$kYTBaseUrl${widget.videoId}&t=${_positionSeconds}s'
      : '$kYTBaseUrl${widget.videoId}';

  static String _formatTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = (seconds % 60).toString().padLeft(2, '0');
    return h > 0 ? '$h:${m.toString().padLeft(2, '0')}:$s' : '$m:$s';
  }

  String get _shareContent {
    if (_includeTitle) {
      return '${widget.videoTitle}\n\n$_videoUrl';
    }
    return _videoUrl;
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _shareContent));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.of(context).copiedToClipboard),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareNative() async {
    Navigator.pop(context);
    await SharePlus.instance.share(ShareParams(text: _shareContent));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final locals = S.of(context);

    return Container(
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
            _DragHandle(),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.share,
                    size: AppIconSize.md,
                    color: isDark
                        ? AppColors.onSurfaceDark
                        : AppColors.onSurface,
                  ),
                  AppSpacing.width12,
                  Text(
                    locals.share,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Video preview card
            _VideoPreviewCard(
              title: widget.videoTitle,
              url: _videoUrl,
              thumbnailUrl: widget.thumbnailUrl,
              isDark: isDark,
            ),

            AppSpacing.height16,

            // Include title toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _ToggleOption(
                label: locals.includeTitle,
                value: _includeTitle,
                onChanged: (value) => setState(() => _includeTitle = value),
                isDark: isDark,
              ),
            ),

            if (_positionSeconds >= 5)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: _ToggleOption(
                  label: 'Start at ${_formatTime(_positionSeconds)}',
                  value: _includeTimestamp,
                  onChanged: (value) =>
                      setState(() => _includeTimestamp = value),
                  isDark: isDark,
                ),
              ),

            AppSpacing.height20,

            // Share options grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _ShareOptionButton(
                      icon: CupertinoIcons.doc_on_clipboard,
                      label: locals.copyLink,
                      onTap: _copyToClipboard,
                      isDark: isDark,
                    ),
                  ),
                  AppSpacing.width12,
                  Expanded(
                    child: _ShareOptionButton(
                      icon: CupertinoIcons.share,
                      label: locals.shareVia,
                      onTap: _shareNative,
                      isDark: isDark,
                      isPrimary: true,
                    ),
                  ),
                ],
              ),
            ),

            AppSpacing.height24,
          ],
        ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: isDark ? AppColors.dividerDark : AppColors.divider,
        borderRadius: AppRadius.borderFull,
      ),
    );
  }
}

class _VideoPreviewCard extends StatelessWidget {
  const _VideoPreviewCard({
    required this.title,
    required this.url,
    this.thumbnailUrl,
    required this.isDark,
  });

  final String title;
  final String url;
  final String? thumbnailUrl;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
        borderRadius: AppRadius.borderMd,
      ),
      child: Row(
        children: [
          // Thumbnail
          if (thumbnailUrl != null)
            ClipRRect(
              borderRadius: AppRadius.borderSm,
              child: Image.network(
                thumbnailUrl!,
                width: 80,
                height: 45,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 80,
                  height: 45,
                  color: isDark ? AppColors.dividerDark : AppColors.divider,
                  child: Icon(
                    CupertinoIcons.play_rectangle_fill,
                    color: isDark
                        ? AppColors.onSurfaceVariantDark
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          if (thumbnailUrl != null) AppSpacing.width12,
          // Title and URL
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppFontSize.body2,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.onSurfaceDark
                        : AppColors.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  url,
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
}

class _ToggleOption extends StatelessWidget {
  const _ToggleOption({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: AppRadius.borderMd,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
          borderRadius: AppRadius.borderMd,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: AppFontSize.body1,
                  color: isDark
                      ? AppColors.onSurfaceDark
                      : AppColors.onSurface,
                ),
              ),
            ),
            SizedBox(
              height: 24,
              width: 44,
              child: Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeTrackColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareOptionButton extends StatelessWidget {
  const _ShareOptionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
    this.isPrimary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isPrimary
        ? AppColors.primary
        : (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant);
    final foregroundColor = isPrimary
        ? AppColors.onPrimary
        : (isDark ? AppColors.onSurfaceDark : AppColors.onSurface);

    return Material(
      color: backgroundColor,
      borderRadius: AppRadius.borderMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderMd,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: AppIconSize.sm,
                color: foregroundColor,
              ),
              AppSpacing.width8,
              Text(
                label,
                style: TextStyle(
                  fontSize: AppFontSize.body2,
                  fontWeight: FontWeight.w600,
                  color: foregroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
