import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/search/search_bloc.dart';
import 'package:fluxtube/application/subscribe/subscribe_bloc.dart';
import 'package:fluxtube/domain/search/models/item.dart';
import 'package:fluxtube/domain/subscribes/models/subscribe.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/widgets/home_video_info_card_widget.dart';
import 'package:fluxtube/widgets/indicator.dart';
import 'package:go_router/go_router.dart';

class SearcheResultSection extends StatelessWidget {
  SearcheResultSection(
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
          !state.isMoreFetchLoading &&
          !state.isMoreFetchCompleted) {
        BlocProvider.of<SearchBloc>(context).add(
            SearchEvent.getMoreSearchResult(
                query: searchQuery,
                filter: "videos",
                nextPage: state.result?.nextpage));
      }
    });
    return BlocBuilder<SubscribeBloc, SubscribeState>(
      builder: (context, subscribeState) {
        return ListView.builder(
          controller: _scrollController,
          itemBuilder: (context, index) {
            if (index < state.result!.items.length) {
              final Item _result = state.result!.items[index];
              final String videoId = _result.url!.split('=').last;
              final String channelId = _result.uploaderUrl!.split("/").last;
              final bool isSubscribed = subscribeState.subscribedChannels
                  .where((channel) => channel.id == channelId)
                  .isNotEmpty;
              return GestureDetector(
                  onTap: () => context.go('/watch/$videoId/$channelId'),
                  child: HomeVideoInfoCardWidget(
                    cardInfo: _result,
                    isSubscribed: isSubscribed,
                    onSubscribeTap: () {
                      if (isSubscribed) {
                        BlocProvider.of<SubscribeBloc>(context).add(
                            SubscribeEvent.deleteSubscribeInfo(id: channelId));
                      } else {
                        BlocProvider.of<SubscribeBloc>(context).add(
                            SubscribeEvent.addSubscribe(
                                channelInfo: Subscribe(
                                    id: channelId,
                                    channelName: _result.uploaderName ??
                                        locals.noUploaderName,
                                    isVerified:
                                        _result.uploaderVerified ?? false)));
                      }
                    },
                  ));
            } else {
              if (state.isMoreFetchCompleted) {
                return const SizedBox();
              } else {
                return cIndicator(context);
              }
            }
          },
          itemCount: (state.result?.items.length ?? 0) + 1,
        );
      },
    );
  }
}
