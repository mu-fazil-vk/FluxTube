// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:fluxtube/application/application.dart' as _i1030;
import 'package:fluxtube/application/channel/channel_bloc.dart' as _i20;
import 'package:fluxtube/application/saved/saved_bloc.dart' as _i7;
import 'package:fluxtube/application/search/search_bloc.dart' as _i799;
import 'package:fluxtube/application/settings/settings_bloc.dart' as _i112;
import 'package:fluxtube/application/subscribe/subscribe_bloc.dart' as _i187;
import 'package:fluxtube/application/trending/trending_bloc.dart' as _i11;
import 'package:fluxtube/application/watch/watch_bloc.dart' as _i771;
import 'package:fluxtube/domain/channel/channel_services.dart' as _i914;
import 'package:fluxtube/domain/home/home_services.dart' as _i811;
import 'package:fluxtube/domain/saved/saved_services.dart' as _i722;
import 'package:fluxtube/domain/search/search_service.dart' as _i947;
import 'package:fluxtube/domain/settings/settings_service.dart' as _i816;
import 'package:fluxtube/domain/subscribes/subscribe_services.dart' as _i479;
import 'package:fluxtube/domain/trending/trending_service.dart' as _i60;
import 'package:fluxtube/domain/watch/watch_service.dart' as _i719;
import 'package:fluxtube/infrastructure/channel/channel_impl.dart' as _i112;
import 'package:fluxtube/infrastructure/home/home_impliment.dart' as _i278;
import 'package:fluxtube/infrastructure/saved/saved_impliment.dart' as _i740;
import 'package:fluxtube/infrastructure/search/search_impliment.dart' as _i422;
import 'package:fluxtube/infrastructure/settings/setting_impliment.dart'
    as _i780;
import 'package:fluxtube/infrastructure/subscribe/subscribe_impliment.dart'
    as _i374;
import 'package:fluxtube/infrastructure/trending/trending_impliment.dart'
    as _i419;
import 'package:fluxtube/infrastructure/watch/watch_impliment.dart' as _i850;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.lazySingleton<_i914.ChannelServices>(() => _i112.ChannelImpl());
    gh.lazySingleton<_i722.SavedServices>(() => _i740.SavedImplimentation());
    gh.lazySingleton<_i816.SettingsService>(() => _i780.SettingImpliment());
    gh.lazySingleton<_i719.WatchService>(() => _i850.WatchImpliment());
    gh.lazySingleton<_i811.HomeServices>(() => _i278.HomeImpliment());
    gh.factory<_i771.WatchBloc>(
        () => _i771.WatchBloc(gh<_i719.WatchService>()));
    gh.lazySingleton<_i479.SubscribeServices>(() => _i374.SubscribeImpliment());
    gh.factory<_i187.SubscribeBloc>(
        () => _i187.SubscribeBloc(gh<_i479.SubscribeServices>()));
    gh.lazySingleton<_i947.SearchService>(() => _i422.SearchImplimentation());
    gh.lazySingleton<_i60.TrendingService>(() => _i419.TrendingImpliment());
    gh.factory<_i112.SettingsBloc>(
        () => _i112.SettingsBloc(gh<_i816.SettingsService>()));
    gh.factory<_i20.ChannelBloc>(
        () => _i20.ChannelBloc(gh<_i914.ChannelServices>()));
    gh.factory<_i799.SearchBloc>(
        () => _i799.SearchBloc(gh<_i947.SearchService>()));
    gh.factory<_i7.SavedBloc>(() => _i7.SavedBloc(gh<_i722.SavedServices>()));
    gh.factory<_i11.TrendingBloc>(() => _i11.TrendingBloc(
          gh<_i1030.SettingsBloc>(),
          gh<_i60.TrendingService>(),
          gh<_i811.HomeServices>(),
          gh<_i1030.SubscribeBloc>(),
        ));
    return this;
  }
}
