import 'dart:developer';


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:fluxtube/core/enums.dart';
import 'package:fluxtube/core/strings.dart';
import 'package:fluxtube/domain/channel/models/newpipe/newpipe_channel_resp.dart';
import 'package:fluxtube/domain/channel/models/piped/channel_resp.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/presentation/channel/widgets/invidious/related_videos.dart';
import 'package:fluxtube/presentation/channel/widgets/newpipe/related_videos.dart';
import 'package:fluxtube/presentation/channel/widgets/newpipe/newpipe_channel_tab_content.dart';
import 'package:fluxtube/presentation/channel/widgets/piped/related_videos.dart';
import 'package:fluxtube/presentation/channel/widgets/piped/channel_tab_content.dart';
import 'package:fluxtube/presentation/settings/utils/launch_url.dart';
import 'package:fluxtube/widgets/widgets.dart';

class ScreenChannel extends StatefulWidget {
  const ScreenChannel({super.key, required String? channelId, avatarUrl})
      : _channelId = channelId,
        _avatarUrl = avatarUrl;
  final String? _channelId;
  final String? _avatarUrl;

  @override
  State<ScreenChannel> createState() => _ScreenChannelState();
}

class _ScreenChannelState extends State<ScreenChannel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _hasLoadedChannel = false;

  @override
  void initState() {
    super.initState();
    // TabController for Piped and Invidious (3 tabs: videos, shorts, playlists)
    // NewPipe manages its own TabController dynamically
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChannelData();
    });
  }

  void _loadChannelData() {
    if (_hasLoadedChannel) return;
    if (_channelId != null) {
      final settingsBloc = BlocProvider.of<SettingsBloc>(context);
      BlocProvider.of<ChannelBloc>(context).add(ChannelEvent.getChannelData(
          channelId: _channelId!, serviceType: settingsBloc.state.ytService));
      _hasLoadedChannel = true;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String? get _channelId => widget._channelId;
  String? get _avatarUrl => widget._avatarUrl;

  @override
  Widget build(BuildContext context) {
    final double _width = MediaQuery.of(context).size.width;
    final S locals = S.of(context);
    return BlocBuilder<SubscribeBloc, SubscribeState>(
      buildWhen: (previous, current) =>
          previous.subscribedChannels != current.subscribedChannels,
      builder: (context, subscribeState) {
        return BlocBuilder<ChannelBloc, ChannelState>(
          buildWhen: (previous, current) =>
              previous.channelDetailsFetchStatus !=
                  current.channelDetailsFetchStatus ||
              previous.pipedChannelResp != current.pipedChannelResp ||
              previous.invidiousChannelResp != current.invidiousChannelResp ||
              previous.newPipeChannelResp != current.newPipeChannelResp,
          builder: (context, state) {
            if (state.channelDetailsFetchStatus == ApiStatus.loading ||
                state.channelDetailsFetchStatus == ApiStatus.initial) {
              return Center(child: cIndicator(context));
            } else if (state.channelDetailsFetchStatus == ApiStatus.error) {
              return Center(
                  child: ErrorRetryWidget(
                lottie: 'assets/black-cat.zip',
                onTap: () {
                  _hasLoadedChannel = false;
                  _loadChannelData();
                },
              ));
            } else if (state.pipedChannelResp == null &&
                state.invidiousChannelResp == null &&
                state.newPipeChannelResp == null) {
              // If loaded but all responses are null, retry
              return Center(
                  child: ErrorRetryWidget(
                lottie: 'assets/black-cat.zip',
                onTap: () {
                  _hasLoadedChannel = false;
                  _loadChannelData();
                },
              ));
            }

            final bool _isSubscribed = subscribeState.subscribedChannels
                .where((channel) => channel.id == _channelId)
                .isNotEmpty;

            // NewPipe Channel
            if (state.newPipeChannelResp != null) {
              log("-----------------NewPipe Channel-----------------");
              return _buildNewPipeChannel(
                context: context,
                width: _width,
                locals: locals,
                state: state,
                channelInfo: state.newPipeChannelResp!,
                isSubscribed: _isSubscribed,
              );
            }

            if (state.pipedChannelResp == null &&
                state.invidiousChannelResp != null) {
              log("-----------------Invidious Channel-----------------");
              return Scaffold(
                appBar: AppBar(
                    automaticallyImplyLeading: true,
                    title: Text(
                      state.invidiousChannelResp!.author!,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                    ),
                    actions: [
                      _buildCompactYouTubeButton(
                        context,
                        state.invidiousChannelResp!.authorUrl!,
                      ),
                      const SizedBox(width: 8),
                    ]),
                body: SafeArea(
                    child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          ChannelBannerWidget(
                              width: _width,
                              name: state.invidiousChannelResp!.author,
                              bannerUrl: state.invidiousChannelResp
                                  ?.authorBanners?.last.url),
                          const SizedBox(height: 10),
                          ChannelWidget(
                            channelName: state.invidiousChannelResp!.author,
                            isVerified:
                                state.invidiousChannelResp!.authorVerified,
                            subscriberCount:
                                state.invidiousChannelResp!.subCount,
                            thumbnail: state.invidiousChannelResp
                                    ?.authorThumbnails?.last.url ??
                                _avatarUrl,
                            isSubscribed: _isSubscribed,
                            channelId: _channelId ?? '',
                            locals: locals,
                            isTapEnabled: false,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverTabBarDelegate(
                        TabBar(
                          controller: _tabController,
                          dividerColor: Colors.transparent,
                          tabs: [
                            Tab(text: locals.videos),
                            Tab(text: locals.shorts),
                            Tab(text: locals.playlists),
                          ],
                        ),
                      ),
                    ),
                  ],
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      InvidiousChannelRelatedVideoSection(
                          channelId: _channelId ?? '',
                          locals: locals,
                          state: state,
                          channelInfo: state.invidiousChannelResp!),
                      Center(
                        child: Text(
                          locals.noShorts,
                          style: TextStyle(color: kGreyColor),
                        ),
                      ),
                      Center(
                        child: Text(
                          locals.noPlaylists,
                          style: TextStyle(color: kGreyColor),
                        ),
                      ),
                    ],
                  ),
                )),
              );
            }

            final ChannelResp channelInfo = state.pipedChannelResp!;
            log("-----------------Piped Channel-----------------");

            return Scaffold(
              appBar: AppBar(
                  automaticallyImplyLeading: true,
                  title: Text(
                    channelInfo.name!,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                  ),
                  actions: [
                    _buildCompactYouTubeButton(
                      context,
                      '$kYTChannelUrl${channelInfo.id}',
                    ),
                    const SizedBox(width: 8),
                  ]),
              body: SafeArea(
                  child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        ChannelBannerWidget(
                            width: _width,
                            name: channelInfo.name,
                            bannerUrl: channelInfo.bannerUrl),
                        const SizedBox(height: 10),
                        ChannelWidget(
                          channelName: channelInfo.name,
                          isVerified: channelInfo.verified,
                          subscriberCount: channelInfo.subscriberCount,
                          thumbnail: channelInfo.avatarUrl ?? _avatarUrl,
                          isSubscribed: _isSubscribed,
                          channelId: _channelId ?? '',
                          locals: locals,
                          isTapEnabled: false,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverTabBarDelegate(
                      TabBar(
                        controller: _tabController,
                        dividerColor: Colors.transparent,
                        tabs: [
                          Tab(text: locals.videos),
                          Tab(text: locals.shorts),
                          Tab(text: locals.playlists),
                        ],
                      ),
                    ),
                  ),
                ],
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    ChannelRelatedVideoSection(
                        channelId: _channelId ?? '',
                        locals: locals,
                        state: state,
                        channelInfo: channelInfo),
                    ChannelTabContent(
                        tabs: channelInfo.tabs,
                        tabName: 'shorts',
                        locals: locals),
                    ChannelTabContent(
                        tabs: channelInfo.tabs,
                        tabName: 'playlists',
                        locals: locals),
                  ],
                ),
              )),
            );
          },
        );
      },
    );
  }

  Widget _buildNewPipeChannel({
    required BuildContext context,
    required double width,
    required S locals,
    required ChannelState state,
    required NewPipeChannelResp channelInfo,
    required bool isSubscribed,
  }) {
    return _NewPipeChannelView(
      channelInfo: channelInfo,
      channelId: _channelId ?? '',
      avatarUrl: _avatarUrl,
      width: width,
      locals: locals,
      state: state,
      isSubscribed: isSubscribed,
    );
  }

  /// Compact YouTube button for AppBar
  Widget _buildCompactYouTubeButton(BuildContext context, String url) {
    return IconButton(
      onPressed: () async => await urlLaunchWithSettings(context, url),
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFF0000), // YouTube red
              Color(0xFFCC0000), // Darker red
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF0000).withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SvgPicture.asset(
          'assets/icons/youtube.svg',
          height: 18,
          width: 18,
          colorFilter: const ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          ),
        ),
      ),
      tooltip: 'Open on YouTube',
    );
  }
}

/// Dynamic NewPipe channel view with tabs based on available channel tabs
class _NewPipeChannelView extends StatefulWidget {
  const _NewPipeChannelView({
    required this.channelInfo,
    required this.channelId,
    required this.avatarUrl,
    required this.width,
    required this.locals,
    required this.state,
    required this.isSubscribed,
  });

  final NewPipeChannelResp channelInfo;
  final String channelId;
  final String? avatarUrl;
  final double width;
  final S locals;
  final ChannelState state;
  final bool isSubscribed;

  @override
  State<_NewPipeChannelView> createState() => _NewPipeChannelViewState();
}

class _NewPipeChannelViewState extends State<_NewPipeChannelView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<NewPipeChannelTab> _availableTabs;

  @override
  void initState() {
    super.initState();
    _initializeTabs();
  }

  void _initializeTabs() {
    // Get available tabs from channel info
    _availableTabs = widget.channelInfo.tabs ?? [];

    // If no tabs available, default to showing just videos
    if (_availableTabs.isEmpty) {
      _availableTabs = [
        NewPipeChannelTab(name: 'videos', url: null, id: null, contentFilters: ['videos'])
      ];
    }

    // Initialize tab controller with the number of available tabs
    _tabController = TabController(length: _availableTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getTabDisplayName(String? tabName) {
    if (tabName == null) return widget.locals.videos;

    switch (tabName.toLowerCase()) {
      case 'videos':
        return widget.locals.videos;
      case 'shorts':
        return widget.locals.shorts;
      case 'playlists':
        return widget.locals.playlists;
      case 'livestreams':
      case 'live':
        return 'Livestreams';
      case 'channels':
        return 'Channels';
      case 'albums':
        return 'Albums';
      case 'releases':
        return 'Releases';
      default:
        // Capitalize first letter
        return tabName[0].toUpperCase() + tabName.substring(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text(
            widget.channelInfo.name ?? '',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
          ),
          actions: [
            _buildCompactYouTubeButton(
              context,
              '$kYTChannelUrl${widget.channelInfo.id}',
            ),
            const SizedBox(width: 8),
          ]),
      body: SafeArea(
          child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: Column(
              children: [
                ChannelBannerWidget(
                    width: widget.width,
                    name: widget.channelInfo.name,
                    bannerUrl: widget.channelInfo.bannerUrl),
                const SizedBox(height: 10),
                ChannelWidget(
                  channelName: widget.channelInfo.name,
                  isVerified: widget.channelInfo.isVerified,
                  subscriberCount: widget.channelInfo.subscriberCount,
                  thumbnail: widget.channelInfo.avatarUrl ?? widget.avatarUrl,
                  isSubscribed: widget.isSubscribed,
                  channelId: widget.channelId,
                  locals: widget.locals,
                  isTapEnabled: false,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                isScrollable: _availableTabs.length > 3,
                tabs: _availableTabs.map((tab) {
                  return Tab(text: _getTabDisplayName(tab.name));
                }).toList(),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: _availableTabs.map((tab) {
            final tabName = tab.name?.toLowerCase() ?? 'videos';

            // First tab (usually videos) uses the initial videos from channel response
            if (_availableTabs.indexOf(tab) == 0) {
              return NewPipeChannelRelatedVideoSection(
                channelId: widget.channelId,
                locals: widget.locals,
                state: widget.state,
                channelInfo: widget.channelInfo,
              );
            }

            // Other tabs load content dynamically
            return NewPipeChannelTabContent(
              tabs: widget.channelInfo.tabs,
              tabName: tabName,
              locals: widget.locals,
              channelId: widget.channelId,
            );
          }).toList(),
        ),
      )),
    );
  }

  /// Compact YouTube button for AppBar
  Widget _buildCompactYouTubeButton(BuildContext context, String url) {
    return IconButton(
      onPressed: () async => await urlLaunchWithSettings(context, url),
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFF0000), // YouTube red
              Color(0xFFCC0000), // Darker red
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF0000).withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SvgPicture.asset(
          'assets/icons/youtube.svg',
          height: 18,
          width: 18,
          colorFilter: const ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          ),
        ),
      ),
      tooltip: 'Open on YouTube',
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? Colors.black : Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}

class ChannelBannerWidget extends StatelessWidget {
  const ChannelBannerWidget({
    super.key,
    required double width,
    required this.bannerUrl,
    required this.name,
  }) : _width = width;

  final double _width;
  final String? bannerUrl;
  final String? name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Container(
          width: _width,
          height: 100,
          decoration: BoxDecoration(
              image: bannerUrl == null
                  ? null
                  : DecorationImage(
                      image: cachedThumbnailProvider(bannerUrl!),
                      fit: BoxFit.cover),
              color: kBlackColor.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(10)),
          child: bannerUrl == null
              ? Center(
                  child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    name!,
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColorLight),
                  ),
                ))
              : null),
    );
  }
}
