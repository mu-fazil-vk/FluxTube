import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/watch/watch_bloc.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/domain/watch/models/basic_info.dart';
import 'package:fluxtube/domain/watch/models/piped/video/watch_resp.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/widgets/related_video_widget.dart';
import 'package:go_router/go_router.dart';

class RelatedVideoSection extends StatelessWidget {
  const RelatedVideoSection({
    super.key,
    required this.locals,
    required this.watchInfo,
  });

  final S locals;
  final WatchResp watchInfo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          locals.relatedTitle,
          style: TextStyle(
              color: Theme.of(context).textTheme.labelMedium!.color,
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
        kHeightBox20,
        SizedBox(
          height: 250,
          width: double.infinity,
          child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final String videoId =
                    watchInfo.relatedStreams![index].url!.split('=').last;
                final String channelId = watchInfo.uploaderUrl!.split("/").last;
                return GestureDetector(
                    onTap: () {
                      BlocProvider.of<WatchBloc>(context).add(
                          WatchEvent.setSelectedVideoBasicDetails(
                              details: VideoBasicInfo(
                                  title: watchInfo.relatedStreams![index].title,
                                  thumbnailUrl: watchInfo
                                      .relatedStreams![index].thumbnail,
                                  channelName: watchInfo
                                      .relatedStreams![index].uploaderName,
                                  channelThumbnailUrl: watchInfo
                                      .relatedStreams![index].uploaderAvatar,
                                  channelId: channelId,
                                  uploaderVerified: watchInfo
                                      .relatedStreams![index]
                                      .uploaderVerified)));
                      context.go('/watch/$videoId/$channelId');
                    },
                    child: RelatedVideoWidget(
                      title: watchInfo.relatedStreams![index].title ??
                          locals.noVideoTitle,
                      thumbnailUrl: watchInfo.relatedStreams![index].thumbnail,
                      duration: watchInfo.relatedStreams![index].duration,
                    ));
              },
              separatorBuilder: (context, index) => kWidthBox10,
              itemCount: watchInfo.relatedStreams?.length ?? 0),
        ),
      ],
    );
  }
}
