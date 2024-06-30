//icon inside a circle
import 'package:flutter/material.dart';

import '../../../core/colors.dart';

class CircularIcon extends StatelessWidget {
  final IconData icon;
  final double radius;
  const CircularIcon({
    super.key,
    required this.icon,
    this.radius = 22,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: kGreyOpacityColor,
      child: Icon(
        icon,
        size: 26,
        color: Theme.of(context).iconTheme.color,
      ),
    );
  }
}
