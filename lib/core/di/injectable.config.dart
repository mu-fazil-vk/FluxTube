// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:fluxtube/application/channel/channel_bloc.dart' as _i22;
import 'package:fluxtube/application/saved/saved_bloc.dart' as _i24;
import 'package:fluxtube/application/search/search_bloc.dart' as _i23;
import 'package:fluxtube/application/settings/settings_bloc.dart' as _i21;
import 'package:fluxtube/application/subscribe/subscribe_bloc.dart' as _i16;
import 'package:fluxtube/application/trending/trending_bloc.dart' as _i25;
import 'package:fluxtube/application/watch/watch_bloc.dart' as _i13;
import 'package:fluxtube/domain/channel/channel_services.dart' as _i3;
import 'package:fluxtube/domain/home/home_services.dart' as _i11;
import 'package:fluxtube/domain/saved/saved_services.dart' as _i5;
import 'package:fluxtube/domain/search/search_service.dart' as _i17;
import 'package:fluxtube/domain/settings/settings_service.dart' as _i7;
import 'package:fluxtube/domain/subscribes/subscribe_services.dart' as _i14;
import 'package:fluxtube/domain/trending/trending_service.dart' as _i19;
import 'package:fluxtube/domain/watch/watch_service.dart' as _i9;
import 'package:fluxtube/infrastructure/channel/channel_impl.dart' as _i4;
import 'package:fluxtube/infrastructure/home/home_impliment.dart' as _i12;
import 'package:fluxtube/infrastructure/saved/saved_impliment.dart' as _i6;
import 'package:fluxtube/infrastructure/search/search_impliment.dart' as _i18;
import 'package:fluxtube/infrastructure/settings/setting_impliment.dart' as _i8;
import 'package:fluxtube/infrastructure/subscribe/subscribe_impliment.dart'
    as _i15;
import 'package:fluxtube/infrastructure/trending/trending_impliment.dart'
    as _i20;
import 'package:fluxtube/infrastructure/watch/watch_impliment.dart' as _i10;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i1.GetIt init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.lazySingleton<_i3.ChannelServices>(() => _i4.ChannelImpl());
    gh.lazySingleton<_i5.SavedServices>(() => _i6.SavedImplimentation());
    gh.lazySingleton<_i7.SettingsService>(() => _i8.SettingImpliment());
    gh.lazySingleton<_i9.WatchService>(() => _i10.WatchImpliment());
    gh.lazySingleton<_i11.HomeServices>(() => _i12.HomeImpliment());
    gh.factory<_i13.WatchBloc>(() => _i13.WatchBloc(gh<_i9.WatchService>()));
    gh.lazySingleton<_i14.SubscribeServices>(() => _i15.SubscribeImpliment());
    gh.factory<_i16.SubscribeBloc>(
        () => _i16.SubscribeBloc(gh<_i14.SubscribeServices>()));
    gh.lazySingleton<_i17.SearchService>(() => _i18.SearchImplimentation());
    gh.lazySingleton<_i19.TrendingService>(() => _i20.TrendingImpliment());
    gh.factory<_i21.SettingsBloc>(
        () => _i21.SettingsBloc(gh<_i7.SettingsService>()));
    gh.factory<_i22.ChannelBloc>(
        () => _i22.ChannelBloc(gh<_i3.ChannelServices>()));
    gh.factory<_i23.SearchBloc>(
        () => _i23.SearchBloc(gh<_i17.SearchService>()));
    gh.factory<_i24.SavedBloc>(() => _i24.SavedBloc(gh<_i5.SavedServices>()));
    gh.factory<_i25.TrendingBloc>(() => _i25.TrendingBloc(
          gh<_i19.TrendingService>(),
          gh<_i11.HomeServices>(),
        ));
    return this;
  }
}
