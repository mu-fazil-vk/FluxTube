import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocObserver extends BlocObserver {
  static const String _reset = '\x1B[0m';
  static const String _green = '\x1B[32m';
  static const String _blue = '\x1B[34m';
  static const String _yellow = '\x1B[33m';
  static const String _magenta = '\x1B[35m';
  static const String _red = '\x1B[31m';
  static const String _cyan = '\x1B[36m';
  static const String _gray = '\x1B[90m';
  static const String _bold = '\x1B[1m';

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    final blocType = bloc is Cubit ? 'Cubit' : 'Bloc';
    if (kDebugMode) {
      print('$_green--- [$blocType Created] ${bloc.runtimeType} ---$_reset');
    }
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    if (kDebugMode) {
      print('$_blue--- [Event] ${bloc.runtimeType} ---\n'
        '$_yellow$event$_reset');
    }
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    if (kDebugMode) {
      print('$_magenta=== [Transition] ${bloc.runtimeType} ===\n'
        '${_bold}from:$_reset $_cyan${transition.currentState}$_reset\n'
        '${_bold}to:  $_reset$_yellow${transition.nextState}$_reset');
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    if (kDebugMode) {
      print('$_red!!! [Error] ${bloc.runtimeType} !!!\n'
        'error: $error\n'
        'stacktrace: $_gray$stackTrace$_reset');
    }
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    if (kDebugMode) {
      print('$_cyan--- [${bloc.runtimeType} Closed] ---$_reset');
    }
  }
}
