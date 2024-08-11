import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/settings/settings_bloc.dart';
import 'package:fluxtube/core/locals.dart';
import 'package:fluxtube/generated/l10n.dart';

import '../widgets/widgets.dart';

class ScreenLanguage extends StatelessWidget {
  const ScreenLanguage({super.key});

  @override
  Widget build(BuildContext context) {
    final locals = S.of(context);

    return Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: SubSettingAppBar(title: locals.language)),
        body: SafeArea(
          child: BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              return ListView.separated(
                  itemBuilder: (context, index) => TextButton.icon(
                        icon: state.defaultLanguage == languages[index].code
                            ? const Icon(CupertinoIcons.check_mark)
                            : null,
                        onPressed: () async =>
                            BlocProvider.of<SettingsBloc>(context).add(
                                SettingsEvent.getDefaultLanguage(
                                    language: languages[index].code)),
                        label: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            languages[index].name,
                            textAlign: TextAlign.left,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(fontSize: 16),
                          ),
                        ),
                      ),
                  separatorBuilder: (context, index) => const SizedBox(),
                  itemCount: languages.length);
            },
          ),
        ));
  }
}
