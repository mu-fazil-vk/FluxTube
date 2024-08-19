// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_in_app_pip/flutter_in_app_pip.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/domain/watch/models/video/watch_resp.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/presentation/watch/widgets/sections/sections.dart';
import 'package:fluxtube/presentation/watch/widgets/widgets.dart';
import 'package:fluxtube/widgets/widgets.dart';

class PipedContentScreen extends StatelessWidget {
  final String id;
  final bool isSaved;
  final SavedState savedState;
  final SettingsState settingsState;
  final WatchState watchState;
  final WatchResp watchInfo;
  final double screenHeight;

  const PipedContentScreen({
    super.key,
    required this.id,
    required this.isSaved,
    required this.savedState,
    required this.settingsState,
    required this.watchState,
    required this.watchInfo,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    final locals = S.of(context);
    return Dismissible(
      direction: DismissDirection.down,
      onDismissed: (_) => buildPip(
        id: id,
        context: context,
        isSaved: isSaved,
        savedState: savedState,
        settingsState: settingsState,
        watchState: watchState,
      ),
      dismissThresholds: const {
        DismissDirection.startToEnd: 0.2, // Adjust sensitivity
        DismissDirection.endToStart: 0.2,
      },
      key: UniqueKey(),
      child: PopScope(
        canPop: false,
        onPopInvoked: (_) => buildPip(
          id: id,
          context: context,
          isSaved: isSaved,
          savedState: savedState,
          settingsState: settingsState,
          watchState: watchState,
        ),
        child: Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (watchState.isLoading || watchState.isSubtitleLoading)
                    _buildLoadingIndicator(context)
                  else
                    VideoPlayerWidget(
                      videoId: id,
                      watchInfo: watchState.watchResp,
                      defaultQuality: settingsState.defaultQuality,
                      playbackPosition:
                          savedState.videoInfo?.playbackPosition ?? 0,
                      isSaved: isSaved,
                      isHlsPlayer: settingsState.isHlsPlayer,
                      subtitles: watchState.isSubtitleLoading
                          ? []
                          : watchState.subtitles,
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCaptionRow(
                          context: context,
                          watchState: watchState,
                          watchInfo: watchInfo,
                          locals: locals,
                        ),
                        if (!watchState.isLoading) _buildViewRow(watchInfo),
                        const SizedBox(height: 10),
                        _buildLikeSection(
                          context: context,
                          id: id,
                          watchState: watchState,
                          watchInfo: watchInfo,
                          isSaved: isSaved,
                          savedState: savedState,
                          settingsState: settingsState,
                        ),
                        const Divider(),
                        if (!watchState.isLoading)
                          _buildChannelInfoSection(
                            watchState: watchState,
                            watchInfo: watchInfo,
                            locals: locals,
                          ),
                        if (!watchState.isTapComments) const Divider(),
                        const SizedBox(height: 10),
                        _buildDescriptionOrRelatedVideos(
                          id: id,
                          context: context,
                          watchState: watchState,
                          screenHeight: screenHeight,
                          watchInfo: watchInfo,
                          locals: locals,
                          settingsState: settingsState,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildLoadingIndicator(context) {
  return Container(
    height: 200,
    color: kBlackColor,
    child: Center(
      child: cIndicator(context),
    ),
  );
}

Widget _buildCaptionRow({
  required BuildContext context,
  required WatchState watchState,
  required WatchResp watchInfo,
  required S locals,
}) {
  return GestureDetector(
    onTap: () =>
        BlocProvider.of<WatchBloc>(context).add(WatchEvent.tapDescription()),
    child: CaptionRowWidget(
      caption: watchState.isLoading
          ? watchState.title
          : watchInfo.title ?? locals.noVideoTitle,
      icon: watchState.isDescriptionTapped
          ? CupertinoIcons.chevron_up
          : CupertinoIcons.chevron_down,
    ),
  );
}

Widget _buildViewRow(WatchResp watchInfo) {
  return ViewRowWidget(
    views: watchInfo.views,
    uploadedDate: watchInfo.uploadDate,
  );
}

Widget _buildLikeSection({
  required BuildContext context,
  required String id,
  required WatchState watchState,
  required WatchResp watchInfo,
  required bool isSaved,
  required SavedState savedState,
  required SettingsState settingsState,
}) {
  return watchState.isLoading
      ? const ShimmerLikeWidget()
      : LikeSection(
          id: id,
          state: watchState,
          watchInfo: watchInfo,
          pipClicked: () => buildPip(
            id: id,
            context: context,
            isSaved: isSaved,
            savedState: savedState,
            settingsState: settingsState,
            watchState: watchState,
          ),
        );
}

Widget _buildChannelInfoSection({
  required WatchState watchState,
  required WatchResp watchInfo,
  required S locals,
}) {
  return ChannelInfoSection(
    state: watchState,
    watchInfo: watchInfo,
    locals: locals,
  );
}

Widget _buildDescriptionOrRelatedVideos({
  required String id,
  required BuildContext context,
  required WatchState watchState,
  required double screenHeight,
  required WatchResp watchInfo,
  required S locals,
  required SettingsState settingsState,
}) {
  if (watchState.isDescriptionTapped) {
    return DescriptionSection(
      height: screenHeight,
      watchInfo: watchInfo,
      locals: locals,
    );
  }

  if (!watchState.isTapComments) {
    if (settingsState.isHideRelated) {
      return const SizedBox();
    }
    return watchState.isLoading
        ? SizedBox(
            height: 350,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return const ShimmerRelatedVideoWidget();
              },
              separatorBuilder: (context, index) => kWidthBox10,
              itemCount: 5,
            ),
          )
        : RelatedVideoSection(
            locals: locals,
            watchInfo: watchInfo,
          );
  }

  return CommentSection(
    videoId: id,
    state: watchState,
    height: screenHeight,
    locals: locals,
  );
}

void buildPip({
  required String id,
  required BuildContext context,
  required WatchState watchState,
  required SettingsState settingsState,
  required SavedState savedState,
  required bool isSaved,
  bool isPop = true,
}) async {
  if (isPop) {
    Navigator.pop(context);
  }
  BlocProvider.of<WatchBloc>(context).add(WatchEvent.togglePip(value: true));
  PictureInPicture.startPiP(
    pipWidget: NavigatablePiPWidget(
      onPiPClose: () {
        BlocProvider.of<WatchBloc>(context)
            .add(WatchEvent.togglePip(value: false));
      },
      elevation: 10,
      pipBorderRadius: 10,
      builder: (BuildContext context) {
        return PipVideoPlayerWidget(
          videoId: id,
          watchInfo: watchState.watchResp,
          defaultQuality: settingsState.defaultQuality,
          playbackPosition: savedState.videoInfo?.playbackPosition ?? 0,
          isSaved: isSaved,
          isHlsPlayer: settingsState.isHlsPlayer,
          subtitles: watchState.isSubtitleLoading ? [] : watchState.subtitles,
        );
      },
    ),
  );
}
