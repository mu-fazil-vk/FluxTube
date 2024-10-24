import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/domain/watch/models/basic_info.dart';
import 'package:go_router/go_router.dart';

import 'package:fluxtube/application/watch/watch_bloc.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/domain/watch/models/explode/explode_watch.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/widgets/related_video_widget.dart';

class ExplodeRelatedVideoSection extends StatelessWidget {
  const ExplodeRelatedVideoSection({
    super.key,
    required this.locals,
    required this.watchInfo,
    required this.related,
  });

  final S locals;
  final ExplodeWatchResp watchInfo;
  final List<MyRelatedVideo> related;

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
                final String videoId = related[index].id;
                final String channelId = related[index].channelId;
                return GestureDetector(
                    onTap: () {
                      BlocProvider.of<WatchBloc>(context).add(
                          WatchEvent.setSelectedVideoBasicDetails(
                              details: VideoBasicInfo(
                                  id: videoId,
                                  title: related[index].title,
                                  thumbnailUrl: related[index].thumbnailUrl,
                                  channelName: related[index].author,
                                  channelThumbnailUrl: null,
                                  channelId: channelId,
                                  uploaderVerified: null)));

                      context.goNamed('watch', pathParameters: {
                        'videoId': videoId,
                        'channelId': channelId,
                      });
                    },
                    child: RelatedVideoWidget(
                      title: related[index].title,
                      thumbnailUrl: related[index].thumbnailUrl,
                      duration: related[index].duration.inSeconds,
                    ));
              },
              separatorBuilder: (context, index) => kWidthBox10,
              itemCount: related.length),
        ),
      ],
    );
  }
}
