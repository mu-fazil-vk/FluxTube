import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/colors.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.count = 0,
  });

  final String title;

  //saved videos count
  final int count;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      toolbarHeight: 60,
      elevation: 0,
      surfaceTintColor: kWhiteColor,
      title: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Text(
          title,
          style: GoogleFonts.knewave(
            color: kRedColor,
          ),
        ),
      ),
      actions: count != 0
          ? [
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10, right: 20),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: kGreyOpacityColor),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      '$count',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              )
            ]
          : [],
    );
  }
}
