import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/domain/saved/models/local_store.dart';
import 'package:fluxtube/domain/watch/models/basic_info.dart';
import 'package:fluxtube/widgets/thumbnail_image.dart';
import 'package:go_router/go_router.dart';

/// Horizontal strip of partially watched videos, resuming where they left
/// off. Hidden entirely when nothing qualifies.
class ContinueWatchingRow extends StatefulWidget {
  const ContinueWatchingRow({super.key});

  static List<LocalStoreVideoInfo> inProgress(
      List<LocalStoreVideoInfo> history) {
    final items = history.where((v) {
      final position = v.playbackPosition ?? 0;
      final duration = v.duration ?? 0;
      return !(v.isLive ?? false) &&
          duration > 60 &&
          position > 10 &&
          position < duration * 0.95;
    }).toList()
      ..sort((a, b) => (b.time ?? DateTime(0)).compareTo(a.time ?? DateTime(0)));
    return items.take(12).toList();
  }

  @override
  State<ContinueWatchingRow> createState() => _ContinueWatchingRowState();
}

class _ContinueWatchingRowState extends State<ContinueWatchingRow> {
  static bool _dismissedThisSession = false;

  @override
  Widget build(BuildContext context) {
    if (_dismissedThisSession) return const SizedBox.shrink();
    return BlocBuilder<SavedBloc, SavedState>(
      buildWhen: (p, c) =>
          !identical(p.localSavedHistoryVideos, c.localSavedHistoryVideos),
      builder: (context, state) {
        final items =
            ContinueWatchingRow.inProgress(state.localSavedHistoryVideos);
        if (items.isEmpty) return const SizedBox.shrink();
        final scheme = Theme.of(context).colorScheme;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 4, 6),
              child: Row(
                children: [
                  Icon(CupertinoIcons.play_circle_fill,
                      size: 16, color: scheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    'CONTINUE WATCHING',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.66,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    iconSize: 16,
                    tooltip: 'Hide',
                    onPressed: () =>
                        setState(() => _dismissedThisSession = true),
                    icon: Icon(CupertinoIcons.xmark,
                        color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 128,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) => _ResumeCard(video: items[i]),
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}

class _ResumeCard extends StatelessWidget {
  const _ResumeCard({required this.video});

  final LocalStoreVideoInfo video;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final progress = ((video.playbackPosition ?? 0) / (video.duration ?? 1))
        .clamp(0.0, 1.0);
    final remaining = (video.duration ?? 0) - (video.playbackPosition ?? 0);
    return GestureDetector(
      onTap: () => _open(context),
      child: SizedBox(
        width: 168,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 168,
                height: 94,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (video.thumbnail != null)
                      ThumbnailImage.small(url: video.thumbnail!)
                    else
                      ColoredBox(color: scheme.surfaceContainerHigh),
                    Positioned(
                      right: 6,
                      bottom: 8,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          child: Text(
                            '${_format(remaining)} left',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                    const Center(
                      child: Icon(CupertinoIcons.play_fill,
                          color: Colors.white70, size: 28),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 3,
                        color: scheme.primaryContainer,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              video.title ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                height: 1.2,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _format(int seconds) {
    if (seconds <= 0) return '0:00';
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = (seconds % 60).toString().padLeft(2, '0');
    return h > 0 ? '$h:${m.toString().padLeft(2, '0')}:$s' : '$m:$s';
  }

  void _open(BuildContext context) {
    final channelId = video.uploaderId ?? '';
    BlocProvider.of<WatchBloc>(context).add(
      WatchEvent.setSelectedVideoBasicDetails(
        details: VideoBasicInfo(
          id: video.id,
          title: video.title,
          thumbnailUrl: video.thumbnail,
          channelName: video.uploaderName,
          channelThumbnailUrl: video.uploaderAvatar,
          channelId: channelId,
          uploaderVerified: video.uploaderVerified,
        ),
      ),
    );
    context.goNamed('watch', pathParameters: {
      'videoId': video.id,
      'channelId': channelId,
    });
  }
}
