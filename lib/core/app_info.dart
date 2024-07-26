import 'model/app_info_model.dart';

class AppInfo {
  static final myApp = AppInfoModel(
    name: 'FluxTube',
    nickname: 'fluxtube',
    url: 'https://github.com/mu-fazil-vk/fluxtube',
    description: 'Watch and download videos without ads',
    image: 'fluxtube.png',
  );

  static List<AppInfoModel> developerInfos = <AppInfoModel>[
    // DO NOT EDIT
    AppInfoModel(
      name: 'Muhammed Fazil vk',
      url: 'https://github.com/mu-fazil-vk',
      description: 'Founder | Lead Developer',
    ),
  ];

  static List<AppInfoModel> translatorsInfos = <AppInfoModel>[
    AppInfoModel(
      name: 'Fazil vk',
      url: 'https://github.com/mu-fazil-vk',
      description: 'English, Malayalam',
    ),
    AppInfoModel(
      name: 'ShLerP',
      url: 'https://github.com/mikropsoft',
      description: 'Turkish',
    ),
    // more...
  ];
}
