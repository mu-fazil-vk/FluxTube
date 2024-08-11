import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluxtube/core/app_info.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/presentation/settings/functions/launch_url.dart';

import '../widgets/widgets.dart';


class ScreenTranslators extends StatelessWidget {
  const ScreenTranslators({super.key});

  @override
  Widget build(BuildContext context) {
    final locals = S.of(context);
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: SubSettingAppBar(title: locals.translators)),
        body: SafeArea(
          child: ListView.separated(
              itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(left: 20, top: 5),
                    child: GestureDetector(
                      onTap: () =>
                          urlLaunch(AppInfo.translatorsInfos[index].url),
                      child: Row(
                        children: [
                          const Icon(
                            CupertinoIcons.person_fill,
                            color: Colors.deepPurple,
                            size: 30,
                          ),
                          kWidthBox20,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppInfo.translatorsInfos[index].name,
                                textAlign: TextAlign.left,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(fontSize: 17),
                              ),
                              Text(
                                AppInfo.translatorsInfos[index].description,
                                textAlign: TextAlign.left,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              separatorBuilder: (context, index) => kHeightBox20,
              itemCount: AppInfo.translatorsInfos.length),
        ));
  }
}
