import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/domain/subscribes/models/subscribe.dart';
import 'package:fluxtube/domain/watch/models/explode/explode_watch.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/widgets/common_video_description_widget.dart';
import 'package:go_router/go_router.dart';

class ExplodeChannelInfoSection extends StatelessWidget {
  const ExplodeChannelInfoSection({
    super.key,
    required this.watchInfo,
    required this.locals,
    required this.state,
  });

  final ExplodeWatchResp watchInfo;
  final S locals;
  final WatchState state;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: !state.isTapComments,
      child: BlocBuilder<SubscribeBloc, SubscribeState>(
        builder: (context, subscribeState) {
          final String channelId = watchInfo.channelId;
          final bool isSubscribed = subscribeState.channelInfo?.id == channelId;

          return GestureDetector(
            onTap: () => context.goNamed('channel', pathParameters: {
              'channelId': channelId,
            }, queryParameters: {
              'avtarUrl': state.selectedVideoBasicDetails?.channelThumbnailUrl,
            }),
            child: SubscribeRowWidget(
              subscribed: isSubscribed,
              uploaderUrl: state.selectedVideoBasicDetails?.channelThumbnailUrl,
              subcount: null,
              uploader: watchInfo.author,
              isVerified:
                  state.selectedVideoBasicDetails?.uploaderVerified ?? false,
              onSubscribeTap: () {
                if (isSubscribed) {
                  BlocProvider.of<SubscribeBloc>(context)
                      .add(SubscribeEvent.deleteSubscribeInfo(id: channelId));
                } else {
                  BlocProvider.of<SubscribeBloc>(context)
                      .add(SubscribeEvent.addSubscribe(
                          channelInfo: Subscribe(
                    id: channelId,
                    channelName: watchInfo.author,
                    isVerified:
                        state.selectedVideoBasicDetails?.uploaderVerified ??
                            false,
                  )));
                }
              },
            ),
          );
        },
      ),
    );
  }
}
