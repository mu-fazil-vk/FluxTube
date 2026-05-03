
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/enums.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:fluxtube/domain/channel/models/piped/related_stream.dart';
import 'package:fluxtube/domain/channel/models/piped/tab.dart' as piped;
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/presentation/shorts/screen_shorts.dart';
import 'package:fluxtube/widgets/widgets.dart';
import 'package:go_router/go_router.dart';

class ChannelTabContent extends StatefulWidget {
  const ChannelTabContent({
    super.key,
    required this.tabs,
    required this.tabName,
    required this.locals,
  });

  final List<piped.Tab>? tabs;
  final String tabName;
  final S locals;

  @override
  State<ChannelTabContent> createState() => _ChannelTabContentState();
}

class _ChannelTabContentState extends State<ChannelTabContent>
    with AutomaticKeepAliveClientMixin {
  bool _hasLoaded = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadTabContent();
  }

  void _loadTabContent() {
    if (_hasLoaded) return;

    final tab = widget.tabs?.firstWhere(
      (t) => t.name?.toLowerCase() == widget.tabName,
      orElse: () => piped.Tab(),
    );

    if (tab?.data != null) {
      BlocProvider.of<ChannelBloc>(context).add(
        ChannelEvent.getChannelTabContent(
          tabData: tab!.data!,
          tabName: widget.tabName,
        ),
      );
      _hasLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final tab = widget.tabs?.firstWhere(
      (t) => t.name?.toLowerCase() == widget.tabName,
      orElse: () => piped.Tab(),
    );

    if (tab?.data == null) {
      return Center(
        child: Text(
          widget.tabName == 'shorts'
              ? widget.locals.noShorts
              : widget.locals.noPlaylists,
          style: TextStyle(color: kGreyColor),
        ),
      );
    }

    return BlocBuilder<ChannelBloc, ChannelState>(
      buildWhen: (previous, current) {
        if (widget.tabName == 'shorts') {
          return previous.shortsTabFetchStatus != current.shortsTabFetchStatus ||
              previous.shortsTabContent != current.shortsTabContent;
        } else {
          return previous.playlistsTabFetchStatus !=
                  current.playlistsTabFetchStatus ||
              previous.playlistsTabContent != current.playlistsTabContent;
        }
      },
      builder: (context, state) {
        final isShorts = widget.tabName == 'shorts';
        final fetchStatus = isShorts
            ? state.shortsTabFetchStatus
            : state.playlistsTabFetchStatus;
        final tabContent =
            isShorts ? state.shortsTabContent : state.playlistsTabContent;

        if (fetchStatus == ApiStatus.loading) {
          return Center(child: cIndicator(context));
        }

        if (fetchStatus == ApiStatus.error ||
            tabContent == null ||
            tabContent.content == null ||
            tabContent.content!.isEmpty) {
          return Center(
            child: Text(
              isShorts ? widget.locals.noShorts : widget.locals.noPlaylists,
              style: TextStyle(color: kGreyColor),
            ),
          );
        }

        final content = tabContent.content!;

        if (isShorts) {
          return _buildShortsGrid(context, content);
        } else {
          return _buildPlaylistList(context, content);
        }
      },
    );
  }

  Widget _buildShortsGrid(BuildContext context, List<RelatedStream> content) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 9 / 16,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: content.length,
      itemBuilder: (context, index) {
        final item = content[index];

        // Try to get thumbnail from various sources
        String thumbnailImage = item.thumbnail ?? item.thumbnailUrl ?? '';

        // If thumbnail is empty, try to generate from video URL
        if (thumbnailImage.isEmpty && item.url != null) {
          // Extract video ID from URL like /watch?v=VIDEO_ID or shorts/VIDEO_ID
          String? videoId;
          if (item.url!.contains('watch?v=')) {
            videoId = item.url!.split('watch?v=').last.split('&').first;
          } else if (item.url!.contains('/shorts/')) {
            videoId = item.url!.split('/shorts/').last.split('?').first;
          }
          if (videoId != null && videoId.isNotEmpty) {
            thumbnailImage = 'https://i.ytimg.com/vi/$videoId/hqdefault.jpg';
          }
        }

        return GestureDetector(
          onTap: () => _onShortTap(context, content, index),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ThumbnailImage.small(url: thumbnailImage),
          ),
        );
      },
    );
  }

  void _onShortTap(BuildContext context, List<RelatedStream> content, int index) {
    // Convert RelatedStream list to ShortItem list
    final shortItems = content.map((item) {
      // Extract video ID from URL
      String videoId = '';
      if (item.url != null) {
        if (item.url!.contains('watch?v=')) {
          videoId = item.url!.split('watch?v=').last.split('&').first;
        } else if (item.url!.contains('/shorts/')) {
          videoId = item.url!.split('/shorts/').last.split('?').first;
        } else if (item.url!.contains('=')) {
          videoId = item.url!.split('=').last;
        }
      }

      // Get thumbnail
      String? thumbnailUrl = item.thumbnail ?? item.thumbnailUrl;
      if ((thumbnailUrl == null || thumbnailUrl.isEmpty) && videoId.isNotEmpty) {
        thumbnailUrl = 'https://i.ytimg.com/vi/$videoId/hqdefault.jpg';
      }

      return ShortItem(
        id: videoId,
        title: item.title ?? item.name,
        thumbnailUrl: thumbnailUrl,
        uploaderName: item.uploaderName,
        uploaderAvatar: item.uploaderAvatar,
        uploaderId: item.uploaderUrl?.split('/').last,
        viewCount: item.views,
        duration: item.duration,
        uploaderVerified: item.uploaderVerified,
      );
    }).toList();

    // Navigate to shorts player
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ScreenShorts(
          shorts: shortItems,
          initialIndex: index,
        ),
      ),
    );
  }

  Widget _buildPlaylistList(BuildContext context, List<RelatedStream> content) {
    return ListView.builder(
      itemCount: content.length,
      itemBuilder: (context, index) {
        final item = content[index];
        final playlistId = item.url?.split('=').last ?? '';

        return PlaylistWidget(
          playlistId: playlistId,
          title: item.name ?? item.title,
          thumbnail: item.thumbnail ?? item.thumbnailUrl,
          videoCount: item.videos ?? item.views ?? 0,
          uploaderName: item.uploaderName,
          uploaderAvatar: item.uploaderAvatar,
          onTap: () {
            context.goNamed('playlist', pathParameters: {
              'playlistId': playlistId,
            });
          },
        );
      },
    );
  }
}
