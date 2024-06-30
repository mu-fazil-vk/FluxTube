import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:readmore/readmore.dart';

// Function to create an annotation for a given HTML tag
Annotation createAnnotation({
  required String tag,
  required TextStyle Function(TextStyle? textStyle) styleBuilder,
}) {
  final openTag = '<$tag>';
  final closeTag = '</$tag>';
  return Annotation(
    regExp: RegExp('$openTag(.*?)$closeTag'),
    spanBuilder: ({required String text, TextStyle? textStyle}) => TextSpan(
      text: text,
      style: styleBuilder(textStyle),
    ),
  );
}

// Function to create an annotation for an HTML anchor tag
Annotation createLinkAnnotation() {
  return Annotation(
    regExp: RegExp(r'<a href="(.*?)">(.*?)<\/a>'),
    spanBuilder: ({required String text, TextStyle? textStyle}) {
      final matches = RegExp(r'<a href="(.*?)">(.*?)<\/a>').firstMatch(text);
      final url = matches?.group(1) ?? '';
      final linkText = matches?.group(2) ?? '';
      return TextSpan(
        text: linkText,
        style: textStyle?.copyWith(color: Colors.blue),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            // Handle URL tap
            if (kDebugMode) {
              print('Tapped on URL: $url');
            }
          },
      );
    },
  );
}

class HTMLText extends StatelessWidget {
  final String text;

  const HTMLText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final locals = S.of(context);
    final theme = Theme.of(context);
    return ReadMoreText(
      text,
      trimMode: TrimMode.Line,
      trimLines: 2,
      colorClickableText: kRedColor,
      moreStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      lessStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      trimCollapsedText: " ${locals.readMoreText}",
      trimExpandedText: " ${locals.showLessText}",
      style: theme.textTheme.bodyMedium,
      delimiter: '',
      delimiterStyle: const TextStyle(color: Colors.grey),
      annotations: [
        createAnnotation(
          tag: 'b',
          styleBuilder: (textStyle) =>
              textStyle?.copyWith(fontWeight: FontWeight.bold) ??
              const TextStyle(fontWeight: FontWeight.bold),
        ),
        createAnnotation(
          tag: 'i',
          styleBuilder: (textStyle) =>
              textStyle?.copyWith(fontStyle: FontStyle.italic) ??
              const TextStyle(fontStyle: FontStyle.italic),
        ),
        createAnnotation(
          tag: 'u',
          styleBuilder: (textStyle) =>
              textStyle?.copyWith(decoration: TextDecoration.underline) ??
              const TextStyle(decoration: TextDecoration.underline),
        ),
        createLinkAnnotation(),
        createAnnotation(
          tag: 'h1',
          styleBuilder: (textStyle) =>
              textStyle?.copyWith(fontSize: 24, fontWeight: FontWeight.bold) ??
              const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        createAnnotation(
          tag: 'h2',
          styleBuilder: (textStyle) =>
              textStyle?.copyWith(fontSize: 22, fontWeight: FontWeight.bold) ??
              const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        createAnnotation(
          tag: 'h3',
          styleBuilder: (textStyle) =>
              textStyle?.copyWith(fontSize: 20, fontWeight: FontWeight.bold) ??
              const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        createAnnotation(
          tag: 'h4',
          styleBuilder: (textStyle) =>
              textStyle?.copyWith(fontSize: 18, fontWeight: FontWeight.bold) ??
              const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        createAnnotation(
          tag: 'h5',
          styleBuilder: (textStyle) =>
              textStyle?.copyWith(fontSize: 16, fontWeight: FontWeight.bold) ??
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        createAnnotation(
          tag: 'h6',
          styleBuilder: (textStyle) =>
              textStyle?.copyWith(fontSize: 14, fontWeight: FontWeight.bold) ??
              const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        createAnnotation(
          tag: 'p',
          styleBuilder: (textStyle) => textStyle ?? const TextStyle(),
        ),
        Annotation(
          regExp: RegExp(r'<br>'),
          spanBuilder: ({required String text, TextStyle? textStyle}) =>
              TextSpan(
            text: '\n',
            style: textStyle,
          ),
        ),
        createAnnotation(
          tag: 'span',
          styleBuilder: (textStyle) => textStyle ?? const TextStyle(),
        ),
        // Handle &nbsp; (non-breaking space) entity
        Annotation(
          regExp: RegExp(r'&nbsp;'),
          spanBuilder: ({required String text, TextStyle? textStyle}) =>
              TextSpan(
            text: '\u00A0',
            style: textStyle,
          ),
        ),
        // Add other annotations as needed...
      ],
    );
  }
}
