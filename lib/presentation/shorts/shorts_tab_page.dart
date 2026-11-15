import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/enums.dart';
import 'package:fluxtube/domain/channel/models/newpipe/newpipe_channel_resp.dart';
import 'package:fluxtube/domain/subscribes/models/subscribe.dart';
import 'package:fluxtube/domain/watch/models/newpipe/newpipe_related.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/infrastructure/newpipe/newpipe_channel.dart';
import 'package:fluxtube/presentation/main_navigation/main_navigation.dart';
import 'package:fluxtube/presentation/shorts/screen_shorts.dart';

/// Embeds Shorts as a bottom-nav tab rather than only a pushed route.
///
/// There is no general "get me a shorts feed" endpoint in NewPipeExtractor
/// (verified against the actual bundled NewPipe Extractor jar: no Shorts kiosk, no
/// Shorts search-content-filter — the only Shorts-specific surface it has
/// at all is a channel's own "Shorts" tab). So this deliberately does **not**
/// fall back to Home's personalized feed or any other shared/generic API —
/// that would just be reintroducing a dependency on something that isn't
/// actually a Shorts API. Instead it fetches directly and only from each
/// subscribed channel's Shorts tab (NewPipe only), the same API the Channel
/// screen's own Shorts tab already uses. No subscriptions (or a non-NewPipe
/// backend, which this native call doesn't support) means an honest empty
/// state rather than borrowing unrelated content to fill the tab.
class ShortsTabPage extends StatefulWidget {
  const ShortsTabPage({super.key});

  @override
  State<ShortsTabPage> createState() => _ShortsTabPageState();
}

class _ShortsTabPageState extends State<ShortsTabPage> {
  /// Bounds how many channels get a shorts-tab fetch per load, so opening
  /// this tab with a large subscription list doesn't fire dozens of
  /// sequential native extractor calls.
  static const _maxChannelsPerLoad = 8;

  bool _loading = false;
  bool _attempted = false;

  /// Whether the channel-tab aggregation has finished (successfully or not)
  /// and won't produce anything more on its own. Only once this is true do
  /// we fall back to Home's shared personalized-feed fetch — Shorts should
  /// load its own dedicated data first rather than always piggybacking on
  /// Home's (potentially unstarted) fetch as a side effect of being opened.
  bool _channelAggregationDone = false;
  List<ShortItem> _channelShorts = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_attempted) {
      _attempted = true;
      _loadFromSubscribedChannels();
    }
  }

  Future<void> _loadFromSubscribedChannels() async {
    final settingsState = context.read<SettingsBloc>().state;
    if (settingsState.ytService != YouTubeServices.newpipe.name) {
      setState(() => _channelAggregationDone = true);
      return;
    }

    final channels = context.read<SubscribeBloc>().state.subscribedChannels;
    if (channels.isEmpty) {
      setState(() => _channelAggregationDone = true);
      return;
    }

    setState(() => _loading = true);

    final sample = List<Subscribe>.from(channels)..shuffle();
    final picked = sample.take(_maxChannelsPerLoad).toList();

    final results = await Future.wait(
      picked.map(_fetchChannelShorts),
    );

    final combined = results.expand((list) => list).toList()..shuffle();

    if (!mounted) return;
    setState(() {
      _channelShorts = combined;
      _loading = false;
      _channelAggregationDone = true;
    });
  }

  Future<List<ShortItem>> _fetchChannelShorts(Subscribe channel) async {
    try {
      final profile = await NewPipeChannel.getChannel(channel.id);
      final shortsTab = profile.tabs?.firstWhere(
        (t) => t.name?.toLowerCase() == 'shorts',
        orElse: () => NewPipeChannelTab(),
      );
      if (shortsTab?.url == null) return const [];

      final tabContent = await NewPipeChannel.getChannelTab(
        shortsTab!.url!,
        tabId: shortsTab.id,
        contentFilters: shortsTab.contentFilters,
      );
      final videos = tabContent.videos ?? const <NewPipeRelatedStream>[];
      return videos.map(_toShortItem).toList();
    } catch (_) {
      // One channel failing (private, deleted, extractor hiccup) shouldn't
      // take down the whole aggregated feed.
      return const [];
    }
  }

  /// Pull-to-refresh — re-fetches a fresh (re-shuffled) batch from the same
  /// subscribed-channels source. Deliberately doesn't touch `_loading`: that
  /// flag drives the full-screen spinner shown before any content has ever
  /// loaded, and a refresh should let [RefreshIndicator] show its own
  /// spinner while the current feed stays visible underneath, not blank the
  /// whole screen out from under the user.
  Future<void> _refresh() async {
    final settingsState = context.read<SettingsBloc>().state;
    if (settingsState.ytService != YouTubeServices.newpipe.name) return;

    final channels = context.read<SubscribeBloc>().state.subscribedChannels;
    if (channels.isEmpty) return;

    final sample = List<Subscribe>.from(channels)..shuffle();
    final picked = sample.take(_maxChannelsPerLoad).toList();

    final results = await Future.wait(picked.map(_fetchChannelShorts));
    final combined = results.expand((list) => list).toList()..shuffle();

    if (!mounted) return;
    setState(() => _channelShorts = combined);
  }

  ShortItem _toShortItem(NewPipeRelatedStream stream) {
    // Stream URLs here come back as normal `watch?v=ID` URLs (confirmed via
    // a real device log — a `/`-based split grabbed "watch" instead of the
    // ID), same as the proven pattern in newpipe_channel_tab_content.dart.
    final videoId = stream.url?.split('=').last ?? '';
    return ShortItem(
      id: videoId,
      title: stream.name,
      thumbnailUrl: stream.thumbnailUrl,
      uploaderName: stream.uploaderName,
      uploaderAvatar: stream.uploaderAvatarUrl,
      uploaderId: stream.uploaderUrl?.split('/').last,
      viewCount: stream.viewCount,
      duration: stream.duration,
      uploaderVerified: stream.uploaderVerified,
    );
  }

  @override
  Widget build(BuildContext context) {
    // The tab stays mounted in the navigation stack, so a subscription made
    // after the first load would otherwise never show up here.
    return BlocListener<SubscribeBloc, SubscribeState>(
      listenWhen: (p, c) =>
          !identical(p.subscribedChannels, c.subscribedChannels),
      listener: (context, _) {
        if (_channelShorts.isEmpty && !_loading) _loadFromSubscribedChannels();
      },
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final locals = S.of(context);

    // Still fetching (either the initial channel-tab pass, or we haven't
    // even determined yet whether it applies) and nothing to show yet.
    if (!_channelAggregationDone || _loading) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_channelShorts.isEmpty) {
      return ColoredBox(
        color: Colors.black,
        child: Center(
          child: Text(
            locals.noShorts,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return ValueListenableBuilder<int>(
      valueListenable: indexChangeNotifier,
      builder: (context, activeTabIndex, _) {
        return ScreenShorts(
          shorts: _channelShorts,
          initialIndex: 0,
          showCloseButton: false,
          isActive: activeTabIndex == shortsTabIndex,
          onRefresh: _refresh,
        );
      },
    );
  }
}
