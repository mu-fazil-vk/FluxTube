// GoRouter configuration
import 'package:flutter/material.dart';
import 'package:fluxtube/presentation/channel/screen_channel.dart';
import 'package:fluxtube/presentation/main_navigation/main_navigation.dart';
import 'package:fluxtube/presentation/settings/sub_screens/screen_instances.dart';
import 'package:fluxtube/presentation/settings/sub_screens/screen_language.dart';
import 'package:fluxtube/presentation/settings/sub_screens/screen_regions.dart';
import 'package:fluxtube/presentation/settings/sub_screens/screen_translators.dart';
import 'package:fluxtube/presentation/splash/screen_splash.dart';
import 'package:fluxtube/presentation/watch/screen_watch.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      name: 'main',
      path: '/main',
      builder: (BuildContext context, GoRouterState state) {
        return MainNavigation();
      },
      routes: <RouteBase>[
        GoRoute(
          name: 'watch',
          path: 'watch/:videoId/:channelId',
          builder: (BuildContext context, GoRouterState state) {
            return ScreenWatch(
              id: state.pathParameters['videoId']!,
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
          name: 'regions',
          path: 'regions',
          builder: (BuildContext context, GoRouterState state) {
            return const ScreenRegions();
          },
        ),
        GoRoute(
          name: 'translators',
          path: 'translators',
          builder: (BuildContext context, GoRouterState state) {
            return const ScreenTranslators();
          },
        ),
        GoRoute(
          name: 'languages',
          path: 'languages',
          builder: (BuildContext context, GoRouterState state) {
            return const ScreenLanguage();
          },
        ),
        GoRoute(
          name: 'instances',
          path: 'instances',
          builder: (BuildContext context, GoRouterState state) {
            return const ScreenInstances();
          },
        ),
      ],
    ),
  ],
);
