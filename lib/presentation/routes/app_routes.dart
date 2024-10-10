// GoRouter configuration
import 'package:flutter/material.dart';
import 'package:fluxtube/presentation/channel/screen_channel.dart';
import 'package:fluxtube/presentation/main_navigation/main_navigation.dart';
import 'package:fluxtube/presentation/settings/sub_screens/screen_instances.dart';
import 'package:fluxtube/presentation/settings/sub_screens/screen_language.dart';
import 'package:fluxtube/presentation/settings/sub_screens/screen_regions.dart';
import 'package:fluxtube/presentation/settings/sub_screens/screen_translators.dart';
import 'package:fluxtube/presentation/watch/explode_screen_watch.dart';
import 'package:fluxtube/presentation/watch/screen_watch.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
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
          path: 'watch-explode/:id/:channelId',
          builder: (BuildContext context, GoRouterState state) {
            return ExplodeScreenWatch(
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
        GoRoute(
          path: 'instances',
          builder: (BuildContext context, GoRouterState state) {
            return const ScreenInstances();
          },
        ),
      ],
    ),
  ],
);