
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/core/enums.dart';
import 'package:fluxtube/domain/watch/models/basic_info.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/widgets/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ScreenPlaylist extends StatelessWidget {
  const ScreenPlaylist({super.key, required this.playlistId});

  final String playlistId;

  @override
  Widget build(BuildContext context) {
    final settingsBloc = BlocProvider.of<SettingsBloc>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<PlaylistBloc>(context).add(PlaylistEvent.getPlaylistData(
        playlistId: playlistId,
        serviceType: settingsBloc.state.ytService,
      ));
    });

    final locals = S.of(context);

    return BlocBuilder<PlaylistBloc, PlaylistState>(
      builder: (context, state) {
        if (state.fetchStatus == ApiStatus.loading ||
            state.fetchStatus == ApiStatus.initial) {
          return Scaffold(
            appBar: AppBar(title: Text(locals.playlist)),
            body: Center(child: cIndicator(context)),
          );
        }

        if (state.fetchStatus == ApiStatus.error) {
          return Scaffold(
            appBar: AppBar(title: Text(locals.playlist)),
            body: Center(
              child: ErrorRetryWidget(
                lottie: 'assets/black-cat.zip',
                onTap: () => BlocProvider.of<PlaylistBloc>(context).add(
                  PlaylistEvent.getPlaylistData(
                    playlistId: playlistId,
                    serviceType: settingsBloc.state.ytService,
                  ),
                ),
              ),
            ),
          );
        }

        // Invidious playlist
        if (state.invidiousPlaylistResp != null) {
          return _buildInvidiousPlaylist(context, state, locals, settingsBloc);
        }

        // Piped playlist
        if (state.pipedPlaylistResp != null) {
          return _buildPipedPlaylist(context, state, locals, settingsBloc);
        }

        return Scaffold(
          appBar: AppBar(title: Text(locals.playlist)),
          body: const Center(child: Text('No playlist data')),
        );
      },
    );
  }

  Widget _buildPipedPlaylist(
    BuildContext context,
    PlaylistState state,
    S locals,
    SettingsBloc settingsBloc,
  ) {
    final playlist = state.pipedPlaylistResp!;
    final videos = playlist.relatedStreams ?? [];
    final scrollController = ScrollController();

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent &&
          state.moreFetchStatus != ApiStatus.loading &&
          !state.isMoreFetchCompleted) {
        BlocProvider.of<PlaylistBloc>(context).add(
          PlaylistEvent.getMorePlaylistVideos(
            playlistId: playlistId,
            nextPage: playlist.nextpage,
          ),
        );
      }
    });

    return Scaffold(
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          _buildSliverAppBar(
            context,
            title: playlist.name ?? 'Playlist',
            thumbnailUrl: playlist.thumbnailUrl,
            bannerUrl: playlist.bannerUrl,
            videoCount: playlist.videos,
            uploaderName: playlist.uploader,
            uploaderAvatar: playlist.uploaderAvatar,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < videos.length) {
                  final video = videos[index];
                  final videoId = video.url?.split('=').last ?? '';
                  final channelId = video.uploaderUrl?.split('/').last ?? '';

                  return _buildVideoItem(
                    context: context,
                    index: index,
                    videoId: videoId,
                    channelId: channelId,
                    title: video.title,
                    thumbnail: video.thumbnail,
                    uploaderName: video.uploaderName,
                    uploaderAvatar: video.uploaderAvatar,
                    duration: video.duration,
                    views: video.views,
                    uploadedDate: video.uploadedDate,
                    uploaderVerified: video.uploaderVerified,
                  );
                } else if (!state.isMoreFetchCompleted) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(child: cIndicator(context)),
                  );
                }
                return null;
              },
              childCount: videos.length + (state.isMoreFetchCompleted ? 0 : 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvidiousPlaylist(
    BuildContext context,
    PlaylistState state,
    S locals,
    SettingsBloc settingsBloc,
  ) {
    final playlist = state.invidiousPlaylistResp!;
    final videos = playlist.videos ?? [];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(
            context,
            title: playlist.title ?? 'Playlist',
            thumbnailUrl: playlist.playlistThumbnail,
            bannerUrl: null,
            videoCount: playlist.videoCount,
            uploaderName: playlist.author,
            uploaderAvatar: null,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < videos.length) {
                  final video = videos[index];
                  final videoId = video.videoId ?? '';
                  final channelId = playlist.authorId ?? '';
                  String? thumbnail;
                  if (video.videoThumbnails != null &&
                      video.videoThumbnails!.isNotEmpty) {
                    thumbnail = video.videoThumbnails!.first.url;
                    if (thumbnail != null && !thumbnail.startsWith('http')) {
                      thumbnail = 'https:$thumbnail';
                    }
                  }

                  return _buildVideoItem(
                    context: context,
                    index: index,
                    videoId: videoId,
                    channelId: channelId,
                    title: video.title,
                    thumbnail: thumbnail,
                    uploaderName: playlist.author,
                    uploaderAvatar: null,
                    duration: video.lengthSeconds,
                    views: null,
                    uploadedDate: null,
                    uploaderVerified: null,
                  );
                }
                return null;
              },
              childCount: videos.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context, {
    required String title,
    required String? thumbnailUrl,
    required String? bannerUrl,
    required int? videoCount,
    required String? uploaderName,
    required String? uploaderAvatar,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            if (thumbnailUrl != null || bannerUrl != null)
              ThumbnailImage(url: bannerUrl ?? thumbnailUrl!),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    isDarkMode
                        ? Colors.black.withValues(alpha: 0.8)
                        : Colors.white.withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),
            // Playlist info
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Playlist badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: kRedColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.playlist_play,
                          color: kWhiteColor,
                          size: 16,
                        ),
                        kWidthBox5,
                        Text(
                          '${_formatCount(videoCount)} videos',
                          style: const TextStyle(
                            color: kWhiteColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  kHeightBox10,
                  // Title
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  kHeightBox5,
                  // Uploader
                  if (uploaderName != null)
                    Row(
                      children: [
                        if (uploaderAvatar != null) ...[
                          CircleAvatar(
                            radius: 12,
                            backgroundImage:
                                cachedAvatarProvider(uploaderAvatar, logicalDiameter: 24),
                            backgroundColor: kGreyColor,
                          ),
                          kWidthBox10,
                        ],
                        Expanded(
                          child: Text(
                            uploaderName,
                            style: TextStyle(
                              color: kGreyColor,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoItem({
    required BuildContext context,
    required int index,
    required String videoId,
    required String channelId,
    required String? title,
    required String? thumbnail,
    required String? uploaderName,
    required String? uploaderAvatar,
    required int? duration,
    required int? views,
    required String? uploadedDate,
    required bool? uploaderVerified,
  }) {
    return InkWell(
      onTap: () {
        BlocProvider.of<WatchBloc>(context).add(
          WatchEvent.setSelectedVideoBasicDetails(
            details: VideoBasicInfo(
              id: videoId,
              title: title,
              thumbnailUrl: thumbnail,
              channelName: uploaderName,
              channelThumbnailUrl: uploaderAvatar,
              channelId: channelId,
              uploaderVerified: uploaderVerified,
            ),
          ),
        );
        context.goNamed('watch', pathParameters: {
          'videoId': videoId,
          'channelId': channelId,
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Index number
            SizedBox(
              width: 30,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: kGreyColor,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            kWidthBox10,
            // Thumbnail
            Stack(
              children: [
                Container(
                  width: 120,
                  height: 68,
                  decoration: BoxDecoration(
                    color: kGreyColor,
                    borderRadius: BorderRadius.circular(8),
                    image: thumbnail != null
                        ? DecorationImage(
                            image: cachedThumbnailProvider(thumbnail),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                ),
                if (duration != null && duration > 0)
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: kBlackColor.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _formatDuration(duration),
                        style: const TextStyle(
                          color: kWhiteColor,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            kWidthBox10,
            // Video info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title ?? 'Unknown',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  kHeightBox5,
                  Row(
                    children: [
                      if (uploaderName != null) ...[
                        Flexible(
                          child: Text(
                            uploaderName,
                            style: TextStyle(
                              color: kGreyColor,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (uploaderVerified == true)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Icon(
                              Icons.verified,
                              size: 12,
                              color: kGreyColor,
                            ),
                          ),
                      ],
                    ],
                  ),
                  if (views != null || uploadedDate != null)
                    Text(
                      [
                        if (views != null) '${_formatCount(views)} views',
                        if (uploadedDate != null) uploadedDate,
                      ].join(' • '),
                      style: TextStyle(
                        color: kGreyColor,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _formatCount(int? count) {
    if (count == null) return '0';
    if (count >= 1000) {
      return NumberFormat.compact().format(count);
    }
    return count.toString();
  }
}
