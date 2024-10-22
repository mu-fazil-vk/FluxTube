import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluxtube/generated/l10n.dart';

import '../../widgets/custom_app_bar.dart';
import 'widgets/widgets.dart';

class ScreenSettings extends StatelessWidget {
  const ScreenSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final locals = S.of(context);
    return SafeArea(
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          CustomAppBar(
            title: locals.settings,
          )
        ],
        body: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonSettingsSection(),
                DistractionFreeSettingsSection(),
                VideoSettingsSecction(),
                AboutSection()
              ],
            ),
          ),
        ),

        // return SettingsList(
        //   lightTheme:
        //       const SettingsThemeData(settingsListBackground: kWhiteColor),
        //   darkTheme: SettingsThemeData(settingsListBackground: kDarkColor),
        //   sections: [
        //     // COMMON SETTINGS
        //     //commonSettingsSection(locals, context, language, region, state),

        //     // VIDEO SETTINGS
        //     videoSettingsSection(locals, context, state),

        //     distractionFreeSettingsSection(locals, context, state),

        //     // ABOUT SECTION
        //     aboutSection(locals, context, state),
        //   ],
        // );
      ),
    );
  }
}
