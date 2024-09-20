import 'package:flutter/material.dart';
import 'package:fluxtube/domain/watch/models/invidious/video/invidious_watch_resp.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:simple_html_css/simple_html_css.dart';

class InvidiousDescriptionSection extends StatelessWidget {
  const InvidiousDescriptionSection({
    super.key,
    required double height,
    required this.watchInfo,
    required this.locals,
  }) : _height = height;

  final double _height;
  final InvidiousWatchResp watchInfo;
  final S locals;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height * 0.40,
      child: SingleChildScrollView(
        child: RichText(
          text: HTML.toTextSpan(
              context, watchInfo.description ?? locals.noVideoDescription,
              defaultTextStyle: Theme.of(context).textTheme.bodyMedium),
        ),
      ),
    );
  }
}
