import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/enums.dart';
import 'package:fluxtube/domain/search/models/invidious/invidious_search_resp.dart';
import 'package:fluxtube/domain/subscribes/models/subscribe.dart';
import 'package:fluxtube/domain/watch/models/basic_info.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/presentation/search/widgets/widgets.dart';
import 'package:fluxtube/widgets/widgets.dart';
import 'package:go_router/go_router.dart';

class InvidiousSearcheResultSection extends StatelessWidget {
  InvidiousSearcheResultSection(
      {super.key,
      required this.locals,
      required this.state,
      required this.searchQuery});

  final S locals;
  final SearchState state;
  final String searchQuery;

  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !(state.fetchMoreSearchResultStatus == ApiStatus.loading) &&
          !state.isMoreFetchCompleted) {
        BlocProvider.of<SearchBloc>(context).add(
            SearchEvent.getMoreSearchResult(
                query: searchQuery,
                filter: "all",
                nextPage: null,
                serviceType: YouTubeServices.invidious.name));
      }
    });
    return BlocBuilder<SubscribeBloc, SubscribeState>(
      buildWhen: (previous, current) =>
          previous.subscribedChannels != current.subscribedChannels,
      builder: (context, subscribeState) {
        return ListView.builder(
          controller: _scrollController,
          itemBuilder: (context, index) {
            if (index < state.invidiousSearchResult.length) {
              final InvidiousSearchResp _result =
                  state.invidiousSearchResult[index];

              if (_result.type == "channel") {
                final String _channelId = _result.authorId!;
                final bool _isSubscribed = subscribeState.subscribedChannels
                    .where((channel) => channel.id == _channelId)
                    .isNotEmpty;
                // channel integration
                return Padding(
                  padding: const EdgeInsets.only(
                      top: 5, left: 20, right: 20, bottom: 10),
                  child: ChannelWidget(
                      channelName: _result.author,
                      isVerified: _result.authorVerified,
                      subscriberCount: _result.subCount,
                      thumbnail: 'https:${_result.authorThumbnails?.last.url}',
                      isSubscribed: _isSubscribed,
                      channelId: _channelId,
                      locals: locals),
                );
              } else if (_result.type == "video") {
                final String _videoId = _result.videoId!;
                final String _channelId = _result.authorId!;
                final bool _isSubscribed = subscribeState.subscribedChannels
                    .where((channel) => channel.id == _channelId)
                    .isNotEmpty;
                return GestureDetector(
                    onTap: () {
                      BlocProvider.of<WatchBloc>(context)
                          .add(WatchEvent.setSelectedVideoBasicDetails(
                              details: VideoBasicInfo(
                        title: _result.title,
                        thumbnailUrl: _result.videoThumbnails!.first.url,
                        channelName: _result.author,
                        channelThumbnailUrl: null,
                        channelId: _channelId,
                        uploaderVerified: _result.authorVerified,
                      )));
                      context.go('/watch/$_videoId/$_channelId');
                    },
                    child: InvidiousSearchVideoInfoCardWidget(
                      channelId: _channelId,
                      cardInfo: _result,
                      isSubscribed: _isSubscribed,
                      onSubscribeTap: () {
                        if (_isSubscribed) {
                          BlocProvider.of<SubscribeBloc>(context).add(
                              SubscribeEvent.deleteSubscribeInfo(
                                  id: _channelId));
                        } else {
                          BlocProvider.of<SubscribeBloc>(context).add(
                              SubscribeEvent.addSubscribe(
                                  channelInfo: Subscribe(
                                      id: _channelId,
                                      channelName: _result.author ??
                                          locals.noUploaderName,
                                      isVerified:
                                          _result.authorVerified ?? false)));
                        }
                      },
                    ));
              } else {
                return const SizedBox();
              }
            } else {
              if (state.isMoreInvidiousFetchCompleted) {
                return const SizedBox();
              } else {
                return cIndicator(context);
              }
            }
          },
          itemCount: (state.invidiousSearchResult.length) + 1,
        );
      },
    );
  }
}
