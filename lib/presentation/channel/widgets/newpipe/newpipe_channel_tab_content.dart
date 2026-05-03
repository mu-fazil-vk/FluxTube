
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/subscribe/subscribe_bloc.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:fluxtube/domain/channel/models/newpipe/newpipe_channel_resp.dart';
import 'package:fluxtube/domain/watch/models/newpipe/newpipe_related.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/infrastructure/newpipe/newpipe_channel.dart';
import 'package:fluxtube/presentation/channel/widgets/newpipe/newpipe_channel_video_card.dart';
import 'package:fluxtube/presentation/shorts/screen_shorts.dart';
import 'package:fluxtube/widgets/widgets.dart';
import 'package:go_router/go_router.dart';

/// Widget to display NewPipe channel tab content (shorts/playlists)
class NewPipeChannelTabContent extends StatefulWidget {
  const NewPipeChannelTabContent({
    super.key,
    required this.tabs,
    required this.tabName,
    required this.locals,
    required this.channelId,
  });

  final List<NewPipeChannelTab>? tabs;
  final String tabName;
  final S locals;
  final String channelId;

  @override
  State<NewPipeChannelTabContent> createState() =>
      _NewPipeChannelTabContentState();
}

class _NewPipeChannelTabContentState extends State<NewPipeChannelTabContent> {
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  List<NewPipeRelatedStream> _allContent = [];
  String? _nextPage;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _loadTabContent();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore &&
        _nextPage != null) {
      _loadMore();
    }
  }

  Future<void> _loadTabContent() async {
    // Find the tab with matching name
    final tab = widget.tabs?.firstWhere(
      (t) => t.name?.toLowerCase() == widget.tabName.toLowerCase(),
      orElse: () => NewPipeChannelTab(),
    );

    // Check if tab exists and has a URL
    if (tab?.url == null) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final content = await NewPipeChannel.getChannelTab(
        tab!.url!,
        tabId: tab.id,
        contentFilters: tab.contentFilters,
      );
      if (mounted) {
        setState(() {
          _allContent = List.from(content.videos ?? []);
          _nextPage = content.nextPage;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_nextPage == null || _isLoadingMore) return;

    final tab = widget.tabs?.firstWhere(
      (t) => t.name?.toLowerCase() == widget.tabName.toLowerCase(),
      orElse: () => NewPipeChannelTab(),
    );

    if (tab?.url == null) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final moreContent = await NewPipeChannel.getChannelTabWithPagination(
        tab!.url!,
        nextPage: _nextPage!,
        tabId: tab.id,
        contentFilters: tab.contentFilters,
      );

      if (mounted) {
        setState(() {
          _allContent.addAll(moreContent.videos ?? []);
          _nextPage = moreContent.nextPage;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildErrorState(context);
    }

    if (_allContent.isEmpty && !_isLoadingMore) {
      return _buildEmptyState(context);
    }

    // Show different UI based on content type
    final tabName = widget.tabName.toLowerCase();

    if (tabName == 'shorts') {
      return _buildShortsGrid(context, _allContent);
    } else if (tabName == 'playlists') {
      return _buildPlaylistList(context, _allContent);
    } else if (tabName == 'channels') {
      return _buildChannelsList(context, _allContent);
    } else {
      // Default: show as video list (works for videos, livestreams, albums, etc.)
      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _allContent.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < _allContent.length) {
            final video = _allContent[index];
            return NewPipeChannelVideoCard(
              videoInfo: video,
              channelId: widget.channelId,
            );
          } else {
            // Show loading indicator at the end
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
        },
      );
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    final tabName = widget.tabName.toLowerCase();
    IconData icon;
    String message;

    switch (tabName) {
      case 'shorts':
        icon = Icons.video_library_outlined;
        message = widget.locals.noShorts;
        break;
      case 'playlists':
        icon = Icons.playlist_play;
        message = widget.locals.noPlaylists;
        break;
      case 'livestreams':
      case 'live':
        icon = Icons.live_tv_outlined;
        message = 'No livestreams';
        break;
      case 'channels':
        icon = Icons.people_outline;
        message = 'No channels';
        break;
      default:
        icon = Icons.video_library_outlined;
        message = 'No content available';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48,
            color: kGreyColor,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: kGreyColor, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: kGreyColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load ${widget.tabName}',
            style: TextStyle(color: kGreyColor, fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _loadTabContent,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildShortsGrid(BuildContext context, List<NewPipeRelatedStream> content) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 9 / 16,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: content.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < content.length) {
          final item = content[index];
          return GestureDetector(
            onTap: () => _onShortTap(context, content, index),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ThumbnailImage.small(url: item.thumbnailUrl ?? ''),
            ),
          );
        } else {
          // Loading indicator spans all columns
          return GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              SizedBox(),
              Center(child: CircularProgressIndicator()),
              SizedBox(),
            ],
          );
        }
      },
    );
  }

  void _onShortTap(BuildContext context, List<NewPipeRelatedStream> content, int index) {
    final shortItems = content.map((item) {
      final videoId = item.url?.split('=').last ?? '';
      return ShortItem(
        id: videoId,
        title: item.name,
        thumbnailUrl: item.thumbnailUrl,
        uploaderName: item.uploaderName,
        uploaderAvatar: item.uploaderAvatarUrl,
        uploaderId: item.uploaderUrl?.split('/').last,
        viewCount: item.viewCount,
        duration: item.duration,
        uploaderVerified: item.uploaderVerified,
      );
    }).toList();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ScreenShorts(
          shorts: shortItems,
          initialIndex: index,
        ),
      ),
    );
  }

  Widget _buildPlaylistList(BuildContext context, List<NewPipeRelatedStream> content) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: content.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < content.length) {
          final item = content[index];
          final playlistId = item.url?.split('=').last ?? '';

          return PlaylistWidget(
            playlistId: playlistId,
            title: item.name,
            thumbnail: item.thumbnailUrl,
            videoCount: item.streamCount ?? 0,
            // Use playlist-specific uploader fields
            uploaderName: item.playlistUploaderName ?? item.uploaderName,
            uploaderAvatar: item.uploaderAvatarUrl,
            onTap: () {
              // Use pushNamed to maintain navigation stack
              context.pushNamed('playlist', pathParameters: {
                'playlistId': playlistId,
              });
            },
          );
        } else {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }

  Widget _buildChannelsList(BuildContext context, List<NewPipeRelatedStream> content) {
    return BlocBuilder<SubscribeBloc, SubscribeState>(
      buildWhen: (previous, current) =>
          previous.subscribedChannels != current.subscribedChannels,
      builder: (context, subscribeState) {
        return ListView.builder(
          controller: _scrollController,
          itemCount: content.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < content.length) {
              final item = content[index];
              final channelId = item.url?.split('/').last ?? '';

              // Check if channel is subscribed
              final isSubscribed = subscribeState.subscribedChannels
                  .where((channel) => channel.id == channelId)
                  .isNotEmpty;

              return ChannelWidget(
                channelName: item.name,
                isVerified: item.isVerified,
                subscriberCount: item.subscriberCount,
                thumbnail: item.thumbnailUrl,
                isSubscribed: isSubscribed,
                channelId: channelId,
                locals: widget.locals,
              );
            } else {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
          },
        );
      },
    );
  }
}
