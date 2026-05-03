import 'package:fluxtube/widgets/thumbnail_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/animations/animations.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/core/enums.dart';
import 'package:fluxtube/core/operations/math_operations.dart';
import 'package:fluxtube/domain/saved/models/local_store.dart';
import 'package:fluxtube/domain/watch/models/basic_info.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:go_router/go_router.dart';

enum SortOption { dateAdded, title, duration }

class ScreenSaved extends StatefulWidget {
  const ScreenSaved({super.key});

  @override
  State<ScreenSaved> createState() => _ScreenSavedState();
}

class _ScreenSavedState extends State<ScreenSaved>
    with SingleTickerProviderStateMixin {
  bool _hasLoaded = false;
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  SortOption _sortOption = SortOption.dateAdded;
  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};

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
      _loadVideos();
    }
  }

  void _loadVideos() {
    final currentProfile = context.read<SettingsBloc>().state.currentProfile;
    BlocProvider.of<SavedBloc>(context)
        .add(SavedEvent.getAllVideoInfoList(profileName: currentProfile));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<LocalStoreVideoInfo> _filterAndSortVideos(
      List<LocalStoreVideoInfo> videos) {
    var filtered = videos.where((video) {
      if (_searchQuery.isEmpty) return true;
      final title = video.title?.toLowerCase() ?? '';
      final uploader = video.uploaderName?.toLowerCase() ?? '';
      return title.contains(_searchQuery) || uploader.contains(_searchQuery);
    }).toList();

    switch (_sortOption) {
      case SortOption.dateAdded:
        filtered.sort((a, b) {
          if (a.time == null && b.time == null) return 0;
          if (a.time == null) return 1;
          if (b.time == null) return -1;
          return b.time!.compareTo(a.time!);
        });
        break;
      case SortOption.title:
        filtered.sort((a, b) =>
            (a.title ?? '').toLowerCase().compareTo((b.title ?? '').toLowerCase()));
        break;
      case SortOption.duration:
        filtered.sort((a, b) => (b.duration ?? 0).compareTo(a.duration ?? 0));
        break;
    }

    return filtered;
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedIds.clear();
      }
    });
  }

  void _toggleVideoSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _selectAll(List<LocalStoreVideoInfo> videos) {
    setState(() {
      _selectedIds.addAll(videos.map((v) => v.id));
    });
  }

  void _deleteSelected() {
    final currentProfile = context.read<SettingsBloc>().state.currentProfile;
    for (final id in _selectedIds) {
      BlocProvider.of<SavedBloc>(context).add(
        SavedEvent.deleteVideoInfo(id: id, profileName: currentProfile),
      );
    }
    setState(() {
      _selectedIds.clear();
      _isSelectionMode = false;
    });
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
              title: locals.dateAdded,
              icon: CupertinoIcons.calendar,
              isSelected: _sortOption == SortOption.dateAdded,
              onTap: () {
                setState(() => _sortOption = SortOption.dateAdded);
                Navigator.pop(context);
              },
            ),
            _SortOptionTile(
              title: locals.title,
              icon: CupertinoIcons.textformat,
              isSelected: _sortOption == SortOption.title,
              onTap: () {
                setState(() => _sortOption = SortOption.title);
                Navigator.pop(context);
              },
            ),
            _SortOptionTile(
              title: locals.duration,
              icon: CupertinoIcons.time,
              isSelected: _sortOption == SortOption.duration,
              onTap: () {
                setState(() => _sortOption = SortOption.duration);
                Navigator.pop(context);
              },
            ),
            AppSpacing.height16,
          ],
        ),
      ),
    );
  }

  void _showClearAllDialog(bool isSaved) {
    final theme = Theme.of(context);
    final locals = S.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.brightness == Brightness.dark
            ? AppColors.surfaceDark
            : AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
        title: Text(isSaved ? locals.clearAllSaved : locals.clearAllHistory),
        content: Text(
          isSaved ? locals.clearAllSavedConfirm : locals.clearAllHistoryConfirm,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(locals.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearAll(isSaved);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(locals.clearAll),
          ),
        ],
      ),
    );
  }

  void _clearAll(bool isSaved) {
    final savedBloc = BlocProvider.of<SavedBloc>(context);
    final currentProfile = context.read<SettingsBloc>().state.currentProfile;
    final videos = isSaved
        ? savedBloc.state.localSavedVideos
        : savedBloc.state.localSavedHistoryVideos;

    // The BLoC's AddVideoInfo handler already returns updated lists,
    // so the count will update immediately without needing to reload
    for (final video in videos) {
      if (isSaved) {
        // For saved videos, update isSaved to false
        savedBloc.add(SavedEvent.addVideoInfo(
          videoInfo: LocalStoreVideoInfo(
            id: video.id,
            title: video.title,
            views: video.views,
            thumbnail: video.thumbnail,
            uploadedDate: video.uploadedDate,
            uploaderAvatar: video.uploaderAvatar,
            uploaderName: video.uploaderName,
            uploaderId: video.uploaderId,
            uploaderSubscriberCount: video.uploaderSubscriberCount,
            duration: video.duration,
            uploaderVerified: video.uploaderVerified,
            isSaved: false,
            isHistory: video.isHistory,
            isLive: video.isLive,
            playbackPosition: video.playbackPosition,
          ),
          profileName: currentProfile,
        ));
      } else {
        // For history, update isHistory to false
        savedBloc.add(SavedEvent.addVideoInfo(
          videoInfo: LocalStoreVideoInfo(
            id: video.id,
            title: video.title,
            views: video.views,
            thumbnail: video.thumbnail,
            uploadedDate: video.uploadedDate,
            uploaderAvatar: video.uploaderAvatar,
            uploaderName: video.uploaderName,
            uploaderId: video.uploaderId,
            uploaderSubscriberCount: video.uploaderSubscriberCount,
            duration: video.duration,
            uploaderVerified: video.uploaderVerified,
            isSaved: video.isSaved,
            isHistory: false,
            isLive: video.isLive,
            playbackPosition: video.playbackPosition,
          ),
          profileName: currentProfile,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final locals = S.of(context);

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        return BlocBuilder<SavedBloc, SavedState>(
          builder: (context, savedState) {
            final savedVideos = _filterAndSortVideos(savedState.localSavedVideos);
            final historyVideos = _filterAndSortVideos(savedState.localSavedHistoryVideos);
            final isLoading = savedState.savedVideosFetchStatus == ApiStatus.loading ||
                savedState.savedVideosFetchStatus == ApiStatus.initial;

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
                        child: _isSelectionMode
                            ? Text(
                                '${_selectedIds.length} ${locals.selected}',
                                style: theme.textTheme.titleLarge,
                              )
                            : ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [Color(0xFFFF4444), Color(0xFFCC0000)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds),
                                child: Text(
                                  locals.library,
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
                        if (_isSelectionMode) ...[
                          IconButton(
                            icon: const Icon(CupertinoIcons.checkmark_square),
                            onPressed: () => _selectAll(
                              _tabController.index == 0 ? savedVideos : historyVideos,
                            ),
                            tooltip: locals.selectAll,
                          ),
                          IconButton(
                            icon: const Icon(CupertinoIcons.delete),
                            onPressed: _selectedIds.isEmpty ? null : _deleteSelected,
                            color: AppColors.error,
                            tooltip: locals.delete,
                          ),
                          IconButton(
                            icon: const Icon(CupertinoIcons.xmark),
                            onPressed: _toggleSelectionMode,
                            tooltip: locals.cancel,
                          ),
                        ] else ...[
                          IconButton(
                            icon: const Icon(CupertinoIcons.sort_down),
                            onPressed: _showSortOptions,
                            tooltip: locals.sort,
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(CupertinoIcons.ellipsis_vertical),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.borderMd,
                            ),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'select',
                                child: Row(
                                  children: [
                                    const Icon(CupertinoIcons.checkmark_circle, size: AppIconSize.sm),
                                    AppSpacing.width12,
                                    Text(locals.selectVideos),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'clear_saved',
                                child: Row(
                                  children: [
                                    Icon(CupertinoIcons.bookmark_fill,
                                      size: AppIconSize.sm,
                                      color: AppColors.error,
                                    ),
                                    AppSpacing.width12,
                                    Text(locals.clearAllSaved,
                                      style: TextStyle(color: AppColors.error),
                                    ),
                                  ],
                                ),
                              ),
                              if (settingsState.isHistoryVisible)
                                PopupMenuItem(
                                  value: 'clear_history',
                                  child: Row(
                                    children: [
                                      Icon(CupertinoIcons.time,
                                        size: AppIconSize.sm,
                                        color: AppColors.error,
                                      ),
                                      AppSpacing.width12,
                                      Text(locals.clearAllHistory,
                                        style: TextStyle(color: AppColors.error),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                            onSelected: (value) {
                              switch (value) {
                                case 'select':
                                  _toggleSelectionMode();
                                  break;
                                case 'clear_saved':
                                  _showClearAllDialog(true);
                                  break;
                                case 'clear_history':
                                  _showClearAllDialog(false);
                                  break;
                              }
                            },
                          ),
                        ],
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
                              hintText: locals.searchSavedVideos,
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
                                  const Icon(CupertinoIcons.bookmark_fill, size: 16),
                                  AppSpacing.width4,
                                  Text(locals.saved),
                                  if (savedState.localSavedVideos.isNotEmpty) ...[
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
                                        '${savedState.localSavedVideos.length}',
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
                            if (settingsState.isHistoryVisible)
                              Tab(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(CupertinoIcons.time, size: 16),
                                    AppSpacing.width4,
                                    Text(locals.history),
                                    if (savedState.localSavedHistoryVideos.isNotEmpty) ...[
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
                                          '${savedState.localSavedHistoryVideos.length}',
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
                          ],
                        ),
                        isDark: isDark,
                        savedCount: savedState.localSavedVideos.length,
                        historyCount: savedState.localSavedHistoryVideos.length,
                      ),
                    ),
                  ],
                  body: isLoading
                      ? _buildLoadingState()
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildVideoList(
                              savedVideos,
                              locals.noSavedVideos,
                              locals.startSavingVideos,
                              CupertinoIcons.bookmark,
                              isSaved: true,
                            ),
                            if (settingsState.isHistoryVisible)
                              _buildVideoList(
                                historyVideos,
                                locals.noHistory,
                                locals.watchSomeVideos,
                                CupertinoIcons.time,
                                isSaved: false,
                              ),
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
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: 6,
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.md),
        child: ShimmerVideoCard(),
      ),
    );
  }

  Widget _buildVideoList(
    List<LocalStoreVideoInfo> videos,
    String emptyTitle,
    String emptySubtitle,
    IconData emptyIcon, {
    required bool isSaved,
  }) {
    if (videos.isEmpty) {
      return _buildEmptyState(emptyTitle, emptySubtitle, emptyIcon);
    }

    return RefreshIndicator(
      onRefresh: () async => _loadVideos(),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];
          return _SavedVideoCard(
            video: video,
            index: index,
            isSelectionMode: _isSelectionMode,
            isSelected: _selectedIds.contains(video.id),
            onTap: () {
              if (_isSelectionMode) {
                _toggleVideoSelection(video.id);
              } else {
                _navigateToVideo(video);
              }
            },
            onLongPress: () {
              if (!_isSelectionMode) {
                _toggleSelectionMode();
                _toggleVideoSelection(video.id);
              }
            },
            onDelete: () => _deleteVideo(video, isSaved),
            isSaved: isSaved,
          );
        },
      ),
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

  void _navigateToVideo(LocalStoreVideoInfo video) {
    final channelId = video.uploaderId ?? '';
    BlocProvider.of<WatchBloc>(context).add(
      WatchEvent.setSelectedVideoBasicDetails(
        details: VideoBasicInfo(
          id: video.id,
          title: video.title,
          thumbnailUrl: video.thumbnail,
          channelName: video.uploaderName,
          channelThumbnailUrl: video.uploaderAvatar,
          channelId: channelId,
          uploaderVerified: video.uploaderVerified,
        ),
      ),
    );
    context.goNamed('watch', pathParameters: {
      'videoId': video.id,
      'channelId': channelId,
    });
  }

  void _deleteVideo(LocalStoreVideoInfo video, bool isSaved) {
    final currentProfile = context.read<SettingsBloc>().state.currentProfile;
    final savedBloc = BlocProvider.of<SavedBloc>(context);

    // Update the video to remove from saved/history
    // The BLoC's AddVideoInfo handler already returns updated lists,
    // so the count will update immediately without needing to reload
    savedBloc.add(
      SavedEvent.addVideoInfo(
        videoInfo: LocalStoreVideoInfo(
          id: video.id,
          title: video.title,
          views: video.views,
          thumbnail: video.thumbnail,
          uploadedDate: video.uploadedDate,
          uploaderAvatar: video.uploaderAvatar,
          uploaderName: video.uploaderName,
          uploaderId: video.uploaderId,
          uploaderSubscriberCount: video.uploaderSubscriberCount,
          duration: video.duration,
          uploaderVerified: video.uploaderVerified,
          isSaved: isSaved ? false : video.isSaved,
          isHistory: isSaved ? video.isHistory : false,
          isLive: video.isLive,
          playbackPosition: video.playbackPosition,
        ),
        profileName: currentProfile,
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final bool isDark;
  final int savedCount;
  final int historyCount;

  _SliverTabBarDelegate(this.tabBar, {
    required this.isDark,
    required this.savedCount,
    required this.historyCount,
  });

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
    // Rebuild when counts change so the tab badges update
    return oldDelegate.savedCount != savedCount ||
        oldDelegate.historyCount != historyCount ||
        oldDelegate.isDark != isDark;
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

class _SavedVideoCard extends StatelessWidget {
  final LocalStoreVideoInfo video;
  final int index;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onDelete;
  final bool isSaved;

  const _SavedVideoCard({
    required this.video,
    required this.index,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    required this.onDelete,
    required this.isSaved,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final locals = S.of(context);
    final duration = formatDuration(video.isLive == true ? -1 : video.duration);
    final isLive = duration == "Live";
    final progress = video.duration != null && video.duration! > 0 && video.playbackPosition != null
        ? (video.playbackPosition! / video.duration!).clamp(0.0, 1.0)
        : 0.0;

    return AnimatedListItem(
      index: index,
      child: Dismissible(
        key: Key(video.id),
        direction: DismissDirection.endToStart,
        background: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: AppRadius.borderMd,
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: AppSpacing.xl),
          child: const Icon(
            CupertinoIcons.delete,
            color: Colors.white,
          ),
        ),
        confirmDismiss: (direction) async {
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(locals.deleteVideo),
              content: Text(locals.deleteVideoConfirm),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(locals.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                  child: Text(locals.delete),
                ),
              ],
            ),
          ) ?? false;
        },
        onDismissed: (_) => onDelete(),
        child: ScaleTap(
          onTap: onTap,
          onLongPress: onLongPress,
          scaleDown: 0.98,
          child: Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : (isDark ? AppColors.cardDark : AppColors.cardLight),
              borderRadius: AppRadius.borderMd,
              border: isSelected
                  ? Border.all(color: AppColors.primary, width: 2)
                  : null,
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
                // Selection checkbox
                if (isSelectionMode)
                  Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.md),
                    child: Icon(
                      isSelected
                          ? CupertinoIcons.checkmark_circle_fill
                          : CupertinoIcons.circle,
                      color: isSelected ? AppColors.primary : AppColors.disabled,
                    ),
                  ),

                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isSelectionMode ? 0 : AppRadius.md),
                    bottomLeft: Radius.circular(isSelectionMode ? 0 : AppRadius.md),
                  ),
                  child: SizedBox(
                    width: 160,
                    height: 90,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (video.thumbnail != null)
                          ThumbnailImage.small(url: video.thumbnail!),

                        // Duration badge
                        Positioned(
                          bottom: AppSpacing.xs,
                          right: AppSpacing.xs,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: AppSpacing.xxs,
                            ),
                            decoration: BoxDecoration(
                              color: isLive ? AppColors.youtubeRed : kBlackColor,
                              borderRadius: AppRadius.borderXs,
                            ),
                            child: Text(
                              duration,
                              style: const TextStyle(
                                color: kWhiteColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        // Progress bar
                        if (progress > 0 && !isLive)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.transparent,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.youtubeRed,
                              ),
                              minHeight: 3,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Video info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
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
                        Text(
                          video.uploaderName ?? locals.noUploaderName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.onSurfaceVariantDark
                                : AppColors.onSurfaceVariant,
                          ),
                        ),
                        AppSpacing.height4,
                        Row(
                          children: [
                            if (video.views != null) ...[
                              Text(
                                '${formatCount(video.views.toString())} ${locals.views}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? AppColors.onSurfaceVariantDark
                                      : AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Options button
                if (!isSelectionMode)
                  PopupMenuButton<String>(
                    icon: Icon(
                      CupertinoIcons.ellipsis_vertical,
                      color: isDark
                          ? AppColors.onSurfaceVariantDark
                          : AppColors.onSurfaceVariant,
                      size: AppIconSize.sm,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.borderMd,
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(CupertinoIcons.delete,
                              size: AppIconSize.sm,
                              color: AppColors.error,
                            ),
                            AppSpacing.width12,
                            Text(
                              isSaved ? locals.removeFromSaved : locals.removeFromHistory,
                              style: TextStyle(color: AppColors.error),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'delete') {
                        onDelete();
                      }
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ShimmerVideoCard extends StatelessWidget {
  const ShimmerVideoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: AppRadius.borderMd,
      ),
      child: Row(
        children: [
          Container(
            width: 160,
            height: 90,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.md),
                bottomLeft: Radius.circular(AppRadius.md),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 14,
                    width: double.infinity,
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
          ),
        ],
      ),
    );
  }
}
