import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:fluxtube/core/locals.dart';
import 'package:fluxtube/core/model/language_model.dart';
import 'package:fluxtube/core/model/region_model.dart';
import 'package:fluxtube/core/regions.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/presentation/settings/widgets/about_section.dart';
import 'package:fluxtube/presentation/settings/widgets/common_section.dart';
import 'package:fluxtube/presentation/settings/widgets/distraction_section.dart';
import 'package:fluxtube/presentation/settings/widgets/video_settings_secction.dart';

import '../../application/settings/settings_bloc.dart';
import '../../widgets/custom_app_bar.dart';

class ScreenSettings extends StatelessWidget {
  const ScreenSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final locals = S.of(context);
    BlocProvider.of<SettingsBloc>(context)
        .add(SettingsEvent.initializeSettings());
    return SafeArea(
        child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  CustomAppBar(
                    title: locals.settings,
                  )
                ],
            body: BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, state) {
                // get language name by using language code
                final language = languages.firstWhere(
                  (name) => name.code == state.defaultLanguage,
                  orElse: () =>
                      LanguageModel(name: locals.unknown, code: locals.unknown),
                );
                // get region name by using region code
                final region = regions.firstWhere(
                  (name) => name.code == state.defaultRegion,
                  orElse: () =>
                      RegionModel(name: locals.unknown, code: locals.unknown),
                );
                return SettingsList(
                  lightTheme: const SettingsThemeData(
                      settingsListBackground: kWhiteColor),
                  darkTheme:
                      SettingsThemeData(settingsListBackground: kDarkColor),
                  sections: [
                    // COMMON SETTINGS
                    commonSettingsSection(
                        locals, context, language, region, state),

                    // VIDEO SETTINGS
                    videoSettingsSection(locals, context, state),

                    distractionFreeSettingsSection(locals, context, state),

                    // ABOUT SECTION
                    aboutSection(locals, context, state),
                  ],
                );
              },
            )));
  }
}
