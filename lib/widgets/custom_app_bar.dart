import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/presentation/home/widgets/circular_icon.dart';
import 'package:fluxtube/presentation/search/screen_search.dart';

import '../../../core/colors.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.count = 0,
    bool isSearchVisible = false,
  }) : _isSearchVisible = isSearchVisible;

  final String title;

  //saved videos count
  final int count;
  final bool _isSearchVisible;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      toolbarHeight: 60,
      elevation: 0,
      surfaceTintColor: kWhiteColor,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Text(
          title,
          style: const TextStyle(fontFamily: 'Knewave', color: kRedColor),
          // style: GoogleFonts.knewave(
          //   color: kRedColor,
          // ),
        ),
      ),
      actions: _isSearchVisible
          ? [
              GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const ScreenSearch(),
                )),
                child: const CircularIcon(
                  icon: CupertinoIcons.search,
                ),
              ),
              kWidthBox20,
            ]
          : count != 0
              ? [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 10, bottom: 10, right: 20),
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
