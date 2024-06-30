import 'package:flutter/material.dart';

import '../../../core/colors.dart';

class CustomRoundedButtons extends StatelessWidget {
  const CustomRoundedButtons({
    super.key,
    required this.icon,
    this.onTap,
    this.isTapped = false,
  });

  final IconData icon;
  final bool isTapped;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      child: IconButton(
          color: isTapped ? kBlueColor : kGreyColor,
          style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(
                  isTapped ? kBlueOpacityColor : kGreyOpacityColor)),
          onPressed: onTap,
          icon: Icon(
            icon,
          )),
    );
  }
}
