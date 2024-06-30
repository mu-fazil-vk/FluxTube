import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/subscribe/subscribe_bloc.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/domain/search/models/item.dart';
import 'package:fluxtube/domain/subscribes/models/subscribe.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/widgets/error_widget.dart';
import 'package:go_router/go_router.dart';

import '../../application/search/search_bloc.dart';
import '../../widgets/home_video_info_card_widget.dart';

class ScreenSearch extends StatelessWidget {
  ScreenSearch({super.key});

  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locals = S.of(context);
    return Scaffold(
      appBar: AppBar(
        foregroundColor: kBlackColor,
        title: Padding(
          padding: const EdgeInsets.only(right: 10, bottom: 5),
          child: CupertinoSearchTextField(
            controller: _textEditingController,
            style: theme.textTheme.bodyMedium!.copyWith(fontSize: 16),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                CupertinoIcons.search,
                color: theme.iconTheme.color,
              ),
            ),
            suffixIcon: Icon(
              CupertinoIcons.clear_circled_solid,
              color: theme.iconTheme.color,
            ),
            onChanged: (value) {
              EasyDebounce.debounce(
                  'suggestions', // <-- An ID for this particular debouncer
                  const Duration(
                      milliseconds: 500), // <-- The debounce duration
                  () => BlocProvider.of<SearchBloc>(context)
                          .add(SearchEvent.getSearchSuggestion(
                        query: _textEditingController.text,
                      )) // <-- The target method
                  );
            },
            onSubmitted: (value) {
              if (value == '') {
                return;
              }
              EasyDebounce.cancel('suggestions');
              BlocProvider.of<SearchBloc>(context).add(
                  SearchEvent.getSearchResult(
                      query: _textEditingController.text, filter: "videos"));
            },
          ),
        ),
      ),
      body: SafeArea(child: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          if (state.isSuggestionDisplay == true &&
              state.isSuggestionError == false &&
              state.suggestions.isNotEmpty &&
              _textEditingController.text.isNotEmpty) {
            return ListView.separated(
                itemBuilder: (context, index) => GestureDetector(
                      onTap: () => _textEditingController.value =
                          TextEditingValue(
                              text: state.suggestions[index] ?? ''),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Text(state.suggestions[index]),
                      ),
                    ),
                separatorBuilder: (context, index) => kHeightBox10,
                itemCount: state.suggestions.length);
          } else if (state.isLoading) {
            return Center(
              child: CupertinoActivityIndicator(
                  color: Theme.of(context).indicatorColor),
            );
          } else if (state.result == null &&
              _textEditingController.text.isEmpty) {
            return Container();
          } else if (state.isError ||
              state.result == null ||
              state.result!.items.isEmpty) {
            return ErrorRetryWidget(
              lottie: 'assets/cup.zip',
              onTap: () => BlocProvider.of<SearchBloc>(context).add(
                  SearchEvent.getSearchResult(
                      query: _textEditingController.text, filter: "videos")),
            );
          } else {
            return BlocBuilder<SubscribeBloc, SubscribeState>(
              builder: (context, subscribeState) {
                return ListView.builder(
                  itemBuilder: (context, index) {
                    final Item _result = state.result!.items[index];
                    final String videoId = _result.url!.split('=').last;
                    final String channelId =
                        _result.uploaderUrl!.split("/").last;
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
                                  SubscribeEvent.deleteSubscribeInfo(
                                      id: channelId));
                            } else {
                              BlocProvider.of<SubscribeBloc>(context).add(
                                  SubscribeEvent.addSubscribe(
                                      channelInfo: Subscribe(
                                          id: channelId,
                                          channelName: _result.uploaderName ??
                                              locals.noUploaderName,
                                          isVerified:
                                              _result.uploaderVerified ??
                                                  false)));
                            }
                          },
                        ));
                  },
                  itemCount: state.result?.items.length ?? 0,
                );
              },
            );
          }
        },
      )),
    );
  }
}
