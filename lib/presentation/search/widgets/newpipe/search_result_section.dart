import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/core/enums.dart';
import 'package:fluxtube/domain/subscribes/models/subscribe.dart';
import 'package:fluxtube/domain/watch/models/basic_info.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/presentation/shorts/screen_shorts.dart';
import 'package:fluxtube/widgets/widgets.dart';
import 'package:go_router/go_router.dart';

import 'home_video_info_card_widget.dart';

class NewPipeSearchResultSection extends StatefulWidget {
  const NewPipeSearchResultSection({
    super.key,
    required this.locals,
    required this.state,
    required this.searchQuery,
    this.filter = "all",
  });

  final S locals;
  final SearchState state;
  final String searchQuery;
  final String filter;

  @override
  State<NewPipeSearchResultSection> createState() =>
      _NewPipeSearchResultSectionState();
}

class _NewPipeSearchResultSectionState
    extends State<NewPipeSearchResultSection> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
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
        !(widget.state.fetchMoreNewPipeSearchResultStatus ==
            ApiStatus.loading) &&
        !widget.state.isMoreNewPipeFetchCompleted) {
      BlocProvider.of<SearchBloc>(context).add(SearchEvent.getMoreSearchResult(
        query: widget.searchQuery,
        filter: widget.filter,
        nextPage: widget.state.newPipeSearchResult?.nextPage,
        serviceType: YouTubeServices.newpipe.name,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscribeBloc, SubscribeState>(
      buildWhen: (previous, current) =>
          previous.subscribedChannels != current.subscribedChannels,
      builder: (context, subscribeState) {
        final items = widget.state.newPipeSearchResult?.items ?? [];

        // Separate shorts from regular items
        final shorts = items
            .where((item) => item.type == "STREAM" && item.isShort == true)
            .toList();
        final regularItems = items
            .where((item) => !(item.type == "STREAM" && item.isShort == true))
            .toList();

        // Convert shorts to ShortItem list
        final shortItems = shorts.map((s) {
          final videoId =
              s.videoId ?? s.url?.split('v=').last.split('&').first ?? '';
          return ShortItem(
            id: videoId,
            title: s.name,
            thumbnailUrl: s.thumbnailUrl,
            uploaderName: s.uploaderName,
            uploaderAvatar: s.uploaderAvatarUrl,
            uploaderId: s.uploaderUrl?.split('/').last,
            viewCount: s.viewCount,
            duration: s.duration,
            uploaderVerified: s.uploaderVerified,
          );
        }).toList();

        return CustomScrollView(
          controller: _scrollController,
          scrollCacheExtent: const ScrollCacheExtent.pixels(500),
          slivers: [
            // Shorts section (horizontal scrollable)
            if (shortItems.isNotEmpty)
              SliverToBoxAdapter(
                child: _ShortsSection(
                  shorts: shortItems,
                  locals: widget.locals,
                ),
              ),

            // Regular items list
            SliverList.separated(
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                  if (index < regularItems.length) {
                    final result = regularItems[index];

                    if (result.type == "CHANNEL") {
                      final channelId =
                          result.channelId ?? result.url?.split("/").last ?? '';
                      final isSubscribed = subscribeState.subscribedChannels
                          .any((channel) => channel.id == channelId);
                      return ChannelWidget(
                        key: ValueKey('channel_$channelId'),
                        channelName: result.name,
                        isVerified: result.isVerified,
                        subscriberCount: result.subscriberCount,
                        thumbnail: result.thumbnailUrl,
                        isSubscribed: isSubscribed,
                        channelId: channelId,
                        locals: widget.locals,
                      );
                    } else if (result.type == "PLAYLIST") {
                      final playlistId = result.url?.split('=').last ?? '';
                      return PlaylistWidget(
                        key: ValueKey('playlist_$playlistId'),
                        playlistId: playlistId,
                        title: result.name,
                        thumbnail: result.thumbnailUrl,
                        videoCount: result.streamCount,
                        uploaderName: result.uploaderName,
                        uploaderAvatar: result.uploaderAvatarUrl,
                        onTap: () {
                          context.goNamed('playlist', pathParameters: {
                            'playlistId': playlistId,
                          });
                        },
                      );
                    } else if (result.type == "STREAM") {
                      final videoId = result.videoId ??
                          result.url?.split('v=').last.split('&').first ??
                          '';
                      final channelId =
                          result.uploaderUrl?.split("/").last ?? '';

                      // Skip if videoId or channelId is empty
                      if (videoId.isEmpty || channelId.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      final isSubscribed = subscribeState.subscribedChannels
                          .any((channel) => channel.id == channelId);
                      return GestureDetector(
                        key: ValueKey('video_$videoId'),
                        onTap: () {
                          BlocProvider.of<WatchBloc>(context).add(
                            WatchEvent.setSelectedVideoBasicDetails(
                              details: VideoBasicInfo(
                                id: videoId,
                                title: result.name,
                                thumbnailUrl: result.thumbnailUrl,
                                channelName: result.uploaderName,
                                channelThumbnailUrl: result.uploaderAvatarUrl,
                                channelId: channelId,
                                uploaderVerified: result.uploaderVerified,
                              ),
                            ),
                          );
                          context.goNamed('watch', pathParameters: {
                            'videoId': videoId,
                            'channelId': channelId,
                          });
                        },
                        child: NewPipeSearchVideoInfoCardWidget(
                          channelId: channelId,
                          cardInfo: result,
                          isSubscribed: isSubscribed,
                          onSubscribeTap: () {
                            if (isSubscribed) {
                              BlocProvider.of<SubscribeBloc>(context).add(
                                  SubscribeEvent.deleteSubscribeInfo(
                                      id: channelId));
                            } else {
                              BlocProvider.of<SubscribeBloc>(context).add(
                                SubscribeEvent.addSubscribe(
                                  channelInfo: Subscribe(
                                    id: channelId,
                                    channelName: result.uploaderName ??
                                        widget.locals.noUploaderName,
                                    isVerified:
                                        result.uploaderVerified ?? false,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    } else {
                      return const SizedBox();
                    }
                  } else {
                    // Only show loading indicator when actually loading more
                    return cIndicator(context);
                  }
                },
              // Only add extra item when loading more results
              itemCount: regularItems.length +
                  (widget.state.fetchMoreNewPipeSearchResultStatus == ApiStatus.loading ? 1 : 0),
            ),
          ],
        );
      },
    );
  }
}

/// Horizontal shorts section for search results
class _ShortsSection extends StatelessWidget {
  const _ShortsSection({
    required this.shorts,
    required this.locals,
  });

  final List<ShortItem> shorts;
  final S locals;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  CupertinoIcons.play_rectangle_fill,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                locals.shorts,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Horizontal shorts list
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: shorts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final short = shorts[index];
              return _ShortCard(
                short: short,
                onTap: () => _openShorts(context, index),
              );
            },
          ),
        ),
        AppSpacing.height12,
      ],
    );
  }

  void _openShorts(BuildContext context, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ScreenShorts(
          shorts: shorts,
          initialIndex: index,
        ),
      ),
    );
  }
}

/// Individual short card for search results
class _ShortCard extends StatelessWidget {
  const _ShortCard({
    required this.short,
    required this.onTap,
  });

  final ShortItem short;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Thumbnail
              if (short.thumbnailUrl != null)
                ThumbnailImage.small(
                  url: short.thumbnailUrl!,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    color: isDark
                        ? AppColors.surfaceVariantDark
                        : AppColors.surfaceVariant,
                  ),
                )
              else
                Container(
                  color: isDark
                      ? AppColors.surfaceVariantDark
                      : AppColors.surfaceVariant,
                ),

              // Gradient overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        kBlackColor.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                ),
              ),

              // Shorts badge
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.play_rectangle_fill,
                        color: kWhiteColor,
                        size: 10,
                      ),
                      const SizedBox(width: 2),
                      const Text(
                        'SHORT',
                        style: TextStyle(
                          color: kWhiteColor,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Title at bottom
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (short.title != null)
                      Text(
                        short.title!,
                        style: const TextStyle(
                          color: kWhiteColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (short.uploaderName != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        short.uploaderName!,
                        style: TextStyle(
                          color: kWhiteColor.withValues(alpha: 0.7),
                          fontSize: 9,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
