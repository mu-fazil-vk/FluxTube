import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluxtube/application/channel/channel_bloc.dart';
import 'package:fluxtube/application/subscribe/subscribe_bloc.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:fluxtube/core/strings.dart';
import 'package:fluxtube/domain/channel/models/channel_resp.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/presentation/channel/widgets/related_videos.dart';
import 'package:fluxtube/presentation/settings/functions/launch_url.dart';
import 'package:fluxtube/widgets/channel_widget.dart';
import 'package:fluxtube/widgets/error_widget.dart';
import 'package:fluxtube/widgets/indicator.dart';

class ScreenChannel extends StatelessWidget {
  const ScreenChannel({super.key, required String? channelId, avtarUrl})
      : _channelId = channelId,
        _avtarUrl = avtarUrl;
  final String? _channelId;
  final String? _avtarUrl;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_channelId != null) {
        BlocProvider.of<ChannelBloc>(context)
            .add(ChannelEvent.getChannelData(channelId: _channelId));
      }
    });
    final double _width = MediaQuery.of(context).size.width;
    final S locals = S.of(context);
    return BlocBuilder<SubscribeBloc, SubscribeState>(
      builder: (context, subscribeState) {
        return BlocBuilder<ChannelBloc, ChannelState>(
          builder: (context, state) {
            if (state.isLoading) {
              return Center(child: cIndicator(context));
            } else if (state.isError || state.result == null) {
              return Center(
                  child: ErrorRetryWidget(
                lottie: 'assets/black-cat.zip',
                onTap: () => BlocProvider.of<ChannelBloc>(context).add(
                    ChannelEvent.getChannelData(channelId: _channelId ?? '')),
              ));
            }

            final ChannelResp channelInfo = state.result!;
            final bool _isSubscribed = subscribeState.subscribedChannels
                .where((channel) => channel.id == _channelId)
                .isNotEmpty;
            return Scaffold(
              appBar: AppBar(
                  automaticallyImplyLeading: true,
                  title: Text(
                    channelInfo.name!,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                  ),
                  actions: [
                    IconButton(
                        color: kGreyColor,
                        // style: ButtonStyle(
                        //     backgroundColor:
                        //         WidgetStatePropertyAll(kGreyOpacityColor)),
                        onPressed: () async =>
                            await urlLaunch('$kYTChannelUrl${channelInfo.id}'),
                        icon: SvgPicture.asset(
                          'assets/icons/youtube.svg',
                          height: 25,
                          colorFilter:
                              ColorFilter.mode(kGreyColor!, BlendMode.srcIn),
                        )),
                  ]),
              body: SafeArea(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 230,
                    child: Stack(
                      children: [
                        ChannelBannerWidget(
                            width: _width, channelInfo: channelInfo),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: ChannelWidget(
                              channelName: channelInfo.name,
                              isVerified: channelInfo.verified,
                              subscriberCount: channelInfo.subscriberCount,
                              thumbnail: channelInfo.avatarUrl ?? _avtarUrl,
                              isSubscribed: _isSubscribed,
                              channelId: _channelId ?? '',
                              locals: locals,
                              isTapEnabled: false,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                      child: ChannelRelatedVideoSection(
                          channelId: _channelId ?? '',
                          locals: locals,
                          state: state,
                          channelInfo: channelInfo)),
                ],
              )),
            );
          },
        );
      },
    );
  }
}

class ChannelBannerWidget extends StatelessWidget {
  const ChannelBannerWidget({
    super.key,
    required double width,
    required this.channelInfo,
  }) : _width = width;

  final double _width;
  final ChannelResp channelInfo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Container(
          width: _width,
          height: 100,
          decoration: BoxDecoration(
              image: channelInfo.bannerUrl == null
                  ? null
                  : DecorationImage(
                      image: CachedNetworkImageProvider(channelInfo.bannerUrl),
                      fit: BoxFit.cover),
              color: kBlackColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(10)),
          child: channelInfo.bannerUrl == null
              ? Center(
                  child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    channelInfo.name!,
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColorLight),
                  ),
                ))
              : null),
    );
  }
}
