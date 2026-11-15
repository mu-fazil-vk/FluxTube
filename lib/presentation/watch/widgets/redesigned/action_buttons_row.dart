import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluxtube/application/settings/settings_bloc.dart';
import 'package:fluxtube/core/animations/animations.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/core/operations/math_operations.dart';
import 'package:fluxtube/core/services/ryd_service.dart';
import 'package:fluxtube/generated/l10n.dart';

/// Redesigned action buttons row with labeled style (like YouTube)
/// Each button has an icon on top and label text below
class ActionButtonsRow extends StatelessWidget {
  const ActionButtonsRow({
    super.key,
    required this.likes,
    this.dislikes = 0,
    this.onTapLike,
    this.onTapDislike,
    this.onTapSave,
    this.onTapComment,
    this.onTapShare,
    this.onTapDownload,
    this.onTapYoutube,
    this.onTapPip,
    this.isLiked = false,
    this.isDisliked = false,
    this.isSaved = false,
    this.isCommentActive = false,
    this.isDownloaded = false,
    this.showDislike = false,
    this.showPip = true,
    this.isLive = false,
    this.videoId,
  });

  final int likes;
  final int dislikes;
  final VoidCallback? onTapLike;
  final VoidCallback? onTapDislike;
  final VoidCallback? onTapSave;
  final VoidCallback? onTapComment;
  final VoidCallback? onTapShare;
  final VoidCallback? onTapDownload;
  final VoidCallback? onTapYoutube;
  final VoidCallback? onTapPip;
  final bool isLiked;
  final bool isDisliked;
  final bool isSaved;
  final bool isCommentActive;
  final bool isDownloaded;
  final bool showDislike;
  final bool showPip;
  final bool isLive;

  /// When set and the backend has no dislike count, the count is looked up
  /// from Return YouTube Dislike.
  final String? videoId;

  Widget _buildDislike(String label) {
    return _ActionButton(
      index: 1,
      icon: isDisliked
          ? CupertinoIcons.hand_thumbsdown_fill
          : CupertinoIcons.hand_thumbsdown,
      label: label,
      onTap: onTapDislike,
      isActive: isDisliked,
    );
  }

  @override
  Widget build(BuildContext context) {
    final locals = S.of(context);
    final formattedLikes =
        likes == -1 ? locals.like : formatCount(likes.toString());
    final formattedDislikes =
        dislikes == -1 ? locals.dislike : formatCount(dislikes.toString());

    return SizedBox(
      height: 70,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            // Like button
            _ActionButton(
              index: 0,
              icon: isLiked
                  ? CupertinoIcons.hand_thumbsup_fill
                  : CupertinoIcons.hand_thumbsup,
              label: formattedLikes,
              onTap: onTapLike,
              isActive: isLiked,
              activeColor: AppColors.likeFilled,
            ),

            // Dislike button (optional)
            if (showDislike)
              (dislikes > 0 || videoId == null)
                  ? _buildDislike(formattedDislikes)
                  : FutureBuilder<int?>(
                      future: RydService.instance.dislikes(videoId!),
                      builder: (context, snapshot) {
                        final count = snapshot.data;
                        return _buildDislike(count == null
                            ? formattedDislikes
                            : formatCount(count.toString()));
                      },
                    ),

            // Save button
            _ActionButton(
              index: showDislike ? 2 : 1,
              icon: isSaved
                  ? CupertinoIcons.bookmark_fill
                  : CupertinoIcons.bookmark,
              label: isSaved ? locals.saved : locals.save,
              onTap: onTapSave,
              isActive: isSaved,
            ),

            // Comments button (controlled by settings)
            BlocBuilder<SettingsBloc, SettingsState>(
              buildWhen: (previous, current) =>
                  previous.isHideComments != current.isHideComments,
              builder: (context, settingsState) {
                if (!settingsState.isHideComments) {
                  return _ActionButton(
                    index: showDislike ? 3 : 2,
                    icon: isCommentActive
                        ? CupertinoIcons.bubble_left_bubble_right_fill
                        : CupertinoIcons.bubble_left_bubble_right,
                    label: 'Comments',
                    onTap: onTapComment,
                    isActive: isCommentActive,
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Share button
            _ActionButton(
              index: showDislike ? 4 : 3,
              icon: CupertinoIcons.arrowshape_turn_up_right,
              label: locals.share,
              onTap: onTapShare,
            ),

            // Download button (hidden for live videos)
            if (!isLive)
              _ActionButton(
                index: showDislike ? 5 : 4,
                icon: isDownloaded
                    ? CupertinoIcons.arrow_down_circle_fill
                    : CupertinoIcons.arrow_down_circle,
                label: locals.download,
                onTap: onTapDownload,
                isActive: isDownloaded,
                activeColor: AppColors.success,
              ),

            // PiP button (optional)
            if (showPip)
              _ActionButton(
                index: showDislike ? 6 : 5,
                icon: Icons.picture_in_picture_outlined,
                label: 'PiP',
                onTap: onTapPip,
              ),

            // YouTube button
            _YouTubeActionButton(
              index: showDislike ? 7 : 6,
              onTap: onTapYoutube,
            ),

            AppSpacing.width16,
          ],
        ),
      ),
    );
  }
}

/// Individual action button with icon and label
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.index,
    required this.icon,
    required this.label,
    this.onTap,
    this.isActive = false,
    this.activeColor,
  });

  final int index;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isActive;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final defaultColor = colorScheme.onSurfaceVariant;
    final iconColor =
        isActive ? (activeColor ?? colorScheme.primary) : defaultColor;
    final labelColor =
        isActive ? (activeColor ?? colorScheme.primary) : defaultColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: ScaleTap(
        onTap: onTap,
        scaleDown: 0.9,
        child: AnimatedContainer(
          duration: AppAnimations.fast,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? (activeColor ?? colorScheme.primary).withValues(alpha: 0.12)
                : colorScheme.surfaceContainerHigh,
            // A tall icon-over-label chip reads oddly with a full pill
            // radius (that shape assumes a wide, short chip) — a smaller
            // rounded-rect radius matches the actual proportions here.
            borderRadius: AppRadius.borderLg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: AppAnimations.fast,
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: child,
                  );
                },
                child: Icon(
                  icon,
                  key: ValueKey('$icon$isActive'),
                  size: AppIconSize.md,
                  color: iconColor,
                ),
              ),
              AppSpacing.height4,
              Text(
                label,
                style: TextStyle(
                  fontSize: AppFontSize.caption,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: labelColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// YouTube-specific button with SVG icon
class _YouTubeActionButton extends StatelessWidget {
  const _YouTubeActionButton({
    required this.index,
    this.onTap,
  });

  final int index;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final defaultColor = colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: ScaleTap(
        onTap: onTap,
        scaleDown: 0.9,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: AppRadius.borderLg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Neutral, same as every other icon in this row by default —
              // a permanently-brand-red icon stood out as the only "active
              // looking" button while doing nothing active, breaking the
              // row's own color-means-active-state convention.
              SvgPicture.asset(
                'assets/icons/youtube.svg',
                height: AppIconSize.md,
                colorFilter: ColorFilter.mode(
                  defaultColor,
                  BlendMode.srcIn,
                ),
              ),
              AppSpacing.height4,
              Text(
                'YouTube',
                style: TextStyle(
                  fontSize: AppFontSize.caption,
                  fontWeight: FontWeight.w500,
                  color: defaultColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact version for landscape mode
class ActionButtonsRowCompact extends StatelessWidget {
  const ActionButtonsRowCompact({
    super.key,
    required this.likes,
    this.onTapLike,
    this.onTapSave,
    this.onTapShare,
    this.isLiked = false,
    this.isSaved = false,
  });

  final int likes;
  final VoidCallback? onTapLike;
  final VoidCallback? onTapSave;
  final VoidCallback? onTapShare;
  final bool isLiked;
  final bool isSaved;

  @override
  Widget build(BuildContext context) {
    final locals = S.of(context);
    final formattedLikes =
        likes == -1 ? locals.like : formatCount(likes.toString());

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CompactButton(
          icon: isLiked
              ? CupertinoIcons.hand_thumbsup_fill
              : CupertinoIcons.hand_thumbsup,
          label: formattedLikes,
          onTap: onTapLike,
          isActive: isLiked,
          activeColor: AppColors.likeFilled,
        ),
        AppSpacing.width8,
        _CompactButton(
          icon:
              isSaved ? CupertinoIcons.bookmark_fill : CupertinoIcons.bookmark,
          onTap: onTapSave,
          isActive: isSaved,
        ),
        AppSpacing.width8,
        _CompactButton(
          icon: CupertinoIcons.arrowshape_turn_up_right,
          onTap: onTapShare,
        ),
      ],
    );
  }
}

class _CompactButton extends StatelessWidget {
  const _CompactButton({
    required this.icon,
    this.label,
    this.onTap,
    this.isActive = false,
    this.activeColor,
  });

  final IconData icon;
  final String? label;
  final VoidCallback? onTap;
  final bool isActive;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final defaultColor = colorScheme.onSurfaceVariant;
    final iconColor =
        isActive ? (activeColor ?? colorScheme.primary) : defaultColor;

    return ScaleTap(
      onTap: onTap,
      scaleDown: 0.9,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? (activeColor ?? colorScheme.primary).withValues(alpha: 0.12)
              : colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
          borderRadius: AppRadius.borderSm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppIconSize.sm,
              color: iconColor,
            ),
            if (label != null) ...[
              AppSpacing.width4,
              Text(
                label!,
                style: TextStyle(
                  fontSize: AppFontSize.caption,
                  fontWeight: FontWeight.w500,
                  color: iconColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
