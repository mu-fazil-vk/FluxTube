import 'package:fluxtube/widgets/thumbnail_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/animations/animations.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/core/enums.dart';
import 'package:fluxtube/core/operations/math_operations.dart';
import 'package:fluxtube/domain/search/models/newpipe/newpipe_search_resp.dart';
import 'package:fluxtube/domain/subscribes/models/subscribe.dart';
import 'package:fluxtube/domain/watch/models/basic_info.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/presentation/home/widgets/home_hero_card.dart';
import 'package:fluxtube/presentation/search/widgets/newpipe/home_video_info_card_widget.dart';
import 'package:fluxtube/presentation/shorts/screen_shorts.dart';
import 'package:fluxtube/widgets/shimmers/shimmer_home_video_card.dart';
import 'package:go_router/go_router.dart';

/// Personalized home feed with mixed content (videos and shorts)
class PersonalizedFeedSection extends StatefulWidget {
  const PersonalizedFeedSection({
    super.key,
    required this.trendingState,
    required this.locals,
    required this.settingsState,
  });

  final TrendingState trendingState;
  final S locals;
  final SettingsState settingsState;

  @override
  State<PersonalizedFeedSection> createState() =>
      _PersonalizedFeedSectionState();
}

class _PersonalizedFeedSectionState extends State<PersonalizedFeedSection> {
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
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      // Load more when 80% scrolled (earlier trigger)
      if (!widget.trendingState.isLoadingMorePersonalizedFeed &&
          widget.trendingState.hasMorePersonalizedContent) {
        BlocProvider.of<TrendingBloc>(context).add(
          TrendingEvent.loadMorePersonalizedFeed(
            profileName: widget.settingsState.currentProfile,
            serviceType: widget.settingsState.ytService,
          ),
        );
      }
    }
  }

  void _openVideo(
      BuildContext context, String videoId, String channelId, dynamic video) {
    // Set video basic details for watch screen
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

    // Track video watch
    context.read<SavedBloc>().add(SavedEvent.trackVideoWatch(videoId: videoId));

    context.goNamed('watch', pathParameters: {
      'videoId': videoId,
      'channelId': channelId,
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show shimmer while loading
    if (widget.trendingState.fetchPersonalizedFeedStatus == ApiStatus.loading) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        itemBuilder: (context, index) => const ShimmerHomeVideoInfoCard(),
      );
    }

    final items =
        widget.trendingState.personalizedFeedResult.cast<NewPipeSearchItem>();

    // Only show empty state if loaded and actually empty
    if (items.isEmpty &&
        widget.trendingState.fetchPersonalizedFeedStatus == ApiStatus.loaded) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'No videos available',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    // Show shimmer if still in initial state
    if (items.isEmpty) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        itemBuilder: (context, index) => const ShimmerHomeVideoInfoCard(),
      );
    }

    // Separate shorts and videos for mixed layout
    final shorts = <NewPipeSearchItem>[];
    final videos = <NewPipeSearchItem>[];

    for (final item in items) {
      if (item.isShort == true) {
        shorts.add(item);
      } else {
        videos.add(item);
      }
    }

    // First video is rendered as the hero card, the rest as regular cards.
    final showHero = videos.isNotEmpty;

    return ListView.separated(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 10),
      separatorBuilder: (context, index) {
        // Insert shorts section every 5-7 videos
        if (shorts.isNotEmpty &&
            index > 0 &&
            index % 6 == 0 &&
            index / 6 <= (shorts.length / 5).ceil()) {
          final shortsStartIndex = ((index ~/ 6) - 1) * 5;
          final shortsEndIndex = (shortsStartIndex + 5).clamp(0, shorts.length);
          final shortsToShow = shorts.sublist(
            shortsStartIndex,
            shortsEndIndex,
          );

          if (shortsToShow.isNotEmpty) {
            return Column(
              children: [
                kHeightBox10,
                _ShortsSection(
                  shorts: shortsToShow,
                  locals: widget.locals,
                ),
                kHeightBox10,
              ],
            );
          }
        }
        return kHeightBox10;
      },
      // The hero *is* videos[0], so it replaces the first row rather than
      // adding one — otherwise the first video showed up twice.
      itemCount: videos.length +
          (widget.trendingState.isLoadingMorePersonalizedFeed ? 2 : 0),
      itemBuilder: (context, index) {
        // Hero card from the first feed video
        if (showHero && index == 0) {
          final heroVideo = videos.first;
          final heroVideoId = heroVideo.videoId ??
              heroVideo.url?.split('v=').last.split('&').first ??
              '';
          final heroChannelId = heroVideo.uploaderUrl?.split('/').last ?? '';
          return AnimatedListItem(
            index: 0,
            child: HomeHeroCard(
              thumbnailUrl: heroVideo.thumbnailUrl,
              title: heroVideo.name ?? widget.locals.noVideoTitle,
              channelName:
                  heroVideo.uploaderName ?? widget.locals.noUploaderName,
              views: heroVideo.viewCount,
              uploadedDate: heroVideo.uploadDate,
              isLive: heroVideo.isLive ?? false,
              durationLabel: (heroVideo.isLive ?? false)
                  ? null
                  : formatDuration(heroVideo.duration),
              onTap: () =>
                  _openVideo(context, heroVideoId, heroChannelId, heroVideo),
            ),
          );
        }

        final contentIndex = index;

        // Shimmer loading cards at the end
        if (contentIndex >= videos.length) {
          return const ShimmerHomeVideoInfoCard();
        }

        final video = videos[contentIndex];
        final videoId =
            video.videoId ?? video.url?.split('v=').last.split('&').first ?? '';
        final channelId = video.uploaderUrl?.split('/').last ?? '';

        // Skip if videoId or channelId is empty
        if (videoId.isEmpty || channelId.isEmpty) {
          return const SizedBox.shrink();
        }

        return BlocBuilder<SubscribeBloc, SubscribeState>(
          buildWhen: (p, c) =>
              !identical(p.subscribedChannels, c.subscribedChannels),
          builder: (context, subscribeState) {
            final isSubscribed = subscribeState.subscribedChannels
                .any((channel) => channel.id == channelId);

            return GestureDetector(
              key: ValueKey('personalized_$videoId'),
              onTap: () => _openVideo(context, videoId, channelId, video),
              child: NewPipeSearchVideoInfoCardWidget(
                channelId: channelId,
                cardInfo: video,
                isSubscribed: isSubscribed,
                subscribeRowVisible: true,
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
                              channelName: video.uploaderName ?? '',
                              avatarUrl: video.uploaderAvatarUrl,
                              isVerified: video.uploaderVerified,
                              profileName: widget.settingsState.currentProfile,
                            ),
                            profileName: widget.settingsState.currentProfile,
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
}

/// Horizontal shorts section
class _ShortsSection extends StatelessWidget {
  const _ShortsSection({
    required this.shorts,
    required this.locals,
  });

  final List<NewPipeSearchItem> shorts;
  final S locals;

  @override
  Widget build(BuildContext context) {
    if (shorts.isEmpty) return const SizedBox.shrink();

    // Convert NewPipeSearchItem to ShortItem
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
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: AppRadius.borderSm,
                ),
                child: Icon(
                  CupertinoIcons.play_rectangle_fill,
                  color: theme.colorScheme.onPrimaryContainer,
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
            itemCount: shortItems.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final short = shortItems[index];
              return _ShortCard(
                short: short,
                onTap: () => _openShorts(context, shortItems, index),
              );
            },
          ),
        ),
        AppSpacing.height12,
      ],
    );
  }

  void _openShorts(
      BuildContext context, List<ShortItem> shortItems, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ScreenShorts(
          shorts: shortItems,
          initialIndex: index,
        ),
      ),
    );
  }
}

/// Individual short card matching search result design
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: AppRadius.borderMd,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.scrim.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: AppRadius.borderMd,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Thumbnail
              if (short.thumbnailUrl != null)
                ThumbnailImage.small(
                  url: short.thumbnailUrl!,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => ColoredBox(
                    color: theme.colorScheme.surfaceContainerHigh,
                    child: Icon(
                      Icons.video_library,
                      size: 40,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                ColoredBox(
                  color: theme.colorScheme.surfaceContainerHigh,
                  child: Icon(
                    Icons.video_library,
                    size: 40,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),

              // Gradient overlay for text readability
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        theme.colorScheme.scrim.withValues(alpha: 0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // View count
              if (short.viewCount != null)
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Text(
                    _formatViews(short.viewCount!),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              // Shorts icon indicator
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.scrim.withValues(alpha: 0.6),
                    borderRadius: AppRadius.borderXs,
                  ),
                  child: const Icon(
                    CupertinoIcons.play_rectangle_fill,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatViews(int views) {
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M views';
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K views';
    }
    return '$views views';
  }
}
