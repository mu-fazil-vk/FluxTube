import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluxtube/application/download/download_bloc.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/application/saved/saved_bloc.dart';
import 'package:fluxtube/application/settings/settings_bloc.dart';
import 'package:fluxtube/application/subscribe/subscribe_bloc.dart';
import 'package:fluxtube/application/trending/trending_bloc.dart';
import 'package:fluxtube/application/watch/watch_bloc.dart';
import 'package:fluxtube/core/app_info.dart';
import 'package:fluxtube/core/app_theme.dart';
import 'package:fluxtube/core/locals.dart';
import 'package:fluxtube/core/player/global_player_controller.dart';
import 'package:fluxtube/infrastructure/download/download_notification_service.dart';
import 'package:fluxtube/infrastructure/settings/setting_impl.dart';
import 'package:fluxtube/presentation/routes/app_routes.dart';
import 'package:fluxtube/presentation/routes/bloc_observer.dart';
import 'package:fluxtube/presentation/watch/widgets/global_pip_overlay.dart';
import 'package:fluxtube/core/services/audio_handler_service.dart';
import 'package:fluxtube/core/services/log_collector.dart';
import 'package:fluxtube/core/services/subscription_notifier.dart';

import 'core/di/injectable.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Mirror framework debug output into the in-app log collector so the Debug
  // Console can surface it for bug reports. LogCollector re-emits through
  // dart:developer, so console output is preserved.
  debugPrint = (String? message, {int? wrapWidth}) {
    if (message != null) {
      LogCollector().log(message, tag: 'FLUTTER');
    }
  };

  // Allow up to 200 MB for decoded image bitmaps (default is 100 MB)
  PaintingBinding.instance.imageCache.maximumSizeBytes = 200 << 20;

  Bloc.observer = AppBlocObserver();
  await SettingImpl.initializeDB();
  // Initialize GetIt and register dependencies
  configureInjection();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize services after the first frame
    // This ensures the Activity is fully attached and can show permission dialogs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DownloadNotificationService().initialize();
      // Initialize audio service for background playback notification controls
      initAudioService();
      // Look for new uploads from subscribed channels. Self-throttling and a
      // no-op unless the user turned notifications on.
      SubscriptionNotifier().checkForNewVideos();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Dispose the global player when app is closing
    GlobalPlayerController().disposePlayer();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // When app is detached (being destroyed), stop the player to prevent crash
    if (state == AppLifecycleState.detached) {
      GlobalPlayerController().disposePlayer();
    }
    // Returning to the foreground is the only chance to poll for new uploads,
    // since there is no background job. The check throttles itself.
    if (state == AppLifecycleState.resumed) {
      SubscriptionNotifier().checkForNewVideos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<TrendingBloc>()),
        BlocProvider(create: (context) => getIt<WatchBloc>()),
        BlocProvider(create: (context) => getIt<SettingsBloc>()),
        BlocProvider(create: (context) => getIt<SavedBloc>()),
        BlocProvider(create: (context) => getIt<SubscribeBloc>()),
        BlocProvider(create: (context) => getIt<DownloadBloc>()),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        buildWhen: (previous, current) =>
            previous.themeMode != current.themeMode ||
            previous.defaultLanguage != current.defaultLanguage,
        builder: (context, state) {
          final mode = state.themeMode;

          if (mode == 'dynamic') {
            return DynamicColorBuilder(
              builder: (lightDynamic, darkDynamic) {
                return MaterialApp.router(
                  title: AppInfo.myApp.name,
                  theme: AppTheme.dynamicTheme(lightDynamic ?? ColorScheme.fromSeed(seedColor: Colors.blue)),
                  darkTheme: AppTheme.dynamicTheme(darkDynamic ?? const ColorScheme.dark()),
                  themeMode: ThemeMode.system,
                  debugShowCheckedModeBanner: false,
                  routerConfig: router,
                  localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                    S.delegate,
                  ],
                  supportedLocales: supportedLocales,
                  locale: Locale(state.defaultLanguage),
                  builder: (context, child) {
                    return GlobalPipOverlay(
                      child: child ?? const SizedBox.shrink(),
                    );
                  },
                );
              },
            );
          }

          final isOled = mode == 'oled';
          return MaterialApp.router(
            title: AppInfo.myApp.name,
            theme: AppTheme.lightTheme,
            darkTheme: isOled ? AppTheme.oledTheme : AppTheme.darkTheme,
            themeMode: _getThemeMode(mode),
            debugShowCheckedModeBanner: false,
            routerConfig: router,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              S.delegate,
            ],
            supportedLocales: supportedLocales,
            locale: Locale(state.defaultLanguage),
            builder: (context, child) {
              return GlobalPipOverlay(
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }

  ThemeMode _getThemeMode(String themeMode) {
    switch (themeMode) {
      case 'dark':
      case 'oled':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }
}
