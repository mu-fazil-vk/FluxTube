import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/domain/subscribes/models/subscribe.dart';
import 'package:fluxtube/domain/watch/models/video/watch_resp.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/widgets/common_video_description_widget.dart';
import 'package:go_router/go_router.dart';

class ChannelInfoSection extends StatelessWidget {
  const ChannelInfoSection({
    super.key,
    required this.watchInfo,
    required this.locals,
    required this.state,
  });

  final WatchResp watchInfo;
  final S locals;
  final WatchState state;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: !state.isTapComments,
      child: BlocBuilder<SubscribeBloc, SubscribeState>(
        builder: (context, subscribeState) {
          final String channelId = watchInfo.uploaderUrl!.split("/").last;
          final bool isSubscribed = subscribeState.channelInfo?.id == channelId;

          return GestureDetector(
            onTap: () => context.goNamed('channel', pathParameters: {
              'channelId': channelId,
            }, queryParameters: {
              'avtarUrl': watchInfo.uploaderAvatar,
            }),
            child: SubscribeRowWidget(
              subscribed: isSubscribed,
              uploaderUrl: watchInfo.uploaderAvatar,
              subcount: watchInfo.uploaderSubscriberCount,
              uploader: watchInfo.uploader ?? locals.noUploaderName,
              isVerified: watchInfo.uploaderVerified ?? false,
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
                                  watchInfo.uploader ?? locals.noUploaderName,
                              isVerified:
                                  watchInfo.uploaderVerified ?? false)));
                }
              },
            ),
          );
        },
      ),
    );
  }
}
