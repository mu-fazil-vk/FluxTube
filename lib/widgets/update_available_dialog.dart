import 'package:flutter/material.dart';
import 'package:fluxtube/core/animations/animations.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/core/services/update_checker.dart';
import 'package:fluxtube/domain/update/update_info.dart';

/// Shows the "update available" popup.
///
/// [showThreeButtons] switches between the two call sites' button sets:
///  * `false` (manual "Check for Updates" tap) — Close / Download.
///  * `true` (automatic startup check) — Later / Update / Never show again,
///    the last styled as a destructive action since it's a permanent opt-out.
Future<void> showUpdateAvailableDialog(
  BuildContext context, {
  required UpdateInfo info,
  required bool showThreeButtons,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Update available',
    barrierColor: Colors.black.withValues(alpha: 0.6),
    transitionDuration: AppAnimations.medium,
    pageBuilder: (context, animation, secondaryAnimation) {
      return _UpdateAvailableDialog(
          info: info, showThreeButtons: showThreeButtons);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved =
          CurvedAnimation(parent: animation, curve: AppAnimations.bounceCurve);
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.85, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _UpdateAvailableDialog extends StatelessWidget {
  const _UpdateAvailableDialog(
      {required this.info, required this.showThreeButtons});

  final UpdateInfo info;
  final bool showThreeButtons;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.xxl),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: AppRadius.borderXl,
          border:
              Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.18),
              blurRadius: 40,
              spreadRadius: -8,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xxl,
                  AppSpacing.xxl, AppSpacing.lg),
              child: Column(
                children: [
                  _AnimatedBadge(color: scheme.primary),
                  AppSpacing.height16,
                  Text(
                    'Update Available',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.height4,
                  Text(
                    info.releaseName.isNotEmpty
                        ? info.releaseName
                        : 'v${info.version}',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            if (info.changelog.isNotEmpty)
              Flexible(
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  constraints: const BoxConstraints(maxHeight: 260),
                  decoration: BoxDecoration(
                    color:
                        scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: AppRadius.borderLg,
                  ),
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      child: _ChangelogText(text: info.changelog),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: showThreeButtons
                  ? _ThreeButtonRow(info: info)
                  : _TwoButtonRow(info: info),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedBadge extends StatefulWidget {
  const _AnimatedBadge({required this.color});

  final Color color;

  @override
  State<_AnimatedBadge> createState() => _AnimatedBadgeState();
}

class _AnimatedBadgeState extends State<_AnimatedBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final glow = 0.25 + (_controller.value * 0.25);
        return Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(alpha: 0.15),
            boxShadow: [
              BoxShadow(
                  color: widget.color.withValues(alpha: glow),
                  blurRadius: 24,
                  spreadRadius: 2),
            ],
          ),
          child: Icon(Icons.rocket_launch_rounded,
              color: widget.color, size: AppIconSize.xl),
        );
      },
    );
  }
}

/// A tiny, non-exhaustive renderer for GitHub release notes: `#`/`##`
/// headings, `-`/`*` bullets, `**bold**` spans, plain paragraphs otherwise.
/// A full CommonMark parser would be overkill for something this
/// structurally simple, and hand-rolling it keeps the styling exactly on the
/// app's own design tokens instead of a package's default stylesheet.
class _ChangelogText extends StatelessWidget {
  const _ChangelogText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final rawLine in lines) ...[
          _buildLine(rawLine.trim(), theme, scheme),
          AppSpacing.height4,
        ],
      ],
    );
  }

  Widget _buildLine(String line, ThemeData theme, ColorScheme scheme) {
    if (line.startsWith('#')) {
      final heading = line.replaceFirst(RegExp(r'^#+\s*'), '');
      return Padding(
        padding:
            const EdgeInsets.only(top: AppSpacing.xs, bottom: AppSpacing.xxs),
        child: _richBold(
          heading,
          theme.textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.w800, color: scheme.onSurface),
        ),
      );
    }
    if (line.startsWith('- ') || line.startsWith('* ')) {
      return Padding(
        padding: const EdgeInsets.only(left: AppSpacing.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('•  ',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: scheme.primary)),
            Expanded(
              child: _richBold(
                line.substring(2),
                theme.textTheme.bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      );
    }
    return _richBold(line,
        theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant));
  }

  Widget _richBold(String line, TextStyle? baseStyle) {
    final spans = <TextSpan>[];
    final pattern = RegExp(r'\*\*(.+?)\*\*');
    var last = 0;
    for (final match in pattern.allMatches(line)) {
      if (match.start > last) {
        spans.add(TextSpan(text: line.substring(last, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.w700),
      ));
      last = match.end;
    }
    if (last < line.length) spans.add(TextSpan(text: line.substring(last)));
    return Text.rich(TextSpan(style: baseStyle, children: spans));
  }
}

class _TwoButtonRow extends StatelessWidget {
  const _TwoButtonRow({required this.info});

  final UpdateInfo info;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              foregroundColor: scheme.onSurfaceVariant,
            ),
            child: const Text('Close'),
          ),
        ),
        AppSpacing.width12,
        Expanded(
          flex: 2,
          child: ScaleTap(
            onTap: () {
              Navigator.of(context).pop();
              UpdateChecker().openRelease(info.htmlUrl);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: scheme.primary, borderRadius: AppRadius.borderFull),
              child: Text(
                'Download',
                style: TextStyle(
                    color: scheme.onPrimary, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ThreeButtonRow extends StatelessWidget {
  const _ThreeButtonRow({required this.info});

  final UpdateInfo info;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  foregroundColor: scheme.onSurfaceVariant,
                ),
                child: const Text('Later'),
              ),
            ),
            AppSpacing.width12,
            Expanded(
              flex: 2,
              child: ScaleTap(
                onTap: () {
                  Navigator.of(context).pop();
                  UpdateChecker().openRelease(info.htmlUrl);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: AppRadius.borderFull),
                  child: Text(
                    'Update',
                    style: TextStyle(
                        color: scheme.onPrimary, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
        AppSpacing.height8,
        TextButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            UpdateChecker().neverShowAgain();
          },
          style: TextButton.styleFrom(foregroundColor: scheme.error),
          icon: Icon(Icons.warning_amber_rounded,
              size: AppIconSize.sm, color: scheme.error),
          label: const Text('Never show again'),
        ),
      ],
    );
  }
}
