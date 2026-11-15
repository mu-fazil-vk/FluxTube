import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/domain/watch/models/explode/explode_watch.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

class ExplodeDescriptionSection extends StatelessWidget {
  const ExplodeDescriptionSection({
    super.key,
    required double height,
    required this.watchInfo,
    required this.locals,
  }) : _height = height;

  final double _height;
  final ExplodeWatchResp watchInfo;
  final S locals;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = watchInfo.description.isEmpty
        ? locals.noVideoDescription
        : watchInfo.description;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: AppRadius.borderLg,
      ),
      child: SizedBox(
        height: _height * 0.40,
        child: SingleChildScrollView(
          child: SelectableText.rich(
            _buildDescriptionSpan(context, description, theme),
          ),
        ),
      ),
    );
  }

  TextSpan _buildDescriptionSpan(
      BuildContext context, String text, ThemeData theme) {
    // Decode HTML entities
    String decoded = text
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '');

    final urlPattern = RegExp(r'https?://[^\s<>\[\]]+', caseSensitive: false);
    final List<InlineSpan> spans = [];
    int lastEnd = 0;

    for (final match in urlPattern.allMatches(decoded)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: decoded.substring(lastEnd, match.start),
          style: theme.textTheme.bodyMedium,
        ));
      }

      final url = match.group(0)!;
      spans.add(TextSpan(
        text: url,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.primary,
          decoration: TextDecoration.none,
        ),
        recognizer: TapGestureRecognizer()..onTap = () => _launchUrl(url),
      ));

      lastEnd = match.end;
    }

    if (lastEnd < decoded.length) {
      spans.add(TextSpan(
        text: decoded.substring(lastEnd),
        style: theme.textTheme.bodyMedium,
      ));
    }

    return TextSpan(children: spans);
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
