import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/enums.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  void _initializeSettings() {
    // Initialize the settings bloc
    final settingsBloc = BlocProvider.of<SettingsBloc>(context);
    final subscribeBloc = BlocProvider.of<SubscribeBloc>(context);
    settingsBloc.add(SettingsEvent.initializeSettings());
    subscribeBloc.add(const SubscribeEvent.getAllSubscribeList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<SettingsBloc, SettingsState>(builder: (context, state) {
        return BlocBuilder<SubscribeBloc, SubscribeState>(
          builder: (context, subscribeState) {
            if (state.settingsStatus == ApiStatus.loading ||
                subscribeState.subscribeStatus == ApiStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state.settingsStatus == ApiStatus.loaded &&
                subscribeState.subscribeStatus == ApiStatus.loaded) {
              _handleState(state, subscribeState);
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              _handleState(state, subscribeState);
              return const Center(
                child: Text('Error loading settings'),
              );
            }
          },
        );
      }),
    );
  }

  void _handleState(SettingsState state, SubscribeState subscribeState) async {
    final settingsBloc = BlocProvider.of<SettingsBloc>(context);

    if (state.ytService != YouTubeServices.piped.name && state.initialized) {
      if (state.invidiousInstances.isEmpty &&
          state.invidiousInstanceStatus != ApiStatus.loading) {
        settingsBloc.add(SettingsEvent.fetchInvidiousInstances());
      }
    } else if (state.ytService == YouTubeServices.piped.name &&
        state.initialized) {
      if (state.pipedInstances.isEmpty &&
          state.pipedInstanceStatus != ApiStatus.loading) {
        settingsBloc.add(SettingsEvent.fetchPipedInstances());
      }
    }

    // go to home screen
    if ((state.settingsStatus == ApiStatus.loaded ||
            state.settingsStatus == ApiStatus.error) &&
        (state.pipedInstanceStatus == ApiStatus.loaded ||
            state.invidiousInstanceStatus == ApiStatus.loaded) &&
        (subscribeState.subscribeStatus == ApiStatus.loaded ||
            subscribeState.subscribeStatus == ApiStatus.error)) {
      {
        await Future.delayed(const Duration(), () {
          context.pushReplacementNamed('main');
        });
      }
    }
  }
}
