import 'package:flutter/material.dart';

class SubSettingAppBar extends StatelessWidget {
  const SubSettingAppBar({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      foregroundColor: theme.iconTheme.color,
      title: Text(
        title,
        style: theme.textTheme.bodyLarge!
            .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
