import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/saved/saved_bloc.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/widgets/error_widget.dart';
import 'package:fluxtube/widgets/home_video_info_card_widget.dart';
import 'package:fluxtube/widgets/indicator.dart';
import 'package:go_router/go_router.dart';

class SavedVideosSection extends StatelessWidget {
  const SavedVideosSection({
    super.key,
    required this.savedState,
    required this.locals,
  });

  final SavedState savedState;
  final S locals;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: savedState.localSavedVideos.isEmpty
          ? Center(
              child: Text(locals.thereIsNoSavedVideos),
            )
          : savedState.isLoading //loading check
              ? cIndicator(context)
              : savedState.isError //empty list check
                  ? ErrorRetryWidget(
                      lottie: 'assets/black-cat.zip',
                      onTap: () => BlocProvider.of<SavedBloc>(context)
                          .add(const SavedEvent.getAllVideoInfoList()),
                    )
                  // disply result
                  : ListView.builder(
                      itemBuilder: (context, index) {
                        final savedVideo = savedState.localSavedVideos[index];
                        final String videoId = savedVideo.id;

                        final String channelId = savedVideo.uploaderId!;
                        return GestureDetector(
                          onTap: () => context.go('/watch/$videoId/$channelId'),
                          child: HomeVideoInfoCardWidget(
                            channelId: channelId,
                            cardInfo: savedVideo,
                            subscribeRowVisible: false,
                            isLive: savedVideo.isLive ?? false,
                          ),
                        );
                      },
                      itemCount: savedState.localSavedVideos.length,
                    ),
    );
  }
}
