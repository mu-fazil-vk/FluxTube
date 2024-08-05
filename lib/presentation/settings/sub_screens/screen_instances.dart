
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/settings/settings_bloc.dart';
import 'package:fluxtube/core/strings.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/widgets/indicator.dart';

import '../widgets/sub_setting_app_bar.dart';

class ScreenInstances extends StatelessWidget {
  const ScreenInstances({super.key});

  @override
  Widget build(BuildContext context) {
    final locals = S.of(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<SettingsBloc>(context)
          .add(SettingsEvent.fetchInstances());
    });

    return Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: SubSettingAppBar(title: locals.instances)),
        body: SafeArea(
          child: BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              if (state.instanceLoading) {
                return Center(child: cIndicator(context));
              }
              return ListView.separated(
                  itemBuilder: (context, index) => ListTile(
                        onTap: () async {
                          BlocProvider.of<SettingsBloc>(context).add(
                              SettingsEvent.setInstance(
                                  instanceApi: state.instances[index].api));

                          BaseUrl.kBaseUrl = state.instances[index].api;
                        },
                        leading: state.instance == state.instances[index].api
                            ? const Icon(CupertinoIcons.check_mark)
                            : null,
                        title: Text(
                          state.instances[index].name,
                          textAlign: TextAlign.left,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(fontSize: 16),
                        ),
                        subtitle: Text(
                          state.instances[index].locations.replaceAll(',', ' '),
                          textAlign: TextAlign.left,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(fontSize: 16),
                        ),
                      ),

                  // TextButton.icon(
                  //       icon: state.defaultLanguage == languages[0].code
                  //           ? const Icon(CupertinoIcons.check_mark)
                  //           : null,
                  //       onPressed: () async =>
                  //           BlocProvider.of<SettingsBloc>(context).add(
                  //               SettingsEvent.getDefaultLanguage(
                  //                   language: languages[index].code)),
                  //       label: Align(
                  //         alignment: Alignment.centerLeft,
                  //         child: Text(
                  //           state.instances[index].name,
                  //           textAlign: TextAlign.left,
                  //           style: Theme.of(context)
                  //               .textTheme
                  //               .bodyMedium!
                  //               .copyWith(fontSize: 16),
                  //         ),
                  //       ),
                  //     ),
                  separatorBuilder: (context, index) => const SizedBox(),
                  itemCount: state.instances.length);
            },
          ),
        ));
  }
}
