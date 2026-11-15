import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/core/enums.dart';
import 'package:fluxtube/domain/subscribes/models/subscribe.dart';
import 'package:fluxtube/domain/trending/models/newpipe/newpipe_trending_resp.dart';
import 'package:fluxtube/domain/watch/models/basic_info.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/infrastructure/newpipe/newpipe_channel.dart';
import 'package:fluxtube/presentation/home/widgets/personalized_feed_section.dart';
import 'package:fluxtube/presentation/main_navigation/main_navigation_layout.dart';
import 'package:fluxtube/presentation/trending/widgets/invidious/trending_videos_section.dart';
import 'package:fluxtube/presentation/trending/widgets/newpipe/home_video_info_card_widget.dart';
import 'package:fluxtube/presentation/trending/widgets/newpipe/trending_videos_section.dart';
import 'package:fluxtube/presentation/trending/widgets/piped/trending_videos_section.dart';
import 'package:fluxtube/widgets/widgets.dart';
import 'package:go_router/go_router.dart';

import 'widgets/widgets.dart';

class ScreenHome extends StatefulWidget {
  const ScreenHome({super.key});

  @override
  State<ScreenHome> createState() => _ScreenHomeState();
}

class _ScreenHomeState extends State<ScreenHome> {
  /// [HomeCategory.home] shows the existing personalized/subscription feed
  /// logic below unchanged; any other value replaces it with that kiosk
  /// category's videos, fetched directly (kiosks are a NewPipeExtractor-only
  /// concept, so this bypasses `TrendingBloc` entirely rather than
  /// stretching its Piped/Invidious-shaped state to fit).
  HomeCategory _selectedCategory = HomeCategory.home;
  bool _kioskLoading = false;
  Object? _kioskError;
  List<NewPipeTrendingResp> _kioskVideos = [];

  Future<void> _selectCategory(
    HomeCategory category,
    SettingsState settingsState,
  ) async {
    if (category == HomeCategory.home) {
      setState(() {
        _selectedCategory = category;
        _kioskError = null;
      });
      return;
    }

    setState(() {
      _selectedCategory = category;
      _kioskLoading = true;
      _kioskError = null;
      // Without this, the previous category's videos were still sitting in
      // _kioskVideos, so the "loading" check below (`_kioskVideos.isEmpty`)
      // was false and the old list stayed on screen — no spinner, and it
      // looked like the tap did nothing until the new data landed.
      _kioskVideos = [];
    });

    try {
      final videos = await NewPipeChannel.getTrending(
        settingsState.defaultRegion,
        kioskId: category.kioskId,
      );
      if (!mounted) return;
      setState(() {
        _kioskVideos = videos;
        _kioskLoading = false;
      });
    } catch (e) {
      debugPrint(
          '[HomeCategory] Failed to load ${category.name} (kiosk ${category.kioskId}): $e');
      if (!mounted) return;
      setState(() {
        _kioskError = e;
        _kioskLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final trendingBloc = BlocProvider.of<TrendingBloc>(context);
    final locals = S.of(context);

    return BlocBuilder<SettingsBloc, SettingsState>(
      buildWhen: (previous, current) =>
          previous.ytService != current.ytService ||
          previous.defaultRegion != current.defaultRegion ||
          previous.homeFeedMode != current.homeFeedMode,
      builder: (context, settingsState) {
        final isNewPipe =
            settingsState.ytService == YouTubeServices.newpipe.name;
        // Kiosks (Music/Gaming/Movies & Shows/Podcasts/Live) don't exist on
        // Piped/Invidious, so switching away from NewPipe mid-selection
        // would otherwise leave a stuck, uncallable category selected.
        if (!isNewPipe && _selectedCategory != HomeCategory.home) {
          _selectedCategory = HomeCategory.home;
        }

        return Column(
          children: [
            // Clears the floating glass header — collapses in sync with it
            // via headerVisibleNotifier so content flows up to fill the
            // space when it hides, instead of leaving it empty.
            MainNavigationLayout.headerSpacer(context),
            if (isNewPipe) ...[
              AppSpacing.height8,
              HomeCategoryRow(
                selected: _selectedCategory,
                onSelected: (category) =>
                    _selectCategory(category, settingsState),
              ),
              AppSpacing.height8,
            ],
            if (_selectedCategory == HomeCategory.home)
              const ContinueWatchingRow(),
            Expanded(
              child: _selectedCategory != HomeCategory.home
                  ? _buildKioskSection(context, locals)
                  : BlocBuilder<SubscribeBloc, SubscribeState>(
                      buildWhen: (previous, current) =>
                          previous.subscribedChannels.length !=
                          current.subscribedChannels.length,
                      builder: (context, subscribeState) {
                        if (subscribeState.subscribedChannels.isNotEmpty &&
                            subscribeState.oldList.length !=
                                subscribeState.subscribedChannels.length) {
                          log("oldList: ${subscribeState.oldList.length} & subscribedChannels: ${subscribeState.subscribedChannels.length}");
                          // For NewPipe, home stays as personalized feed - no refresh needed
                          // For other services, refresh the subscription feed on home
                          if (settingsState.ytService !=
                              YouTubeServices.newpipe.name) {
                            trendingBloc.add(GetForcedHomeFeedData(
                                channels: subscribeState.subscribedChannels));
                          }
                          BlocProvider.of<SubscribeBloc>(context).add(
                              SubscribeEvent.updateSubscribeOldList(
                                  subscribedChannels:
                                      subscribeState.subscribedChannels));
                        }
                        return BlocBuilder<TrendingBloc, TrendingState>(
                          buildWhen: (previous, current) {
                            return previous.fetchTrendingStatus !=
                                    current.fetchTrendingStatus ||
                                previous.fetchInvidiousTrendingStatus !=
                                    current.fetchInvidiousTrendingStatus ||
                                previous.fetchNewPipeTrendingStatus !=
                                    current.fetchNewPipeTrendingStatus ||
                                previous.fetchFeedStatus !=
                                    current.fetchFeedStatus ||
                                previous.fetchNewPipeFeedStatus !=
                                    current.fetchNewPipeFeedStatus ||
                                previous.newPipeFeedResult !=
                                    current.newPipeFeedResult ||
                                // Personalized feed state changes
                                previous.fetchPersonalizedFeedStatus !=
                                    current.fetchPersonalizedFeedStatus ||
                                previous.personalizedFeedResult !=
                                    current.personalizedFeedResult ||
                                previous.personalizedFeedDisplayCount !=
                                    current.personalizedFeedDisplayCount ||
                                previous.isLoadingMorePersonalizedFeed !=
                                    current.isLoadingMorePersonalizedFeed ||
                                previous.hasMorePersonalizedContent !=
                                    current.hasMorePersonalizedContent ||
                                // Pagination state changes
                                previous.feedDisplayCount !=
                                    current.feedDisplayCount ||
                                previous.isLoadingMoreFeed !=
                                    current.isLoadingMoreFeed ||
                                previous.newPipeFeedDisplayCount !=
                                    current.newPipeFeedDisplayCount ||
                                previous.isLoadingMoreNewPipeFeed !=
                                    current.isLoadingMoreNewPipeFeed ||
                                previous.trendingDisplayCount !=
                                    current.trendingDisplayCount ||
                                previous.isLoadingMoreTrending !=
                                    current.isLoadingMoreTrending ||
                                previous.newPipeTrendingDisplayCount !=
                                    current.newPipeTrendingDisplayCount ||
                                previous.isLoadingMoreNewPipeTrending !=
                                    current.isLoadingMoreNewPipeTrending ||
                                previous.invidiousTrendingDisplayCount !=
                                    current.invidiousTrendingDisplayCount ||
                                previous.isLoadingMoreInvidiousTrending !=
                                    current.isLoadingMoreInvidiousTrending;
                          },
                          builder: (context, trendingState) {
                            if (settingsState.ytService ==
                                YouTubeServices.newpipe.name) {
                              return _buildNewPipeTrendingOrFeedSection(
                                trendingState,
                                locals,
                                context,
                                subscribeState,
                                trendingBloc,
                                settingsState,
                              );
                            } else if (settingsState.ytService ==
                                YouTubeServices.invidious.name) {
                              return _buildInvidiousTrendingOrFeedSection(
                                trendingState,
                                locals,
                                context,
                                subscribeState,
                                trendingBloc,
                                settingsState,
                              );
                            } else {
                              return _buildPipedTrendingOrFeedSection(
                                trendingState,
                                locals,
                                context,
                                subscribeState,
                                trendingBloc,
                                settingsState,
                              );
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildKioskSection(BuildContext context, S locals) {
    if (_kioskLoading && _kioskVideos.isEmpty) {
      return _padForNavBar(context, _buildLoadingList());
    }

    if (_kioskError != null && _kioskVideos.isEmpty) {
      return _padForNavBar(
        context,
        ErrorRetryWidget(
          lottie: 'assets/dog.zip',
          // Surfaces the actual extraction error (e.g. a specific kiosk
          // failing) instead of a generic message with no way to tell
          // which category broke or why.
          customMessage: _kioskError.toString(),
          onTap: () => _selectCategory(
            _selectedCategory,
            context.read<SettingsBloc>().state,
          ),
        ),
      );
    }

    if (_kioskVideos.isEmpty) {
      return _padForNavBar(
        context,
        Center(
          child: Text(
            locals.noVideosFound,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _selectCategory(
        _selectedCategory,
        context.read<SettingsBloc>().state,
      ),
      child: _padForNavBar(
        context,
        BlocBuilder<SubscribeBloc, SubscribeState>(
          builder: (context, subscribeState) {
            return ListView.separated(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              itemCount: _kioskVideos.length,
              separatorBuilder: (context, index) => kHeightBox10,
              itemBuilder: (context, index) {
                final video = _kioskVideos[index];
                final videoId = video.videoId ?? '';
                final channelId = video.uploaderUrl?.split('/').last ?? '';
                if (videoId.isEmpty || channelId.isEmpty) {
                  return const SizedBox.shrink();
                }

                final isSubscribed = subscribeState.subscribedChannels
                    .any((channel) => channel.id == channelId);

                return GestureDetector(
                  key: ValueKey('kiosk_${_selectedCategory.name}_$videoId'),
                  onTap: () {
                    context.read<WatchBloc>().add(
                          WatchEvent.setSelectedVideoBasicDetails(
                            details: VideoBasicInfo(
                              id: videoId,
                              title: video.name,
                              thumbnailUrl: video.thumbnailUrl,
                              channelName: video.uploaderName,
                              channelThumbnailUrl: video.uploaderAvatarUrl,
                              channelId: channelId,
                              uploaderVerified: video.uploaderVerified ?? false,
                            ),
                          ),
                        );
                    context.goNamed('watch', pathParameters: {
                      'videoId': videoId,
                      'channelId': channelId,
                    });
                  },
                  child: NewPipeTrendingVideoInfoCardWidget(
                    channelId: channelId,
                    cardInfo: video,
                    isSubscribed: isSubscribed,
                    onSubscribeTap: () {
                      if (isSubscribed) {
                        context.read<SubscribeBloc>().add(
                              SubscribeEvent.deleteSubscribeInfo(id: channelId),
                            );
                      } else {
                        context.read<SubscribeBloc>().add(
                              SubscribeEvent.addSubscribe(
                                channelInfo: Subscribe(
                                  id: channelId,
                                  channelName: video.uploaderName ??
                                      locals.noUploaderName,
                                  isVerified: video.uploaderVerified ?? false,
                                ),
                              ),
                            );
                      }
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// Keeps scrolling content clear of the floating bottom nav pill.
  Widget _padForNavBar(BuildContext context, Widget child) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MainNavigationLayout.navPadding(context).bottom),
      child: child,
    );
  }

  Widget _buildPipedTrendingOrFeedSection(
      TrendingState trendingState,
      S locals,
      BuildContext context,
      SubscribeState subscribeState,
      TrendingBloc trendingBloc,
      SettingsState settingsState) {
    final homeFeedMode = settingsState.homeFeedMode;

    // Always fetch trending data if not available
    if (trendingState.trendingResult.isEmpty &&
        !(trendingState.fetchTrendingStatus == ApiStatus.error)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        trendingBloc.add(TrendingEvent.getTrendingData(
            serviceType: settingsState.ytService,
            region: settingsState.defaultRegion));
      });
    }

    if (trendingState.fetchTrendingStatus == ApiStatus.loading ||
        trendingState.fetchTrendingStatus == ApiStatus.initial) {
      return _padForNavBar(context, _buildLoadingList());
    }

    // Trending Only mode - always show trending
    if (homeFeedMode == HomeFeedMode.trendingOnly.name) {
      return _padForNavBar(
        context,
        _buildErrorOrTrendingSection(
          context,
          trendingState,
          locals,
          settingsState,
        ),
      );
    }

    // Feed Only mode - show feed or empty state
    if (homeFeedMode == HomeFeedMode.feedOnly.name) {
      if (trendingState.fetchFeedStatus == ApiStatus.loading) {
        return _padForNavBar(context, _buildLoadingList());
      }
      if (trendingState.feedResult.isEmpty) {
        return _padForNavBar(
            context, _buildEmptySubscriptionState(context, locals));
      }
      return _buildFeedSection(
        context,
        trendingState,
        locals,
        subscribeState,
        trendingBloc,
      );
    }

    // Auto mode (feedOrTrending) - show feed if available, otherwise trending
    if (trendingState.fetchFeedStatus == ApiStatus.loading) {
      return _padForNavBar(context, _buildLoadingList());
    }

    if (trendingState.feedResult.isEmpty ||
        trendingState.fetchFeedStatus == ApiStatus.error) {
      log("Feed Error or empty - showing trending");
      return _buildErrorOrTrendingSection(
        context,
        trendingState,
        locals,
        settingsState,
      );
    }

    return _buildFeedSection(
      context,
      trendingState,
      locals,
      subscribeState,
      trendingBloc,
    );
  }

  Widget _buildNewPipeTrendingOrFeedSection(
    TrendingState trendingState,
    S locals,
    BuildContext context,
    SubscribeState subscribeState,
    TrendingBloc trendingBloc,
    SettingsState settingsState,
  ) {
    // For NewPipe, always use personalized feed on home screen
    // (Subscription feed is available via subscriptions tab)

    // Fetch personalized feed if not already loaded
    if (trendingState.personalizedFeedResult.isEmpty &&
        trendingState.fetchPersonalizedFeedStatus == ApiStatus.initial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        trendingBloc.add(TrendingEvent.getPersonalizedFeed(
          profileName: settingsState.currentProfile,
          serviceType: settingsState.ytService,
        ));
      });
    }

    if (trendingState.fetchPersonalizedFeedStatus == ApiStatus.loading ||
        trendingState.fetchPersonalizedFeedStatus == ApiStatus.initial) {
      return _padForNavBar(context, _buildLoadingList());
    }

    // If personalized feed fails or is empty, fall back to trending
    if (trendingState.fetchPersonalizedFeedStatus == ApiStatus.error ||
        (trendingState.personalizedFeedResult.isEmpty &&
            trendingState.fetchPersonalizedFeedStatus == ApiStatus.loaded)) {
      log("Personalized feed error/empty - falling back to trending");
      // Fetch trending as fallback
      if (trendingState.newPipeTrendingResult.isEmpty &&
          trendingState.fetchNewPipeTrendingStatus != ApiStatus.loading) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          trendingBloc.add(TrendingEvent.getTrendingData(
              serviceType: settingsState.ytService,
              region: settingsState.defaultRegion));
        });
      }
      // Wrap with RefreshIndicator to allow retrying personalized feed
      return RefreshIndicator(
        onRefresh: () async {
          trendingBloc.add(TrendingEvent.getForcedPersonalizedFeed(
            profileName: settingsState.currentProfile,
            serviceType: settingsState.ytService,
          ));
        },
        child: _padForNavBar(
          context,
          _buildErrorOrTrendingSection(
            context,
            trendingState,
            locals,
            settingsState,
          ),
        ),
      );
    }

    // Show personalized feed
    return RefreshIndicator(
      onRefresh: () async {
        trendingBloc.add(TrendingEvent.getForcedPersonalizedFeed(
          profileName: settingsState.currentProfile,
          serviceType: settingsState.ytService,
        ));
      },
      child: _padForNavBar(
        context,
        PersonalizedFeedSection(
          trendingState: trendingState,
          locals: locals,
          settingsState: settingsState,
        ),
      ),
    );
  }

  Widget _buildInvidiousTrendingOrFeedSection(
    TrendingState trendingState,
    S locals,
    BuildContext context,
    SubscribeState subscribeState,
    TrendingBloc trendingBloc,
    SettingsState settingsState,
  ) {
    final homeFeedMode = settingsState.homeFeedMode;

    // Always fetch trending data if not available
    if (trendingState.invidiousTrendingResult.isEmpty &&
        !(trendingState.fetchInvidiousTrendingStatus == ApiStatus.error)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        trendingBloc.add(TrendingEvent.getTrendingData(
            serviceType: settingsState.ytService,
            region: settingsState.defaultRegion));
      });
    }

    if (trendingState.fetchInvidiousTrendingStatus == ApiStatus.loading ||
        trendingState.fetchInvidiousTrendingStatus == ApiStatus.initial) {
      return _padForNavBar(context, _buildLoadingList());
    }

    // Trending Only mode - always show trending
    if (homeFeedMode == HomeFeedMode.trendingOnly.name) {
      return _padForNavBar(
        context,
        _buildErrorOrTrendingSection(
          context,
          trendingState,
          locals,
          settingsState,
        ),
      );
    }

    // Feed Only mode - show feed or empty state
    if (homeFeedMode == HomeFeedMode.feedOnly.name) {
      if (trendingState.fetchFeedStatus == ApiStatus.loading) {
        return _padForNavBar(context, _buildLoadingList());
      }
      if (trendingState.feedResult.isEmpty) {
        return _padForNavBar(
            context, _buildEmptySubscriptionState(context, locals));
      }
      return _buildFeedSection(
        context,
        trendingState,
        locals,
        subscribeState,
        trendingBloc,
      );
    }

    // Auto mode (feedOrTrending) - show feed if available, otherwise trending
    if (trendingState.fetchFeedStatus == ApiStatus.loading) {
      return _padForNavBar(context, _buildLoadingList());
    }

    if (trendingState.feedResult.isEmpty ||
        trendingState.fetchFeedStatus == ApiStatus.error) {
      return _buildErrorOrTrendingSection(
        context,
        trendingState,
        locals,
        settingsState,
      );
    }

    return _buildFeedSection(
      context,
      trendingState,
      locals,
      subscribeState,
      trendingBloc,
    );
  }

  Widget _buildLoadingList() {
    return ListView.separated(
      separatorBuilder: (context, index) => kHeightBox10,
      itemBuilder: (context, index) {
        return const ShimmerHomeVideoInfoCard();
      },
      itemCount: 10,
    );
  }

  Widget _buildErrorOrTrendingSection(
    BuildContext context,
    TrendingState trendingState,
    S locals,
    SettingsState settingsState,
  ) {
    // NewPipe error handling
    if (settingsState.ytService == YouTubeServices.newpipe.name) {
      if (trendingState.fetchNewPipeTrendingStatus == ApiStatus.error ||
          trendingState.newPipeTrendingResult.isEmpty) {
        return ErrorRetryWidget(
          lottie: 'assets/dog.zip',
          onTap: () => BlocProvider.of<TrendingBloc>(context).add(
            TrendingEvent.getForcedTrendingData(
                serviceType: settingsState.ytService,
                region: settingsState.defaultRegion),
          ),
        );
      }
    } else if (settingsState.ytService == YouTubeServices.invidious.name) {
      if (trendingState.fetchInvidiousTrendingStatus == ApiStatus.error ||
          trendingState.invidiousTrendingResult.isEmpty) {
        return ErrorRetryWidget(
          lottie: 'assets/dog.zip',
          onTap: () => BlocProvider.of<TrendingBloc>(context).add(
            TrendingEvent.getForcedTrendingData(
                serviceType: settingsState.ytService,
                region: settingsState.defaultRegion),
          ),
        );
      }
    } else {
      if (trendingState.fetchTrendingStatus == ApiStatus.error ||
          trendingState.trendingResult.isEmpty) {
        return ErrorRetryWidget(
          lottie: 'assets/dog.zip',
          onTap: () => BlocProvider.of<TrendingBloc>(context).add(
            TrendingEvent.getForcedTrendingData(
                serviceType: settingsState.ytService,
                region: settingsState.defaultRegion),
          ),
        );
      }
    }

    // Return appropriate trending section
    if (settingsState.ytService == YouTubeServices.newpipe.name) {
      return NewPipeTrendingVideosSection(
        locals: locals,
        state: trendingState,
      );
    } else if (settingsState.ytService == YouTubeServices.invidious.name) {
      return InvidiousTrendingVideosSection(
        locals: locals,
        state: trendingState,
      );
    }

    return TrendingVideosSection(
      locals: locals,
      state: trendingState,
    );
  }

  Widget _buildFeedSection(
    BuildContext context,
    TrendingState trendingState,
    S locals,
    SubscribeState subscribeState,
    TrendingBloc trendingBloc,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        trendingBloc.add(TrendingEvent.getForcedHomeFeedData(
          channels: subscribeState.subscribedChannels,
        ));
      },
      child: _padForNavBar(
        context,
        FeedVideoSection(
          trendingState: trendingState,
          locals: locals,
          subscribeState: subscribeState,
        ),
      ),
    );
  }

  Widget _buildEmptySubscriptionState(BuildContext context, S locals) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.subscriptions_outlined,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
            ),
            kHeightBox20,
            Text(
              locals.noSubscriptions,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            kHeightBox10,
            Text(
              locals.noSubscriptionsHint,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
