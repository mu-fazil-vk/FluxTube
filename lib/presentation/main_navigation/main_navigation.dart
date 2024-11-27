import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:fluxtube/core/enums.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/presentation/watch/widgets/explode/pip_video_player.dart';
import 'package:fluxtube/presentation/watch/widgets/iFrame/pip_video_player.dart';
import 'package:fluxtube/presentation/watch/widgets/invidious/pip_video_player.dart';
import 'package:fluxtube/presentation/watch/widgets/pip_video_player.dart';

import '../home/screen_home.dart';
import '../saved/screen_saved.dart';
import '../settings/screen_settings.dart';
import '../trending/screen_trending.dart';

ValueNotifier<int> indexChangeNotifier = ValueNotifier(0);

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  MainNavigationState createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {
  final _pages = [
    const ScreenHome(),
    const ScreenTrending(),
    const ScreenSaved(),
    const ScreenSettings()
  ];

  @override
  Widget build(BuildContext context) {
    final locals = S.of(context);

    final List<TabItem> items = [
      TabItem(icon: CupertinoIcons.house_fill, title: locals.home, key: "home"),
      TabItem(
          icon: CupertinoIcons.flame_fill,
          title: locals.trending,
          key: "trending"),
      TabItem(
          icon: CupertinoIcons.bookmark_fill,
          title: locals.saved,
          key: "saved"),
      TabItem(
          icon: CupertinoIcons.settings,
          title: locals.settings,
          key: "settings"),
    ];

    return ValueListenableBuilder(
      valueListenable: indexChangeNotifier,
      builder: (BuildContext context, int index, Widget? _) {
        return Scaffold(
          body: SafeArea(
            child: BlocBuilder<SavedBloc, SavedState>(
              builder: (context, savedState) {
                return BlocBuilder<SettingsBloc, SettingsState>(
                  builder: (context, settingsState) {
                    return BlocBuilder<WatchBloc, WatchState>(
                      builder: (context, state) {
                        return Stack(
                          children: [
                            _pages[index],

                            // Invidious pip video player
                            if (state.isPipEnabled &&
                                state.selectedVideoBasicDetails?.id != null &&
                                settingsState.ytService ==
                                    YouTubeServices.invidious.name)
                              Positioned(
                                child: InvidiousPipVideoPlayerWidget(
                                  watchInfo: state.invidiousWatchResp,
                                  videoId: state.selectedVideoBasicDetails!.id,
                                  playbackPosition: state.playBack,
                                  isSaved: (savedState.videoInfo?.id ==
                                          state.selectedVideoBasicDetails?.id &&
                                      savedState.videoInfo?.isSaved == true),
                                  isHlsPlayer: settingsState.isHlsPlayer,
                                  subtitles: state.subtitles,
                                  watchState: state,
                                ),
                              ),

                            // Piped pip video player
                            if (state.isPipEnabled &&
                                state.selectedVideoBasicDetails?.id != null &&
                                settingsState.ytService ==
                                    YouTubeServices.piped.name)
                              Positioned(
                                child: PipVideoPlayerWidget(
                                  watchInfo: state.watchResp,
                                  videoId: state.selectedVideoBasicDetails!.id,
                                  playbackPosition: state.playBack,
                                  isSaved: (savedState.videoInfo?.id ==
                                          state.selectedVideoBasicDetails?.id &&
                                      savedState.videoInfo?.isSaved == true),
                                  isHlsPlayer: settingsState.isHlsPlayer,
                                  subtitles: state.subtitles,
                                  watchState: state,
                                ),
                              ),

                            // IFrame pip video player
                            if (state.isPipEnabled &&
                                state.selectedVideoBasicDetails?.id != null &&
                                settingsState.ytService ==
                                    YouTubeServices.iframe.name)
                              Align(
                                child: IFramePipVideoPlayer(
                                  id: state.selectedVideoBasicDetails!.id,
                                  isLive: state.explodeWatchResp.isLive,
                                  channelId: state
                                      .selectedVideoBasicDetails!.channelId!,
                                  settingsState: settingsState,
                                  watchState: state,
                                  isSaved: (savedState.videoInfo?.id ==
                                          state.selectedVideoBasicDetails?.id &&
                                      savedState.videoInfo?.isSaved == true),
                                  savedState: savedState,
                                  watchInfo: state.explodeWatchResp,
                                  playBack: state.playBack,
                                ),
                              ),

                            // Explode pip video player
                            if (state.isPipEnabled &&
                                state.selectedVideoBasicDetails?.id != null &&
                                settingsState.ytService ==
                                    YouTubeServices.explode.name)
                              Positioned(
                                child: ExplodePipVideoPlayerWidget(
                                  watchInfo: state.explodeWatchResp,
                                  videoId: state.selectedVideoBasicDetails!.id,
                                  playbackPosition: state.playBack,
                                  isSaved: (savedState.videoInfo?.id ==
                                          state.selectedVideoBasicDetails?.id &&
                                      savedState.videoInfo?.isSaved == true),
                                  liveUrl: state.liveStreamUrl,
                                  availableVideoTracks:
                                      state.muxedStreams ?? [],
                                  subtitles: state.subtitles,
                                  watchState: state,
                                ),
                              ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          bottomNavigationBar: BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              return BottomBarSalomon(
                items: items,
                top: 25,
                bottom: 25,
                iconSize: 26,
                heightItem: 50,
                backgroundColor: kTransparentColor,
                color: kGreyColor!,
                colorSelected: kRedColor,
                backgroundSelected: kGreyOpacityColor!,
                indexSelected: indexChangeNotifier.value,
                titleStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  overflow: TextOverflow.ellipsis,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                onTap: (int index) => indexChangeNotifier.value = index,
              );
            },
          ),
        );
      },
    );
  }
}
