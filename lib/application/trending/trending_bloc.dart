// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/application.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import 'package:fluxtube/core/enums.dart';
import 'package:fluxtube/domain/core/failure/main_failure.dart';
import 'package:fluxtube/domain/home/home_services.dart';
import 'package:fluxtube/domain/home_recommendation/home_recommendation_service.dart';
import 'package:fluxtube/domain/subscribes/models/subscribe.dart';
import 'package:fluxtube/domain/trending/models/invidious/invidious_trending_resp.dart';
import 'package:fluxtube/domain/trending/models/newpipe/newpipe_trending_resp.dart';
import 'package:fluxtube/domain/trending/trending_service.dart';

import '../../domain/trending/models/piped/trending_resp.dart';

part 'trending_bloc.freezed.dart';
part 'trending_event.dart';
part 'trending_state.dart';

@injectable
class TrendingBloc extends Bloc<TrendingEvent, TrendingState> {
  final SettingsBloc settingsBloc;
  final TrendingService trendingService;
  final HomeServices homeServices;
  final SubscribeBloc subscribeBloc;
  final HomeRecommendationService homeRecommendationService;
  StreamSubscription<SettingsState>? _settingsSubscription;

  TrendingBloc(
    this.settingsBloc,
    this.trendingService,
    this.homeServices,
    this.subscribeBloc,
    this.homeRecommendationService,
  ) : super(TrendingState.initialize()) {
    _settingsSubscription = settingsBloc.stream.listen((settingsState) {
      if (settingsState.defaultRegion != state.lastUsedRegion) {
        final serviceType = settingsState.ytService;
        add(GetForcedTrendingData(
            serviceType: serviceType, region: settingsState.defaultRegion));
      }
    });
    // fetch trending videos - with smart caching
    on<GetTrendingData>((event, emit) async {
      // Check cache validity instead of just checking if data exists
      if (event.serviceType == YouTubeServices.invidious.name) {
        if (state.invidiousTrendingResult.isNotEmpty && state.isInvidiousTrendingCacheValid) {
          return emit(state);
        }
      } else if (event.serviceType == YouTubeServices.newpipe.name) {
        if (state.newPipeTrendingResult.isNotEmpty && state.isNewPipeTrendingCacheValid) {
          return emit(state);
        }
      } else {
        if (state.trendingResult.isNotEmpty && state.isTrendingCacheValid) {
          return emit(state);
        }
      }

      if (event.serviceType == YouTubeServices.invidious.name) {
        await _fetchInvidiousTrendingInfo(event, emit);
      } else if (event.serviceType == YouTubeServices.newpipe.name) {
        await _fetchNewPipeTrendingInfo(event, emit);
      } else {
        await _fetchPipedTrendingInfo(event, emit);
      }
    });

    //get new trending data when refresh
    on<GetForcedTrendingData>((event, emit) async {
      if (event.serviceType == YouTubeServices.invidious.name) {
        await _fetchInvidiousTrendingInfo(event, emit);
      } else if (event.serviceType == YouTubeServices.newpipe.name) {
        await _fetchNewPipeTrendingInfo(event, emit);
      } else {
        await _fetchPipedTrendingInfo(event, emit);
      }
    });

    // home feed call - with smart caching
    on<GetHomeFeedData>((event, emit) async {
      if (state.feedResult.isNotEmpty && state.isFeedCacheValid) {
        return emit(state);
      }

      //make loading
      emit(state.copyWith(fetchFeedStatus: ApiStatus.loading));

      final result =
          await homeServices.getHomeFeedData(channels: event.channels);

      final _state = result.fold(
          (MainFailure failure) =>
              state.copyWith(fetchFeedStatus: ApiStatus.error),
          (List<TrendingResp> resp) {
        subscribeBloc.add(SubscribeEvent.updateSubscribeOldList(
            subscribedChannels: event.channels));
        return state.copyWith(
            feedResult: resp,
            fetchFeedStatus: ApiStatus.loaded,
            feedLastFetched: DateTime.now());
      });
      emit(_state);
    });

    // get data when refresh
    on<GetForcedHomeFeedData>((event, emit) async {
      //make loading
      emit(state.copyWith(fetchFeedStatus: ApiStatus.loading));

      final result =
          await homeServices.getHomeFeedData(channels: event.channels);

      final _state = result.fold(
          (MainFailure failure) =>
              state.copyWith(fetchFeedStatus: ApiStatus.error),
          (List<TrendingResp> resp) {
        subscribeBloc.add(SubscribeEvent.updateSubscribeOldList(
            subscribedChannels: event.channels));
        return state.copyWith(
            feedResult: resp,
            fetchFeedStatus: ApiStatus.loaded,
            feedDisplayCount: 10); // Reset display count on refresh
      });
      emit(_state);
    });

    // NewPipe feed call - with smart caching
    on<GetNewPipeHomeFeedData>((event, emit) async {
      if (state.newPipeFeedResult.isNotEmpty && state.isNewPipeFeedCacheValid) {
        return emit(state);
      }

      //make loading
      emit(state.copyWith(fetchNewPipeFeedStatus: ApiStatus.loading));

      final result =
          await homeServices.getNewPipeHomeFeedData(channels: event.channels);

      final _state = result.fold(
          (MainFailure failure) =>
              state.copyWith(fetchNewPipeFeedStatus: ApiStatus.error),
          (List<NewPipeTrendingResp> resp) {
        subscribeBloc.add(SubscribeEvent.updateSubscribeOldList(
            subscribedChannels: event.channels));
        return state.copyWith(
            newPipeFeedResult: resp,
            fetchNewPipeFeedStatus: ApiStatus.loaded,
            newPipeFeedLastFetched: DateTime.now());
      });
      emit(_state);
    });

    // NewPipe get data when refresh
    on<GetForcedNewPipeHomeFeedData>((event, emit) async {
      //make loading
      emit(state.copyWith(fetchNewPipeFeedStatus: ApiStatus.loading));

      final result =
          await homeServices.getNewPipeHomeFeedData(channels: event.channels);

      final _state = result.fold(
          (MainFailure failure) =>
              state.copyWith(fetchNewPipeFeedStatus: ApiStatus.error),
          (List<NewPipeTrendingResp> resp) {
        subscribeBloc.add(SubscribeEvent.updateSubscribeOldList(
            subscribedChannels: event.channels));
        return state.copyWith(
            newPipeFeedResult: resp,
            fetchNewPipeFeedStatus: ApiStatus.loaded,
            newPipeFeedDisplayCount: 10); // Reset display count on refresh
      });
      emit(_state);
    });

    // Infinite scroll handlers
    on<LoadMoreFeed>((event, emit) async {
      if (state.isLoadingMoreFeed) return;
      final currentCount = state.feedDisplayCount;
      final totalCount = state.feedResult.length;
      if (currentCount >= totalCount) return; // Already showing all

      emit(state.copyWith(isLoadingMoreFeed: true));

      // Simulate small delay for smoother UX

      final newCount = (currentCount + 10).clamp(0, totalCount);
      emit(state.copyWith(
        feedDisplayCount: newCount,
        isLoadingMoreFeed: false,
      ));
    });

    on<LoadMoreTrending>((event, emit) async {
      if (state.isLoadingMoreTrending) return;
      final currentCount = state.trendingDisplayCount;
      final totalCount = state.trendingResult.length;
      if (currentCount >= totalCount) return;

      emit(state.copyWith(isLoadingMoreTrending: true));

      final newCount = (currentCount + 10).clamp(0, totalCount);
      emit(state.copyWith(
        trendingDisplayCount: newCount,
        isLoadingMoreTrending: false,
      ));
    });

    on<LoadMoreNewPipeFeed>((event, emit) async {
      if (state.isLoadingMoreNewPipeFeed) return;
      final currentCount = state.newPipeFeedDisplayCount;
      final totalCount = state.newPipeFeedResult.length;
      if (currentCount >= totalCount) return;

      emit(state.copyWith(isLoadingMoreNewPipeFeed: true));

      final newCount = (currentCount + 10).clamp(0, totalCount);
      emit(state.copyWith(
        newPipeFeedDisplayCount: newCount,
        isLoadingMoreNewPipeFeed: false,
      ));
    });

    on<LoadMoreNewPipeTrending>((event, emit) async {
      if (state.isLoadingMoreNewPipeTrending) return;
      final currentCount = state.newPipeTrendingDisplayCount;
      final totalCount = state.newPipeTrendingResult.length;
      if (currentCount >= totalCount) return;

      emit(state.copyWith(isLoadingMoreNewPipeTrending: true));

      final newCount = (currentCount + 10).clamp(0, totalCount);
      emit(state.copyWith(
        newPipeTrendingDisplayCount: newCount,
        isLoadingMoreNewPipeTrending: false,
      ));
    });

    on<LoadMoreInvidiousTrending>((event, emit) async {
      if (state.isLoadingMoreInvidiousTrending) return;
      final currentCount = state.invidiousTrendingDisplayCount;
      final totalCount = state.invidiousTrendingResult.length;
      if (currentCount >= totalCount) return;

      emit(state.copyWith(isLoadingMoreInvidiousTrending: true));

      final newCount = (currentCount + 10).clamp(0, totalCount);
      emit(state.copyWith(
        invidiousTrendingDisplayCount: newCount,
        isLoadingMoreInvidiousTrending: false,
      ));
    });

    on<ResetDisplayCounts>((event, emit) {
      emit(state.copyWith(
        feedDisplayCount: 10,
        trendingDisplayCount: 10,
        newPipeFeedDisplayCount: 10,
        newPipeTrendingDisplayCount: 10,
        invidiousTrendingDisplayCount: 10,
        personalizedFeedDisplayCount: 10,
      ));
    });

    // Personalized feed handlers - with smart caching
    on<GetPersonalizedFeed>((event, emit) async {
      if (state.personalizedFeedResult.isNotEmpty && state.isPersonalizedFeedCacheValid) {
        return emit(state);
      }
      await _fetchPersonalizedFeed(event, emit);
    });

    on<GetForcedPersonalizedFeed>((event, emit) async {
      await _fetchPersonalizedFeed(event, emit);
    });

    on<LoadMorePersonalizedFeed>((event, emit) async {
      if (state.isLoadingMorePersonalizedFeed ||
          !state.hasMorePersonalizedContent) {
        return;
      }

      emit(state.copyWith(isLoadingMorePersonalizedFeed: true));

      // Build set of existing video IDs for deduplication
      final existingVideoIds = state.personalizedFeedResult
          .map((item) =>
              item.videoId ?? item.url?.split('v=').last.split('&').first ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();

      // Load more queries (fetch total queries including previous + 3 new ones)
      // Then filter out duplicates
      final result = await homeRecommendationService.getPersonalizedFeed(
        profileName: event.profileName,
        serviceType: event.serviceType,
        resultsPerQuery: 3,
        queryLimit: state.personalizedFeedQueryOffset +
            3, // Get all queries including new ones
        page: 1,
      );

      result.fold(
        (failure) {
          if (!emit.isDone) {
            emit(state.copyWith(
              isLoadingMorePersonalizedFeed: false,
              hasMorePersonalizedContent: false,
            ));
          }
        },
        (items) {
          // Filter out duplicates
          final uniqueItems = items.where((item) {
            final videoId = item.videoId ??
                item.url?.split('v=').last.split('&').first ??
                '';
            return !existingVideoIds.contains(videoId);
          }).toList();

          if (!emit.isDone) {
            final updatedList = [
              ...state.personalizedFeedResult,
              ...uniqueItems
            ];
            emit(state.copyWith(
              personalizedFeedResult: updatedList,
              personalizedFeedDisplayCount: updatedList.length,
              isLoadingMorePersonalizedFeed: false,
              hasMorePersonalizedContent: uniqueItems.isNotEmpty,
              personalizedFeedQueryOffset:
                  state.personalizedFeedQueryOffset + 3,
            ));
          }
        },
      );
    });
  }

  Future<void> _fetchPersonalizedFeed(dynamic event, Emitter<TrendingState> emit) async {
    emit(state.copyWith(fetchPersonalizedFeedStatus: ApiStatus.loading));

    // Initial load: fetch 4 queries worth of content
    final result = await homeRecommendationService.getPersonalizedFeed(
      profileName: event.profileName,
      serviceType: event.serviceType,
      resultsPerQuery: 3,
      queryLimit: 4,
      page: 1,
    );

    result.fold(
      (failure) {
        if (!emit.isDone) {
          emit(state.copyWith(
            fetchPersonalizedFeedStatus: ApiStatus.error,
          ));
        }
      },
      (items) {
        if (!emit.isDone) {
          emit(state.copyWith(
            personalizedFeedResult: items,
            fetchPersonalizedFeedStatus: ApiStatus.loaded,
            personalizedFeedDisplayCount: items.length.clamp(0, 10),
            hasMorePersonalizedContent: true,
            personalizedFeedQueryOffset: 4, // Track that we've loaded 4 queries
            personalizedFeedLastFetched: DateTime.now(),
          ));
        }
      },
    );
  }

  Future<void> _fetchPipedTrendingInfo(dynamic event, Emitter<TrendingState> emit) async {
    emit(state.copyWith(fetchTrendingStatus: ApiStatus.loading));

    final result = await trendingService.getTrendingData(
        region: event.region ?? settingsBloc.state.defaultRegion);

    final _state = result.fold(
        (MainFailure failure) =>
            state.copyWith(fetchTrendingStatus: ApiStatus.error),
        (List<TrendingResp> resp) => state.copyWith(
            trendingResult: resp,
            fetchTrendingStatus: ApiStatus.loaded,
            trendingLastFetched: DateTime.now()));
    emit(_state);
  }

  Future<void> _fetchInvidiousTrendingInfo(dynamic event, Emitter<TrendingState> emit) async {
    emit(state.copyWith(fetchInvidiousTrendingStatus: ApiStatus.loading));

    final result = await trendingService.getInvidiousTrendingData(
        region: settingsBloc.state.defaultRegion);
    final _state = result.fold(
        (MainFailure failure) =>
            state.copyWith(fetchInvidiousTrendingStatus: ApiStatus.error),
        (List<InvidiousTrendingResp> resp) => state.copyWith(
            invidiousTrendingResult: resp,
            fetchInvidiousTrendingStatus: ApiStatus.loaded,
            invidiousTrendingLastFetched: DateTime.now()));
    emit(_state);
  }

  Future<void> _fetchNewPipeTrendingInfo(dynamic event, Emitter<TrendingState> emit) async {
    emit(state.copyWith(fetchNewPipeTrendingStatus: ApiStatus.loading));

    final result = await trendingService.getNewPipeTrendingData(
        region: settingsBloc.state.defaultRegion);
    final _state = result.fold(
        (MainFailure failure) =>
            state.copyWith(fetchNewPipeTrendingStatus: ApiStatus.error),
        (List<NewPipeTrendingResp> resp) => state.copyWith(
            newPipeTrendingResult: resp,
            fetchNewPipeTrendingStatus: ApiStatus.loaded,
            lastUsedRegion: settingsBloc.state.defaultRegion,
            newPipeTrendingLastFetched: DateTime.now()));
    emit(_state);
  }

  @override
  Future<void> close() {
    _settingsSubscription?.cancel();
    return super.close();
  }
}
