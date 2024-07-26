import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:fluxtube/generated/l10n.dart';

import '../../application/settings/settings_bloc.dart';
import '../home/screen_home.dart';
import '../saved/screen_saved.dart';
import '../settings/screen_settings.dart';
import '../trending/screen_trending.dart';

ValueNotifier<int> indexChangeNotifier = ValueNotifier(0);

class MainNavigation extends StatelessWidget {
  MainNavigation({super.key});

  final _pages = [
    const ScreenHome(),
    const ScreenTrending(),
    const ScreenSaved(),
    const ScreenSettings()
  ];

  @override
  Widget build(BuildContext context) {
    final locals = S.of(context);

    final List<TabItem> items = [
      TabItem(icon: CupertinoIcons.house_fill, title: locals.home, key: "home"),
      TabItem(
          icon: CupertinoIcons.flame_fill,
          title: locals.trending,
          key: "trending"),
      TabItem(
          icon: CupertinoIcons.bookmark_fill,
          title: locals.saved,
          key: "saved"),
      TabItem(
          icon: CupertinoIcons.settings,
          title: locals.settings,
          key: "settings"),
    ];

    return ValueListenableBuilder(
        valueListenable: indexChangeNotifier,
        builder: (BuildContext context, index, _) {
          return Scaffold(
            body: SafeArea(
              child: _pages[index],
            ),
            bottomNavigationBar: BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, state) {
                return BottomBarSalomon(
                  items: items,
                  top: 25,
                  bottom: 25,
                  iconSize: 26,
                  heightItem: 50,
                  backgroundColor: kTransparentColor,
                  color: kGreyColor!,
                  colorSelected: kRedColor,
                  backgroundSelected: kGreyOpacityColor!,
                  indexSelected: indexChangeNotifier.value,
                  titleStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      overflow: TextOverflow.ellipsis),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                  onTap: (int index) => indexChangeNotifier.value = index,
                );
              },
            ),
          );
        });
  }
}
