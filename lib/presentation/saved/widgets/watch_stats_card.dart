import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluxtube/domain/saved/models/local_store.dart';
import 'package:fluxtube/generated/l10n.dart';

/// At-a-glance watch stats computed from local history — nothing leaves the
/// device and nothing extra is queried.
class WatchStatsCard extends StatelessWidget {
  const WatchStatsCard({
    super.key,
    required this.history,
    required this.savedCount,
  });

  final List<LocalStoreVideoInfo> history;
  final int savedCount;

  @override
  Widget build(BuildContext context) {
    final locals = S.of(context);
    if (history.isEmpty) return const SizedBox.shrink();
    final stats = _WatchStats.from(history);
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primaryContainer,
              Color.lerp(scheme.primaryContainer, scheme.tertiary, 0.55)!,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(CupertinoIcons.chart_bar_alt_fill,
                      color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    locals.watchStatsTitle.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.66,
                    ),
                  ),
                  const Spacer(),
                  if (stats.thisWeek > 0)
                    Text(
                      locals.watchStatsThisWeek(stats.thisWeek),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _Stat(
                      value: _formatHours(stats.watchSeconds),
                      label: locals.watchStatsWatched),
                  _Stat(
                      value: '${history.length}',
                      label: locals.watchStatsVideos),
                  _Stat(value: '$savedCount', label: locals.watchStatsSaved),
                ],
              ),
              if (stats.topChannel != null) ...[
                const SizedBox(height: 10),
                Text(
                  locals.watchStatsTopChannel(stats.topChannel!),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _formatHours(int seconds) {
    if (seconds < 3600) return '${(seconds / 60).round()}m';
    final hours = seconds / 3600;
    return hours < 10 ? '${hours.toStringAsFixed(1)}h' : '${hours.round()}h';
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              height: 1.1,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _WatchStats {
  _WatchStats(this.watchSeconds, this.thisWeek, this.topChannel);

  final int watchSeconds;
  final int thisWeek;
  final String? topChannel;

  // Memoised on list identity: SavedBloc emits a new list on every change,
  // so an unchanged list means unchanged stats across rebuilds.
  static List<LocalStoreVideoInfo>? _lastInput;
  static _WatchStats? _lastResult;

  static _WatchStats from(List<LocalStoreVideoInfo> history) {
    if (identical(history, _lastInput) && _lastResult != null) {
      return _lastResult!;
    }
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    var seconds = 0;
    var week = 0;
    final channelCounts = <String, int>{};
    for (final v in history) {
      final position = v.playbackPosition ?? 0;
      final duration = v.duration ?? 0;
      seconds += duration > 0 && position > duration ? duration : position;
      if (v.time != null && v.time!.isAfter(weekAgo)) week++;
      final channel = v.uploaderName;
      if (channel != null && channel.isNotEmpty) {
        channelCounts[channel] = (channelCounts[channel] ?? 0) + 1;
      }
    }
    String? top;
    var best = 1;
    channelCounts.forEach((name, count) {
      if (count > best) {
        best = count;
        top = name;
      }
    });
    _lastInput = history;
    return _lastResult = _WatchStats(seconds, week, top);
  }
}
