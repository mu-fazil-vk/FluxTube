import 'package:flutter/material.dart';
import 'package:fluxtube/domain/watch/models/explode/explode_watch.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:simple_html_css/simple_html_css.dart';

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
    return SizedBox(
      height: _height * 0.40,
      child: SingleChildScrollView(
        child: RichText(
          text: HTML.toTextSpan(
              context, watchInfo.description,
              defaultTextStyle: Theme.of(context).textTheme.bodyMedium),
        ),
      ),
    );
  }
}
