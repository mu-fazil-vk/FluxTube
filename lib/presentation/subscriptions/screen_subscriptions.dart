import 'package:flutter/cupertino.dart';
import 'package:fluxtube/widgets/thumbnail_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/animations/animations.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/core/enums.dart';
import 'package:fluxtube/core/operations/math_operations.dart';
import 'package:fluxtube/domain/subscribes/models/subscribe.dart';
import 'package:fluxtube/domain/trending/models/newpipe/newpipe_trending_resp.dart';
import 'package:fluxtube/domain/trending/models/piped/trending_resp.dart';
import 'package:fluxtube/domain/watch/models/basic_info.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:go_router/go_router.dart';

// Widget to display channel avatar from either URL or initial

enum SubscriptionSortOption { name, recent }
enum SubscriptionViewMode { channels, feed }

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

  void _showSortOptions() {
    final theme = Theme.of(context);
    final locals = S.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.brightness == Brightness.dark
          ? AppColors.surfaceDark
          : AppColors.surface,
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
                color: AppColors.disabled,
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
              icon: CupertinoIcons.textformat,
              isSelected: _sortOption == SubscriptionSortOption.name,
              onTap: () {
                setState(() => _sortOption = SubscriptionSortOption.name);
                Navigator.pop(context);
              },
            ),
            _SortOptionTile(
              title: locals.dateAdded,
              icon: CupertinoIcons.calendar,
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
        backgroundColor: theme.brightness == Brightness.dark
            ? AppColors.surfaceDark
            : AppColors.surface,
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
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(locals.unsubscribe),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final locals = S.of(context);

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        return BlocBuilder<SubscribeBloc, SubscribeState>(
          builder: (context, subscribeState) {
            final channels = _filterAndSortChannels(subscribeState.subscribedChannels);
            final isLoading = subscribeState.subscribeStatus == ApiStatus.loading ||
                subscribeState.subscribeStatus == ApiStatus.initial;

            return Scaffold(
              backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
              body: SafeArea(
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    // App Bar
                    SliverAppBar(
                      floating: true,
                      snap: true,
                      toolbarHeight: 60,
                      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
                      elevation: 0,
                      surfaceTintColor: kWhiteColor,
                      title: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFFFF4444), Color(0xFFCC0000)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: Text(
                            locals.subscriptions,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 24,
                              letterSpacing: -0.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      actions: [
                        // View mode toggle
                        IconButton(
                          icon: Icon(
                            _isGridView
                                ? CupertinoIcons.list_bullet
                                : CupertinoIcons.square_grid_2x2,
                          ),
                          onPressed: () {
                            setState(() {
                              _isGridView = !_isGridView;
                            });
                          },
                          tooltip: _isGridView ? 'List view' : 'Grid view',
                        ),
                        IconButton(
                          icon: const Icon(CupertinoIcons.sort_down),
                          onPressed: _showSortOptions,
                          tooltip: locals.sort,
                        ),
                      ],
                    ),

                    // Search Bar
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            controller: _searchController,
                            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                            decoration: InputDecoration(
                              hintText: locals.searchSubscriptions,
                              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 14,
                                color: isDark
                                    ? AppColors.onSurfaceVariantDark
                                    : AppColors.onSurfaceVariant,
                              ),
                              prefixIcon: const Icon(CupertinoIcons.search, size: 18),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(CupertinoIcons.xmark_circle_fill, size: 16),
                                      onPressed: () => _searchController.clear(),
                                    )
                                  : null,
                              filled: true,
                              fillColor: isDark
                                  ? AppColors.surfaceVariantDark
                                  : AppColors.surfaceVariant,
                              border: OutlineInputBorder(
                                borderRadius: AppRadius.borderMd,
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Tab Bar
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverTabBarDelegate(
                        TabBar(
                          controller: _tabController,
                          labelColor: AppColors.primary,
                          unselectedLabelColor: isDark
                              ? AppColors.onSurfaceVariantDark
                              : AppColors.onSurfaceVariant,
                          indicatorColor: AppColors.primary,
                          indicatorSize: TabBarIndicatorSize.label,
                          dividerColor: Colors.transparent,
                          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          unselectedLabelStyle: const TextStyle(fontSize: 13),
                          tabs: [
                            Tab(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(CupertinoIcons.person_2_fill, size: 16),
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
                                        color: AppColors.primary.withValues(alpha: 0.1),
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
                                  const Icon(CupertinoIcons.play_rectangle_fill, size: 16),
                                  AppSpacing.width4,
                                  Text(locals.videos),
                                ],
                              ),
                            ),
                          ],
                        ),
                        isDark: isDark,
                        channelCount: subscribeState.subscribedChannels.length,
                      ),
                    ),
                  ],
                  body: isLoading
                      ? _buildLoadingState()
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildChannelsTab(channels, isDark),
                            _buildFeedTab(settingsState, isDark),
                          ],
                        ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return _isGridView
        ? GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.75,
            ),
            itemCount: 12,
            itemBuilder: (context, index) => const _ShimmerChannelCard(),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: 10,
            itemBuilder: (context, index) => const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: _ShimmerChannelListTile(),
            ),
          );
  }

  Widget _buildChannelsTab(List<Subscribe> channels, bool isDark) {
    final locals = S.of(context);

    if (channels.isEmpty) {
      return _buildEmptyState(
        locals.noSubscriptions,
        locals.noSubscriptionsHint,
        CupertinoIcons.person_2,
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadSubscriptions(),
      child: _isGridView
          ? GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 0.75,
              ),
              itemCount: channels.length,
              itemBuilder: (context, index) {
                final channel = channels[index];
                return _ChannelGridCard(
                  channel: channel,
                  index: index,
                  onTap: () => _navigateToChannel(channel),
                  onLongPress: () => _showUnsubscribeDialog(channel),
                );
              },
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: channels.length,
              itemBuilder: (context, index) {
                final channel = channels[index];
                return _ChannelListTile(
                  channel: channel,
                  index: index,
                  onTap: () => _navigateToChannel(channel),
                  onUnsubscribe: () => _showUnsubscribeDialog(channel),
                );
              },
            ),
    );
  }

  Widget _buildFeedTab(SettingsState settingsState, bool isDark) {
    return BlocBuilder<TrendingBloc, TrendingState>(
      builder: (context, trendingState) {
        return BlocBuilder<SubscribeBloc, SubscribeState>(
          builder: (context, subscribeState) {
            final locals = S.of(context);
            final isNewPipe = settingsState.ytService == YouTubeServices.newpipe.name;

            // Check loading state based on service
            final isLoading = isNewPipe
                ? trendingState.fetchNewPipeFeedStatus == ApiStatus.loading
                : trendingState.fetchFeedStatus == ApiStatus.loading;

            // Get feed based on service
            final newPipeFeed = trendingState.newPipeFeedResult;
            final pipedFeed = trendingState.feedResult;
            final feedLength = isNewPipe ? newPipeFeed.length : pipedFeed.length;

            if (subscribeState.subscribedChannels.isEmpty) {
              return _buildEmptyState(
                locals.noSubscriptions,
                locals.noSubscriptionsHint,
                CupertinoIcons.play_rectangle,
              );
            }

            if (isLoading) {
              return ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: 6,
                itemBuilder: (context, index) => const Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.md),
                  child: _ShimmerVideoCard(),
                ),
              );
            }

            if (feedLength == 0) {
              return _buildEmptyState(
                locals.noVideosFound,
                locals.refreshToLoad,
                CupertinoIcons.play_rectangle,
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                if (isNewPipe) {
                  BlocProvider.of<TrendingBloc>(context).add(
                    TrendingEvent.getForcedNewPipeHomeFeedData(
                      channels: subscribeState.subscribedChannels,
                    ),
                  );
                } else {
                  BlocProvider.of<TrendingBloc>(context).add(
                    TrendingEvent.getForcedHomeFeedData(
                      channels: subscribeState.subscribedChannels,
                    ),
                  );
                }
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: feedLength,
                itemBuilder: (context, index) {
                  if (isNewPipe) {
                    final video = newPipeFeed[index];
                    final videoId = video.url?.split('=').last ?? '';
                    final channelId = video.uploaderUrl?.split('/').last ?? '';

                    return _FeedVideoCardNewPipe(
                      video: video,
                      index: index,
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
                    final videoId = video.url?.split('=').last ?? '';
                    final channelId = video.uploaderUrl?.split('/').last ?? '';

                    return _FeedVideoCardPiped(
                      video: video,
                      index: index,
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
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceVariantDark
                    : AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: AppIconSize.xxxl,
                color: AppColors.disabled,
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
                color: isDark
                    ? AppColors.onSurfaceVariantDark
                    : AppColors.onSurfaceVariant,
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

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final bool isDark;
  final int channelCount;

  _SliverTabBarDelegate(this.tabBar, {required this.isDark, required this.channelCount});

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: isDark ? AppColors.backgroundDark : AppColors.background,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    // Rebuild when channel count changes so the tab badge updates
    return oldDelegate.channelCount != channelCount || oldDelegate.isDark != isDark;
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
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      leading: Icon(
        icon,
        size: 20,
        color: isSelected ? AppColors.primary : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: isSelected ? AppColors.primary : null,
          fontWeight: isSelected ? FontWeight.w600 : null,
        ),
      ),
      trailing: isSelected
          ? const Icon(CupertinoIcons.checkmark, color: AppColors.primary, size: 18)
          : null,
      onTap: onTap,
    );
  }
}

class _ChannelGridCard extends StatelessWidget {
  final Subscribe channel;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ChannelGridCard({
    required this.channel,
    required this.index,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedListItem(
      index: index,
      child: ScaleTap(
        onTap: onTap,
        onLongPress: onLongPress,
        scaleDown: 0.95,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: AppRadius.borderMd,
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Channel avatar
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? AppColors.surfaceVariantDark
                      : AppColors.surfaceVariant,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: channel.avatarUrl != null && channel.avatarUrl!.isNotEmpty
                      ? ThumbnailImage.small(
                          url: channel.avatarUrl!,
                          width: 64,
                          height: 64,
                          errorWidget: (_, __, ___) => Center(
                            child: Text(
                              channel.channelName.isNotEmpty
                                  ? channel.channelName[0].toUpperCase()
                                  : '?',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            channel.channelName.isNotEmpty
                                ? channel.channelName[0].toUpperCase()
                                : '?',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
              ),
              AppSpacing.height12,
              // Channel name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        channel.channelName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (channel.isVerified == true) ...[
                      AppSpacing.width4,
                      Icon(
                        CupertinoIcons.checkmark_seal_fill,
                        size: 12,
                        color: isDark
                            ? AppColors.onSurfaceVariantDark
                            : AppColors.onSurfaceVariant,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChannelListTile extends StatelessWidget {
  final Subscribe channel;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onUnsubscribe;

  const _ChannelListTile({
    required this.channel,
    required this.index,
    required this.onTap,
    required this.onUnsubscribe,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final locals = S.of(context);

    return AnimatedListItem(
      index: index,
      child: ScaleTap(
        onTap: onTap,
        scaleDown: 0.98,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: AppRadius.borderMd,
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            children: [
              // Channel avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? AppColors.surfaceVariantDark
                      : AppColors.surfaceVariant,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: channel.avatarUrl != null && channel.avatarUrl!.isNotEmpty
                      ? ThumbnailImage.small(
                          url: channel.avatarUrl!,
                          width: 48,
                          height: 48,
                          errorWidget: (_, __, ___) => Center(
                            child: Text(
                              channel.channelName.isNotEmpty
                                  ? channel.channelName[0].toUpperCase()
                                  : '?',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            channel.channelName.isNotEmpty
                                ? channel.channelName[0].toUpperCase()
                                : '?',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
              ),
              AppSpacing.width12,
              // Channel name
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        channel.channelName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (channel.isVerified == true) ...[
                      AppSpacing.width4,
                      Icon(
                        CupertinoIcons.checkmark_seal_fill,
                        size: 14,
                        color: isDark
                            ? AppColors.onSurfaceVariantDark
                            : AppColors.onSurfaceVariant,
                      ),
                    ],
                  ],
                ),
              ),
              // Unsubscribe button
              TextButton(
                onPressed: onUnsubscribe,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.subscribedRed,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
                child: Text(
                  locals.unsubscribe,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedVideoCardPiped extends StatelessWidget {
  final TrendingResp video;
  final int index;
  final VoidCallback onTap;

  const _FeedVideoCardPiped({
    required this.video,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final locals = S.of(context);
    final duration = formatDuration(video.duration ?? 0);
    final isLive = video.duration == null || video.duration == -1;

    return AnimatedListItem(
      index: index,
      child: ScaleTap(
        onTap: onTap,
        scaleDown: 0.98,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: AppRadius.borderMd,
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.md),
                  topRight: Radius.circular(AppRadius.md),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (video.thumbnail != null)
                        ThumbnailImage.small(url: video.thumbnail!),
                      // Duration badge
                      Positioned(
                        bottom: AppSpacing.sm,
                        right: AppSpacing.sm,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: isLive ? AppColors.youtubeRed : kBlackColor,
                            borderRadius: AppRadius.borderXs,
                          ),
                          child: Text(
                            isLive ? 'LIVE' : duration,
                            style: const TextStyle(
                              color: kWhiteColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Video info
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Channel avatar
                    if (video.uploaderAvatar != null)
                      ClipOval(
                        child: ThumbnailImage.small(
                          url: video.uploaderAvatar!,
                          width: 36,
                          height: 36,
                          errorWidget: (_, __, ___) => Container(
                            width: 36,
                            height: 36,
                            color: isDark
                                ? AppColors.surfaceVariantDark
                                : AppColors.surfaceVariant,
                            child: const Icon(CupertinoIcons.person_fill, size: 20),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? AppColors.surfaceVariantDark
                              : AppColors.surfaceVariant,
                        ),
                        child: const Icon(CupertinoIcons.person_fill, size: 20),
                      ),
                    AppSpacing.width12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            video.title ?? locals.noVideoTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                          ),
                          AppSpacing.height4,
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  video.uploaderName ?? locals.noUploaderName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isDark
                                        ? AppColors.onSurfaceVariantDark
                                        : AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              if (video.uploaderVerified == true) ...[
                                AppSpacing.width4,
                                Icon(
                                  CupertinoIcons.checkmark_seal_fill,
                                  size: 12,
                                  color: isDark
                                      ? AppColors.onSurfaceVariantDark
                                      : AppColors.onSurfaceVariant,
                                ),
                              ],
                            ],
                          ),
                          AppSpacing.height2,
                          Text(
                            '${formatCount(video.views?.toString() ?? '0')} ${locals.views} • ${video.uploadedDate ?? video.uploaded ?? ''}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppColors.onSurfaceVariantDark
                                  : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedVideoCardNewPipe extends StatelessWidget {
  final NewPipeTrendingResp video;
  final int index;
  final VoidCallback onTap;

  const _FeedVideoCardNewPipe({
    required this.video,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final locals = S.of(context);
    final duration = formatDuration(video.duration ?? 0);
    final isLive = video.duration == null || video.duration == -1;

    return AnimatedListItem(
      index: index,
      child: ScaleTap(
        onTap: onTap,
        scaleDown: 0.98,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: AppRadius.borderMd,
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.md),
                  topRight: Radius.circular(AppRadius.md),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (video.thumbnailUrl != null)
                        ThumbnailImage.small(url: video.thumbnailUrl!),
                      // Duration badge
                      Positioned(
                        bottom: AppSpacing.sm,
                        right: AppSpacing.sm,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: isLive ? AppColors.youtubeRed : kBlackColor,
                            borderRadius: AppRadius.borderXs,
                          ),
                          child: Text(
                            isLive ? 'LIVE' : duration,
                            style: const TextStyle(
                              color: kWhiteColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Video info
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Channel avatar
                    if (video.uploaderAvatarUrl != null)
                      ClipOval(
                        child: ThumbnailImage.small(
                          url: video.uploaderAvatarUrl!,
                          width: 36,
                          height: 36,
                          errorWidget: (_, __, ___) => Container(
                            width: 36,
                            height: 36,
                            color: isDark
                                ? AppColors.surfaceVariantDark
                                : AppColors.surfaceVariant,
                            child: const Icon(CupertinoIcons.person_fill, size: 20),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? AppColors.surfaceVariantDark
                              : AppColors.surfaceVariant,
                        ),
                        child: const Icon(CupertinoIcons.person_fill, size: 20),
                      ),
                    AppSpacing.width12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            video.name ?? locals.noVideoTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                          ),
                          AppSpacing.height4,
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  video.uploaderName ?? locals.noUploaderName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isDark
                                        ? AppColors.onSurfaceVariantDark
                                        : AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              if (video.uploaderVerified == true) ...[
                                AppSpacing.width4,
                                Icon(
                                  CupertinoIcons.checkmark_seal_fill,
                                  size: 12,
                                  color: isDark
                                      ? AppColors.onSurfaceVariantDark
                                      : AppColors.onSurfaceVariant,
                                ),
                              ],
                            ],
                          ),
                          AppSpacing.height2,
                          Text(
                            '${formatCount(video.viewCount?.toString() ?? '0')} ${locals.views} • ${video.uploadDate ?? ''}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppColors.onSurfaceVariantDark
                                  : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShimmerChannelCard extends StatelessWidget {
  const _ShimmerChannelCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: AppRadius.borderMd,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
            ),
          ),
          AppSpacing.height12,
          Container(
            height: 12,
            width: 60,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
              borderRadius: AppRadius.borderXs,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerChannelListTile extends StatelessWidget {
  const _ShimmerChannelListTile();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: AppRadius.borderMd,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
            ),
          ),
          AppSpacing.width12,
          Expanded(
            child: Container(
              height: 14,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
                borderRadius: AppRadius.borderXs,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerVideoCard extends StatelessWidget {
  const _ShimmerVideoCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: AppRadius.borderMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.md),
                  topRight: Radius.circular(AppRadius.md),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
                  ),
                ),
                AppSpacing.width12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
                          borderRadius: AppRadius.borderXs,
                        ),
                      ),
                      AppSpacing.height8,
                      Container(
                        height: 12,
                        width: 100,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
                          borderRadius: AppRadius.borderXs,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
