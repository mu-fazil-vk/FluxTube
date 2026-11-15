import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/animations/animations.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/core/enums.dart';
import 'package:fluxtube/domain/subscribes/models/subscribe.dart';
import 'package:fluxtube/domain/trending/models/newpipe/newpipe_trending_resp.dart';
import 'package:fluxtube/domain/trending/models/piped/trending_resp.dart';
import 'package:fluxtube/domain/watch/models/basic_info.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/presentation/main_navigation/main_navigation_layout.dart';
import 'package:fluxtube/presentation/subscriptions/widgets/channel_cards.dart';
import 'package:fluxtube/presentation/subscriptions/widgets/feed_video_cards.dart';
import 'package:go_router/go_router.dart';

enum SubscriptionSortOption { name, recent }

enum _FeedFilter { all, today, live }

class ScreenSubscriptions extends StatefulWidget {
  const ScreenSubscriptions({super.key});

  @override
  State<ScreenSubscriptions> createState() => _ScreenSubscriptionsState();
}

class _ScreenSubscriptionsState extends State<ScreenSubscriptions>
    with SingleTickerProviderStateMixin {
  bool _hasLoaded = false;
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  SubscriptionSortOption _sortOption = SubscriptionSortOption.name;
  bool _isGridView = true;
  _FeedFilter _feedFilter = _FeedFilter.all;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoaded) {
      _hasLoaded = true;
      _loadSubscriptions();
    }
  }

  void _loadSubscriptions() {
    final currentProfile = context.read<SettingsBloc>().state.currentProfile;
    BlocProvider.of<SubscribeBloc>(context)
        .add(SubscribeEvent.getAllSubscribeList(profileName: currentProfile));

    // Also load feed data
    final subscribeState = context.read<SubscribeBloc>().state;
    final settingsState = context.read<SettingsBloc>().state;
    if (subscribeState.subscribedChannels.isNotEmpty) {
      if (settingsState.ytService == YouTubeServices.newpipe.name) {
        BlocProvider.of<TrendingBloc>(context).add(
          TrendingEvent.getNewPipeHomeFeedData(
            channels: subscribeState.subscribedChannels,
          ),
        );
      } else {
        BlocProvider.of<TrendingBloc>(context).add(
          TrendingEvent.getHomeFeedData(
            channels: subscribeState.subscribedChannels,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Subscribe> _filterAndSortChannels(List<Subscribe> channels) {
    var filtered = channels.where((channel) {
      if (_searchQuery.isEmpty) return true;
      final name = channel.channelName.toLowerCase();
      return name.contains(_searchQuery);
    }).toList();

    switch (_sortOption) {
      case SubscriptionSortOption.name:
        filtered.sort((a, b) =>
            a.channelName.toLowerCase().compareTo(b.channelName.toLowerCase()));
        break;
      case SubscriptionSortOption.recent:
        // For recent, we reverse (most recently added first)
        filtered = filtered.reversed.toList();
        break;
    }

    return filtered;
  }

  bool _matchesPipedFeedFilter(TrendingResp video) {
    switch (_feedFilter) {
      case _FeedFilter.all:
        return true;
      case _FeedFilter.live:
        return video.duration == null || video.duration == -1;
      case _FeedFilter.today:
        final millis = video.uploaded;
        return isUploadedToday(
          uploadedMillis: millis != null && millis > 0 ? millis : null,
          dateText: video.uploadedDate,
        );
    }
  }

  bool _matchesNewPipeFeedFilter(NewPipeTrendingResp video) {
    switch (_feedFilter) {
      case _FeedFilter.all:
        return true;
      case _FeedFilter.live:
        return video.duration == null || video.duration == -1;
      case _FeedFilter.today:
        return isUploadedToday(dateText: video.uploadDate);
    }
  }

  static final _relativeTimeRegex =
      RegExp(r'(\d+)\s*(second|minute|hour)', caseSensitive: false);

  /// Tolerant "uploaded today" check for relative-time strings
  /// ("3 hours ago" => today), epoch millis and ISO dates.
  static bool isUploadedToday({int? uploadedMillis, String? dateText}) {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);

    if (uploadedMillis != null) {
      final date =
          DateTime.fromMillisecondsSinceEpoch(uploadedMillis).toLocal();
      return !date.isBefore(startOfToday);
    }

    final text = dateText?.trim() ?? '';
    if (text.isEmpty) return false;

    // Relative time: "x second(s)/minute(s)/hour(s) ... ago"
    final match = _relativeTimeRegex.firstMatch(text);
    if (match != null) {
      final value = int.tryParse(match.group(1) ?? '') ?? -1;
      if (value >= 0) {
        final unit = match.group(2)!.toLowerCase();
        final seconds = unit == 'second'
            ? value
            : unit == 'minute'
                ? value * 60
                : value * 3600;
        return now.subtract(Duration(seconds: seconds)).isAfter(startOfToday);
      }
      return false;
    }

    // ISO / absolute date fallback
    final parsed = DateTime.tryParse(text);
    if (parsed != null) {
      final local = parsed.isUtc ? parsed.toLocal() : parsed;
      return !local.isBefore(startOfToday);
    }
    return false;
  }

  void _showSortOptions() {
    final theme = Theme.of(context);
    final locals = S.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.topLg,
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: AppRadius.borderFull,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                locals.sortBy,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            AppSpacing.height12,
            _SortOptionTile(
              title: locals.title,
              icon: Icons.text_fields,
              isSelected: _sortOption == SubscriptionSortOption.name,
              onTap: () {
                setState(() => _sortOption = SubscriptionSortOption.name);
                Navigator.pop(context);
              },
            ),
            _SortOptionTile(
              title: locals.dateAdded,
              icon: Icons.calendar_today_outlined,
              isSelected: _sortOption == SubscriptionSortOption.recent,
              onTap: () {
                setState(() => _sortOption = SubscriptionSortOption.recent);
                Navigator.pop(context);
              },
            ),
            AppSpacing.height16,
          ],
        ),
      ),
    );
  }

  void _unsubscribeChannel(Subscribe channel) {
    final currentProfile = context.read<SettingsBloc>().state.currentProfile;
    final subscribeBloc = BlocProvider.of<SubscribeBloc>(context);

    // The BLoC's DeleteSubscribeInfo handler already returns updated list,
    // so the count will update immediately without needing to reload
    subscribeBloc.add(
      SubscribeEvent.deleteSubscribeInfo(
        id: channel.id,
        profileName: currentProfile,
      ),
    );
  }

  void _showUnsubscribeDialog(Subscribe channel) {
    final theme = Theme.of(context);
    final locals = S.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
        title: Text(locals.unsubscribe),
        content: Text(
          '${locals.unsubscribeConfirm}\n\n${channel.channelName}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(locals.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _unsubscribeChannel(channel);
            },
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            child: Text(locals.unsubscribe),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locals = S.of(context);

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        return BlocBuilder<SubscribeBloc, SubscribeState>(
          builder: (context, subscribeState) {
            final channels =
                _filterAndSortChannels(subscribeState.subscribedChannels);
            final isLoading =
                subscribeState.subscribeStatus == ApiStatus.loading ||
                    subscribeState.subscribeStatus == ApiStatus.initial;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // No floating header overlay on this tab (Home-only now) —
                // just clear the status bar.
                SizedBox(height: MediaQuery.paddingOf(context).top),
                // Search pill + view-mode toggle + sort button.
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    10,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            controller: _searchController,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontSize: 14),
                            decoration: InputDecoration(
                              hintText: locals.searchSubscriptions,
                              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 14,
                                color: scheme.onSurfaceVariant,
                              ),
                              prefixIcon: const Icon(Icons.search, size: 18),
                              prefixIconConstraints: const BoxConstraints(
                                minWidth: 36,
                              ),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.cancel,
                                        size: 16,
                                      ),
                                      onPressed: () =>
                                          _searchController.clear(),
                                    )
                                  : null,
                              filled: true,
                              fillColor: scheme.surfaceContainerHigh,
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: AppRadius.borderFull,
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: AppRadius.borderFull,
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: AppRadius.borderFull,
                                borderSide: BorderSide(color: scheme.primary),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                            ),
                          ),
                        ),
                      ),
                      AppSpacing.width8,
                      _ChromeIconButton(
                        icon: _isGridView
                            ? Icons.view_list_outlined
                            : Icons.grid_view_outlined,
                        tooltip: _isGridView ? 'List view' : 'Grid view',
                        onPressed: () {
                          setState(() {
                            _isGridView = !_isGridView;
                          });
                        },
                      ),
                      AppSpacing.width4,
                      _ChromeIconButton(
                        icon: Icons.sort_rounded,
                        tooltip: locals.sort,
                        onPressed: _showSortOptions,
                      ),
                    ],
                  ),
                ),
                // Tab bar.
                TabBar(
                  controller: _tabController,
                  labelColor: scheme.primary,
                  unselectedLabelColor: scheme.onSurfaceVariant,
                  indicatorColor: scheme.primary,
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerColor: Colors.transparent,
                  labelStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                  unselectedLabelStyle: const TextStyle(fontSize: 13),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.people, size: 16),
                          AppSpacing.width4,
                          Text(locals.channels),
                          if (subscribeState.subscribedChannels.isNotEmpty) ...[
                            AppSpacing.width4,
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.primary.withValues(alpha: 0.1),
                                borderRadius: AppRadius.borderFull,
                              ),
                              child: Text(
                                '${subscribeState.subscribedChannels.length}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.smart_display_outlined, size: 16),
                          AppSpacing.width4,
                          Text(locals.videos),
                        ],
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: isLoading
                      ? _buildLoadingState()
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildChannelsTab(channels),
                            _buildFeedTab(settingsState),
                          ],
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingState() {
    final navBottom = MainNavigationLayout.navPadding(context).bottom;
    final gridPadding = EdgeInsets.fromLTRB(
      AppSpacing.lg,
      AppSpacing.md,
      AppSpacing.lg,
      navBottom + AppSpacing.md,
    );

    return _isGridView
        ? GridView.builder(
            padding: gridPadding,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.75,
            ),
            itemCount: 12,
            itemBuilder: (context, index) => const ShimmerChannelCard(),
          )
        : ListView.builder(
            padding: gridPadding,
            itemCount: 10,
            itemBuilder: (context, index) => const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: ShimmerChannelListTile(),
            ),
          );
  }

  Widget _buildChannelsTab(List<Subscribe> channels) {
    final locals = S.of(context);
    final bottomPadding = MainNavigationLayout.navPadding(context).bottom;

    if (channels.isEmpty) {
      return _buildEmptyState(
        locals.noSubscriptions,
        locals.noSubscriptionsHint,
        Icons.person_outline,
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadSubscriptions(),
      child: CustomScrollView(
        slivers: [
          if (_isGridView)
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                bottomPadding + AppSpacing.md,
              ),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: 0.75,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final channel = channels[index];
                    return ChannelGridCard(
                      channel: channel,
                      index: index,
                      onTap: () => _navigateToChannel(channel),
                      onLongPress: () => _showUnsubscribeDialog(channel),
                    );
                  },
                  childCount: channels.length,
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xs,
                AppSpacing.lg,
                bottomPadding + AppSpacing.md,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final channel = channels[index];
                    return ChannelListTile(
                      channel: channel,
                      index: index,
                      onTap: () => _navigateToChannel(channel),
                      onUnsubscribe: () => _showUnsubscribeDialog(channel),
                    );
                  },
                  childCount: channels.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeedTab(SettingsState settingsState) {
    return BlocBuilder<TrendingBloc, TrendingState>(
      buildWhen: (p, c) =>
          p.fetchNewPipeFeedStatus != c.fetchNewPipeFeedStatus ||
          p.fetchFeedStatus != c.fetchFeedStatus ||
          !identical(p.newPipeFeedResult, c.newPipeFeedResult) ||
          !identical(p.feedResult, c.feedResult),
      builder: (context, trendingState) {
        return BlocBuilder<SubscribeBloc, SubscribeState>(
          buildWhen: (p, c) =>
              !identical(p.subscribedChannels, c.subscribedChannels),
          builder: (context, subscribeState) {
            final locals = S.of(context);
            final isNewPipe =
                settingsState.ytService == YouTubeServices.newpipe.name;

            // Check loading state based on service
            final isLoading = isNewPipe
                ? trendingState.fetchNewPipeFeedStatus == ApiStatus.loading
                : trendingState.fetchFeedStatus == ApiStatus.loading;

            // Get feed based on service
            final newPipeFeed = trendingState.newPipeFeedResult;
            final pipedFeed = trendingState.feedResult;
            final feedLength =
                isNewPipe ? newPipeFeed.length : pipedFeed.length;

            if (subscribeState.subscribedChannels.isEmpty) {
              return _buildEmptyState(
                locals.noSubscriptions,
                locals.noSubscriptionsHint,
                Icons.smart_display_outlined,
              );
            }

            // Client-side filter indices.
            final visibleIndices = <int>[];
            for (var i = 0; i < feedLength; i++) {
              final matches = isNewPipe
                  ? _matchesNewPipeFeedFilter(newPipeFeed[i])
                  : _matchesPipedFeedFilter(pipedFeed[i]);
              if (matches) visibleIndices.add(i);
            }

            return Column(
              children: [
                _buildFeedFilterChips(locals),
                Expanded(
                  child: isLoading
                      ? ListView.builder(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            AppSpacing.md,
                            AppSpacing.lg,
                            MainNavigationLayout.navPadding(context).bottom +
                                AppSpacing.md,
                          ),
                          itemCount: 6,
                          itemBuilder: (context, index) => const Padding(
                            padding: EdgeInsets.only(bottom: AppSpacing.md),
                            child: ShimmerVideoCard(),
                          ),
                        )
                      : visibleIndices.isEmpty
                          ? _buildEmptyState(
                              locals.noVideosFound,
                              locals.refreshToLoad,
                              Icons.smart_display_outlined,
                            )
                          : RefreshIndicator(
                              onRefresh: () async {
                                if (isNewPipe) {
                                  BlocProvider.of<TrendingBloc>(context).add(
                                    TrendingEvent.getForcedNewPipeHomeFeedData(
                                      channels:
                                          subscribeState.subscribedChannels,
                                    ),
                                  );
                                } else {
                                  BlocProvider.of<TrendingBloc>(context).add(
                                    TrendingEvent.getForcedHomeFeedData(
                                      channels:
                                          subscribeState.subscribedChannels,
                                    ),
                                  );
                                }
                              },
                              child: ListView.builder(
                                padding: EdgeInsets.fromLTRB(
                                  AppSpacing.lg,
                                  AppSpacing.md,
                                  AppSpacing.lg,
                                  MainNavigationLayout.navPadding(context)
                                          .bottom +
                                      AppSpacing.md,
                                ),
                                itemCount: visibleIndices.length,
                                itemBuilder: (context, listIndex) {
                                  final index = visibleIndices[listIndex];
                                  if (isNewPipe) {
                                    final video = newPipeFeed[index];
                                    final videoId =
                                        video.url?.split('=').last ?? '';
                                    final channelId =
                                        video.uploaderUrl?.split('/').last ??
                                            '';

                                    return FeedVideoCardNewPipe(
                                      video: video,
                                      index: listIndex,
                                      onTap: () => _navigateToVideo(
                                        videoId,
                                        channelId,
                                        video.name,
                                        video.thumbnailUrl,
                                        video.uploaderName,
                                        video.uploaderAvatarUrl,
                                        video.uploaderVerified,
                                      ),
                                    );
                                  } else {
                                    final video = pipedFeed[index];
                                    final videoId =
                                        video.url?.split('=').last ?? '';
                                    final channelId =
                                        video.uploaderUrl?.split('/').last ??
                                            '';

                                    return FeedVideoCardPiped(
                                      video: video,
                                      index: listIndex,
                                      onTap: () => _navigateToVideo(
                                        videoId,
                                        channelId,
                                        video.title,
                                        video.thumbnail,
                                        video.uploaderName,
                                        video.uploaderAvatar,
                                        video.uploaderVerified,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFeedFilterChips(S locals) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    Widget chip(_FeedFilter filter, String label) {
      final isSelected = _feedFilter == filter;
      return Padding(
        padding: const EdgeInsets.only(right: AppSpacing.sm),
        child: ScaleTap(
          onTap: () => setState(() => _feedFilter = filter),
          scaleDown: 0.95,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: isSelected ? scheme.primary : scheme.surfaceContainerHigh,
              borderRadius: AppRadius.borderFull,
            ),
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: isSelected ? scheme.onPrimary : scheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: SizedBox(
        height: 32,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            chip(_FeedFilter.all, locals.all),
            chip(_FeedFilter.today, locals.today),
            chip(_FeedFilter.live, locals.live),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: AppIconSize.xxxl,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
            AppSpacing.height24,
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.height8,
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToChannel(Subscribe channel) {
    context.goNamed('channel', pathParameters: {
      'channelId': channel.id,
    }, queryParameters: {
      'avatarUrl': '',
    });
  }

  void _navigateToVideo(
    String videoId,
    String channelId,
    String? title,
    String? thumbnail,
    String? channelName,
    String? channelThumbnail,
    bool? uploaderVerified,
  ) {
    BlocProvider.of<WatchBloc>(context).add(
      WatchEvent.setSelectedVideoBasicDetails(
        details: VideoBasicInfo(
          id: videoId,
          title: title,
          thumbnailUrl: thumbnail,
          channelName: channelName,
          channelThumbnailUrl: channelThumbnail,
          channelId: channelId,
          uploaderVerified: uploaderVerified,
        ),
      ),
    );
    context.goNamed('watch', pathParameters: {
      'videoId': videoId,
      'channelId': channelId,
    });
  }
}

class _ChromeIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _ChromeIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: scheme.surfaceContainerHigh,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, size: 20, color: scheme.onSurface),
          ),
        ),
      ),
    );
  }
}

class _SortOptionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortOptionTile({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      leading: Icon(
        icon,
        size: 20,
        color: isSelected ? theme.colorScheme.primary : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: isSelected ? theme.colorScheme.primary : null,
          fontWeight: isSelected ? FontWeight.w600 : null,
        ),
      ),
      trailing: isSelected
          ? Icon(
              Icons.check,
              color: theme.colorScheme.primary,
              size: 18,
            )
          : null,
      onTap: onTap,
    );
  }
}
