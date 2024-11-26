import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/domain/subscribes/models/subscribe.dart';
import 'package:fluxtube/domain/watch/models/invidious/video/invidious_watch_resp.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/widgets/common_video_description_widget.dart';
import 'package:go_router/go_router.dart';

class InvidiousChannelInfoSection extends StatelessWidget {
  const InvidiousChannelInfoSection({
    super.key,
    required this.watchInfo,
    required this.locals,
    required this.state,
  });

  final InvidiousWatchResp watchInfo;
  final S locals;
  final WatchState state;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: !state.isTapComments,
      child: BlocBuilder<SubscribeBloc, SubscribeState>(
        builder: (context, subscribeState) {
          final String channelId = watchInfo.authorId!;
          final bool isSubscribed = subscribeState.channelInfo?.id == channelId;

          return GestureDetector(
            onTap: () => context.goNamed('channel', pathParameters: {
              'channelId': channelId,
            }, queryParameters: {
              'avtarUrl': watchInfo.authorThumbnails?.first.url,
            }),
            child: SubscribeRowWidget(
              subscribed: isSubscribed,
              uploaderUrl: watchInfo.authorThumbnails?.first.url,
              subcount: watchInfo.subCountText,
              uploader: watchInfo.author ?? locals.noUploaderName,
              isVerified: watchInfo.authorVerified ?? false,
              onSubscribeTap: () {
                if (isSubscribed) {
                  BlocProvider.of<SubscribeBloc>(context)
                      .add(SubscribeEvent.deleteSubscribeInfo(id: channelId));
                } else {
                  BlocProvider.of<SubscribeBloc>(context).add(
                      SubscribeEvent.addSubscribe(
                          channelInfo: Subscribe(
                              id: channelId,
                              channelName:
                                  watchInfo.author ?? locals.noUploaderName,
                              isVerified: watchInfo.authorVerified ?? false)));
                }
              },
            ),
          );
        },
      ),
    );
  }
}
