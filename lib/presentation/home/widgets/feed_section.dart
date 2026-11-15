import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/animations/animations.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/domain/subscribes/models/subscribe.dart';
import 'package:fluxtube/core/operations/math_operations.dart';
import 'package:fluxtube/domain/watch/models/basic_info.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/presentation/home/widgets/home_hero_card.dart';
import 'package:fluxtube/widgets/home_video_info_card_widget.dart';
import 'package:go_router/go_router.dart';

class FeedVideoSection extends StatefulWidget {
  const FeedVideoSection({
    super.key,
    required this.locals,
    required this.trendingState,
    required this.subscribeState,
  });

  final S locals;
  final TrendingState trendingState;
  final SubscribeState subscribeState;

  @override
  State<FeedVideoSection> createState() => _FeedVideoSectionState();
}

class _FeedVideoSectionState extends State<FeedVideoSection> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<TrendingBloc>().add(const TrendingEvent.loadMoreFeed());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Trigger when user is 200 pixels from bottom
    return currentScroll >= (maxScroll - 200);
  }

  @override
  Widget build(BuildContext context) {
    final displayCount = widget.trendingState.feedDisplayCount;
    final totalCount = widget.trendingState.feedResult.length;
    // First item is rendered as the hero card, the rest as regular cards.
    final showHero = totalCount > 0;
    final heroOffset = showHero ? 1 : 0;
    final listCount =
        (displayCount - heroOffset).clamp(0, totalCount - heroOffset);
    final hasMore = displayCount < totalCount;
    final isLoading = widget.trendingState.isLoadingMoreFeed;

    return ListView.separated(
      controller: _scrollController,
      scrollCacheExtent: const ScrollCacheExtent.pixels(500),
      separatorBuilder: (context, index) => kHeightBox10,
      itemBuilder: (context, index) {
        // Hero card from the first feed item
        if (showHero && index == 0) {
          final hero = widget.trendingState.feedResult.first;
          final String videoId = hero.url!.split('=').last;
          final String channelId = hero.uploaderUrl!.split("/").last;
          final bool isLive = hero.duration == -1;
          return AnimatedListItem(
            index: 0,
            child: HomeHeroCard(
              thumbnailUrl: hero.thumbnail,
              title: hero.title ?? widget.locals.noVideoTitle,
              channelName: hero.uploaderName ?? widget.locals.noUploaderName,
              views: hero.views,
              uploadedDate: hero.uploadedDate,
              isLive: isLive,
              durationLabel: isLive ? null : formatDuration(hero.duration),
              onTap: () => _openVideo(context, videoId, channelId, hero),
            ),
          );
        }

        final contentIndex = showHero ? index - 1 : index;

        // Show loading indicator at the end
        if (contentIndex >= listCount) {
          return _buildLoadingIndicator(hasMore, isLoading);
        }

        final feed = widget.trendingState.feedResult[contentIndex + heroOffset];
        final String videoId = feed.url!.split('=').last;

        final String channelId = feed.uploaderUrl!.split("/").last;
        final bool isSubscribed = widget.subscribeState.subscribedChannels
            .any((channel) => channel.id == channelId);
        return HomeVideoInfoCardWidget(
          key: ValueKey('feed_$videoId'),
          channelId: channelId,
          cardInfo: feed,
          isSubscribed: isSubscribed,
          index: contentIndex,
          onTap: () => _openVideo(context, videoId, channelId, feed),
          onSubscribeTap: () => onSubscribeTapped(
              context, isSubscribed, channelId, feed, widget.locals),
        );
      },
      itemCount:
          heroOffset + listCount + (hasMore ? 1 : 0),
    );
  }

  void _openVideo(
      BuildContext context, String videoId, String channelId, dynamic feed) {
    BlocProvider.of<WatchBloc>(context).add(WatchEvent.setSelectedVideoBasicDetails(
        details: VideoBasicInfo(
            id: videoId,
            title: feed.title,
            thumbnailUrl: feed.thumbnail,
            channelName: feed.uploaderName,
            channelThumbnailUrl: feed.uploaderAvatar,
            channelId: channelId,
            uploaderVerified: feed.uploaderVerified)));
    context.goNamed('watch', pathParameters: {
      'videoId': videoId,
      'channelId': channelId,
    });
  }

  Widget _buildLoadingIndicator(bool hasMore, bool isLoading) {
    if (!hasMore) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}

void onSubscribeTapped(BuildContext context, bool isSubscribed, String channelId, dynamic channelDetails, S locals) {
  if (isSubscribed) {
    BlocProvider.of<SubscribeBloc>(context)
        .add(SubscribeEvent.deleteSubscribeInfo(id: channelId));
  } else {
    BlocProvider.of<SubscribeBloc>(context).add(SubscribeEvent.addSubscribe(
        channelInfo: Subscribe(
            id: channelId,
            channelName: channelDetails.uploaderName ?? locals.noUploaderName,
            isVerified: channelDetails.uploaderVerified ?? false)));
  }
}
