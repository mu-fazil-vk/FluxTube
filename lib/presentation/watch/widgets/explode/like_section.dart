import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/strings.dart';
import 'package:fluxtube/domain/saved/models/local_store.dart';
import 'package:fluxtube/domain/watch/models/explode/explode_watch.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/presentation/settings/utils/launch_url.dart';
import 'package:fluxtube/presentation/watch/widgets/like_widgets.dart';
import 'package:share_plus/share_plus.dart';

class ExplodeLikeSection extends StatelessWidget {
  ExplodeLikeSection({
    super.key,
    required this.id,
    required this.watchInfo,
    required this.state,
    required this.pipClicked,
  });

  final String id;
  final ExplodeWatchResp watchInfo;
  final WatchState state;
  final VoidCallback pipClicked;

  final ValueNotifier<bool> _checkedBoxNotifier = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final S locals = S.of(context);
    return BlocBuilder<SavedBloc, SavedState>(
      builder: (context, savedState) {
        bool isSaved = (savedState.videoInfo?.id == id &&
                savedState.videoInfo?.isSaved == true)
            ? true
            : false;
        return BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, settingsState) {
            return LikeRowWidget(
                like: watchInfo.likeCount,
                dislikes: watchInfo.dislikeCount,
                isDislikeVisible: settingsState.isDislikeVisible,
                isCommentTapped: state.isTapComments,
                isPipDesabled: settingsState.isPipDisabled,
                onTapComment: () {
                  if (state.isDescriptionTapped) {
                    BlocProvider.of<WatchBloc>(context)
                        .add(WatchEvent.tapDescription());
                  }
                  BlocProvider.of<WatchBloc>(context)
                      .add(WatchEvent.getCommentData(id: id));
                },
                onTapShare: () {
                  alertboxMethod(context, locals);
                },
                isSaveTapped: isSaved,
                onTapSave: () {
                  BlocProvider.of<SavedBloc>(context).add(
                    SavedEvent.addVideoInfo(
                      videoInfo: LocalStoreVideoInfo(
                          id: id,
                          title: watchInfo.title,
                          views: watchInfo.viewCount,
                          thumbnail: watchInfo.thumbnailUrl,
                          uploadedDate: watchInfo.uploadDate.toString(),
                          uploaderAvatar: null,
                          uploaderName: watchInfo.author,
                          uploaderId: watchInfo.channelId,
                          uploaderSubscriberCount: null,
                          duration: watchInfo.duration.inSeconds,
                          playbackPosition:
                              savedState.videoInfo?.playbackPosition,
                          uploaderVerified: false,
                          isSaved: !isSaved,
                          isLive: watchInfo.isLive,
                          isHistory: savedState.videoInfo?.isHistory),
                    ),
                  );
                },
                onTapYoutube: () async => await urlLaunch('$kYTBaseUrl$id'),
                pipClicked: pipClicked);
          },
        );
      },
    );
  }

  Future<dynamic> alertboxMethod(BuildContext context, S locals) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return ValueListenableBuilder(
            valueListenable: _checkedBoxNotifier,
            builder: (context, value, _) {
              return AlertDialog(
                title: Text(locals.share),
                content: Row(
                  children: [
                    Checkbox(
                        value: _checkedBoxNotifier.value,
                        onChanged: (value) =>
                            _checkedBoxNotifier.value = value ?? false),
                    Text(locals.includeTitle),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text(locals.share),
                    onPressed: () async {
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                      if (_checkedBoxNotifier.value) {
                        await Share.share(
                            "${watchInfo.title}\n\n$kYTBaseUrl$id");
                      } else {
                        await Share.share('$kYTBaseUrl$id');
                      }
                    },
                  ),
                ],
              );
            });
      },
    );
  }
}
