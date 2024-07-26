import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

class CustomRoundedSvgButtons extends StatelessWidget {
  const CustomRoundedSvgButtons({
    super.key,
    required this.iconPath,
    this.onTap,
    this.isTapped = false,
  });

  final String iconPath;
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
          icon: SvgPicture.asset(
            iconPath,
            height: 25,
            colorFilter: ColorFilter.mode(kGreyColor!, BlendMode.srcIn),
          )),
    );
  }
}
