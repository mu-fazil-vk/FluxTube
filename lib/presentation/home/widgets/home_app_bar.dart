import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/app_info.dart';
import '../../../core/colors.dart';
import '../../../core/constants.dart';
import '../../search/screen_search.dart';
import 'circular_icon.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      toolbarHeight: 60,
      elevation: 0,
      surfaceTintColor: kWhiteColor,
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      title: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Text(
          AppInfo.myApp.name,
          style: const TextStyle(fontFamily: 'Knewave', color: kRedColor),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const ScreenSearch(),
          )),
          child: const CircularIcon(
            icon: CupertinoIcons.search,
          ),
        ),
        kWidthBox20,
      ],
    );
  }
}
