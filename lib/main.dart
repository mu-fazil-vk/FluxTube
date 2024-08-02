import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_in_app_pip/flutter_in_app_pip.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluxtube/application/channel/channel_bloc.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/presentation/channel/screen_channel.dart';
import 'package:fluxtube/presentation/settings/sub_screens/screen_language.dart';
import 'package:fluxtube/presentation/settings/sub_screens/screen_translators.dart';
import 'package:go_router/go_router.dart';

import 'package:fluxtube/application/saved/saved_bloc.dart';
import 'package:fluxtube/application/search/search_bloc.dart';
import 'package:fluxtube/application/settings/settings_bloc.dart';
import 'package:fluxtube/application/subscribe/subscribe_bloc.dart';
import 'package:fluxtube/application/trending/trending_bloc.dart';
import 'package:fluxtube/application/watch/watch_bloc.dart';
import 'package:fluxtube/core/app_info.dart';
import 'package:fluxtube/core/app_theme.dart';
import 'package:fluxtube/core/locals.dart';
import 'package:fluxtube/infrastructure/settings/setting_impliment.dart';
import 'package:fluxtube/presentation/main_navigation/main_navigation.dart';
import 'package:fluxtube/presentation/settings/sub_screens/screen_regions.dart';
import 'package:fluxtube/presentation/watch/screen_watch.dart';

import 'core/di/injectable.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingImpliment.initializeDB();
  // Initialize GetIt and register dependencies
  configureInjection();
  runApp(const MyApp());
}

// GoRouter configuration
final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return MainNavigation();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'watch/:id/:channelId',
          builder: (BuildContext context, GoRouterState state) {
            return ScreenWatch(
              id: state.pathParameters['id']!,
              channelId: state.pathParameters['channelId']!,
            );
          },
        ),
        GoRoute(
          name: 'channel',
          path: 'channel/:channelId',
          builder: (BuildContext context, GoRouterState state) {
            return ScreenChannel(
              channelId: state.pathParameters['channelId']!,
              avtarUrl: state.uri.queryParameters['avtarUrl'],
            );
          },
        ),
        GoRoute(
          path: 'regions',
          builder: (BuildContext context, GoRouterState state) {
            return const ScreenRegions();
          },
        ),
        GoRoute(
          path: 'translators',
          builder: (BuildContext context, GoRouterState state) {
            return const ScreenTranslators();
          },
        ),
        GoRoute(
          path: 'languages',
          builder: (BuildContext context, GoRouterState state) {
            return const ScreenLanguage();
          },
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<TrendingBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<WatchBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<SearchBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<SettingsBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<SavedBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<SubscribeBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<ChannelBloc>(),
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return PiPMaterialApp.router(
            title: AppInfo.myApp.name,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.themeMode == 'dark'
                ? ThemeMode.dark
                : state.themeMode == 'light'
                    ? ThemeMode.light
                    : ThemeMode.system,
            debugShowCheckedModeBanner: false,
            routerConfig: _router,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              S.delegate,
            ],
            supportedLocales: supportedLocales,
            locale: Locale(state.defaultLanguage),
          );
        },
      ),
    );
  }
}
