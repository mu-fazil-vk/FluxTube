import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/settings/settings_bloc.dart';
import 'package:fluxtube/core/enums.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/presentation/settings/widgets/settings_components.dart';

List<DropdownMenuItem<String>> _getQualities(S locals) => [
  DropdownMenuItem(value: "144p", child: Text(locals.quality144p)),
  DropdownMenuItem(value: "240p", child: Text(locals.quality240p)),
  DropdownMenuItem(value: "360p", child: Text(locals.quality360p)),
  DropdownMenuItem(value: "480p", child: Text(locals.quality480p)),
  DropdownMenuItem(value: "720p", child: Text(locals.quality720p)),
  DropdownMenuItem(value: "1080p", child: Text(locals.quality1080p)),
  DropdownMenuItem(value: "1440p", child: Text(locals.quality1440p)),
];

List<DropdownMenuItem<YouTubeServices>> _getServices(S locals) {
  final services = <DropdownMenuItem<YouTubeServices>>[];

  // NewPipe is only available on Android (recommended)
  if (Platform.isAndroid) {
    services.add(DropdownMenuItem(
      value: YouTubeServices.newpipe,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(locals.serviceNewPipe),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              '★',
              style: TextStyle(fontSize: 10, color: Colors.green),
            ),
          ),
        ],
      ),
    ));
  }

  // Piped and Explode are deliberately absent — see removedYouTubeServices.
  services.add(DropdownMenuItem(
    value: YouTubeServices.invidious,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(locals.serviceInvidious),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            locals.serviceLimited,
            style: const TextStyle(fontSize: 10, color: Colors.orange),
          ),
        ),
      ],
    ),
  ));

  return services;
}

List<DropdownMenuItem<String>> _getVideoFitModes(S locals) => [
  DropdownMenuItem(value: "contain", child: Text(locals.videoFitContain)),
  DropdownMenuItem(value: "cover", child: Text(locals.videoFitCover)),
  DropdownMenuItem(value: "fill", child: Text(locals.videoFitFill)),
  DropdownMenuItem(value: "fitWidth", child: Text(locals.videoFitFitWidth)),
  DropdownMenuItem(value: "fitHeight", child: Text(locals.videoFitFitHeight)),
];

List<DropdownMenuItem<int>> _getSkipIntervals(S locals) => [
  DropdownMenuItem(value: 5, child: Text("5 ${locals.seconds}")),
  DropdownMenuItem(value: 10, child: Text("10 ${locals.seconds}")),
  DropdownMenuItem(value: 15, child: Text("15 ${locals.seconds}")),
  DropdownMenuItem(value: 30, child: Text("30 ${locals.seconds}")),
  DropdownMenuItem(value: 60, child: Text("60 ${locals.seconds}")),
];

List<DropdownMenuItem<double>> _getSubtitleSizes(S locals) => [
  DropdownMenuItem(value: 24.0, child: Text(locals.subtitleSizeSmall)),
  DropdownMenuItem(value: 32.0, child: Text(locals.subtitleSizeMedium)),
  DropdownMenuItem(value: 42.0, child: Text(locals.subtitleSizeLarge)),
  DropdownMenuItem(value: 54.0, child: Text(locals.subtitleSizeExtraLarge)),
];

class VideoSettingsSection extends StatelessWidget {
  const VideoSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final locals = S.of(context);
    final scheme = Theme.of(context).colorScheme;

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return SettingsSectionCard(
          title: locals.video,
          children: [
            SettingsActionTile(
              icon: Icons.hd_outlined,
              title: locals.defaultQuality,
              trailing: DropdownButton(
                value: state.defaultQuality,
                underline: const SizedBox.shrink(),
                dropdownColor: scheme.surfaceContainerHigh,
                items: _getQualities(locals),
                onChanged: (quality) => context.read<SettingsBloc>().add(
                    SettingsEvent.getDefaultQuality(quality: quality.toString())),
              ),
            ),
            SettingsActionTile(
              icon: Icons.network_cell_outlined,
              title: locals.youtubeService,
              trailing: DropdownButton(
                value: YouTubeServices.values.firstWhere((e) => e.name == state.ytService),
                underline: const SizedBox.shrink(),
                dropdownColor: scheme.surfaceContainerHigh,
                items: _getServices(locals),
                onChanged: (service) {
                  if (service == null) return;
                  final oldService = state.ytService;
                  context.read<SettingsBloc>().add(SettingsEvent.setYTService(service: service));

                  // Only fetch instances for services that need them (not NewPipe)
                  if (service != YouTubeServices.newpipe) {
                    if (service == YouTubeServices.invidious) {
                      context.read<SettingsBloc>().add(SettingsEvent.fetchInvidiousInstances());
                    } else {
                      context.read<SettingsBloc>().add(SettingsEvent.fetchPipedInstances());
                    }
                  }

                  if (oldService != service.name) {
                    final serviceName = switch (service) {
                      YouTubeServices.newpipe => locals.serviceNewPipe,
                      YouTubeServices.piped => locals.servicePiped,
                      YouTubeServices.invidious => locals.serviceInvidious,
                      YouTubeServices.explode => locals.serviceExplode,
                    };
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Switched to $serviceName'),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
            ),
            _ProviderNote(
              text: state.ytService == YouTubeServices.invidious.name
                  ? locals.serviceInvidiousNote
                  : locals.serviceRemovedNote,
            ),
            SettingsActionTile(
              icon: Icons.aspect_ratio_outlined,
              title: locals.videoFit,
              trailing: DropdownButton(
                value: state.videoFitMode,
                underline: const SizedBox.shrink(),
                dropdownColor: scheme.surfaceContainerHigh,
                items: _getVideoFitModes(locals),
                onChanged: (fitMode) {
                  if (fitMode == null) return;
                  context.read<SettingsBloc>().add(SettingsEvent.setVideoFitMode(fitMode: fitMode));
                },
              ),
            ),
            SettingsActionTile(
              icon: Icons.fast_forward_outlined,
              title: locals.skipInterval,
              subtitle: locals.skipIntervalDescription,
              trailing: DropdownButton(
                value: state.skipInterval,
                underline: const SizedBox.shrink(),
                dropdownColor: scheme.surfaceContainerHigh,
                items: _getSkipIntervals(locals),
                onChanged: (interval) {
                  if (interval == null) return;
                  context.read<SettingsBloc>().add(SettingsEvent.setSkipInterval(seconds: interval));
                },
              ),
            ),
            SettingsActionTile(
              icon: Icons.subtitles_outlined,
              title: locals.subtitleSize,
              subtitle: locals.subtitleSizeDescription,
              trailing: DropdownButton(
                value: state.subtitleSize,
                underline: const SizedBox.shrink(),
                dropdownColor: scheme.surfaceContainerHigh,
                items: _getSubtitleSizes(locals),
                onChanged: (size) {
                  if (size == null) return;
                  context.read<SettingsBloc>().add(SettingsEvent.setSubtitleSize(size: size));
                },
              ),
            ),
            SettingsSwitchTile(
              icon: CupertinoIcons.play,
              title: locals.hlsPlayer,
              subtitle: locals.enableHlsPlayerDescription,
              value: state.isHlsPlayer,
              onChanged: (_) => context.read<SettingsBloc>().add(SettingsEvent.toggleHlsPlayer()),
            ),
            SettingsSwitchTile(
              icon: Icons.history,
              title: locals.history,
              subtitle: locals.disableVideoHistory,
              value: !state.isHistoryVisible,
              onChanged: (_) =>
                  context.read<SettingsBloc>().add(SettingsEvent.toggleHistoryVisibility()),
            ),
            SettingsSwitchTile(
              icon: CupertinoIcons.hand_thumbsdown,
              title: locals.retrieveDislikes,
              subtitle: locals.retrieveDislikeCounts,
              value: state.isDislikeVisible,
              onChanged: (_) =>
                  context.read<SettingsBloc>().add(SettingsEvent.toggleDislikeVisibility()),
            ),
            SettingsSwitchTile(
              icon: Icons.picture_in_picture_alt_outlined,
              title: locals.disablePipPlayer,
              value: state.isPipDisabled,
              onChanged: (_) => context.read<SettingsBloc>().add(SettingsEvent.togglePipPlayer()),
            ),
            // Auto PiP - only available on Android
            if (Platform.isAndroid && !state.isPipDisabled)
              SettingsSwitchTile(
                icon: Icons.home_outlined,
                title: locals.autoPip,
                subtitle: locals.autoPipDescription,
                value: state.isAutoPipEnabled,
                onChanged: (_) => context.read<SettingsBloc>().add(SettingsEvent.toggleAutoPip()),
              ),
            SettingsSwitchTile(
              icon: CupertinoIcons.doc_text_search,
              title: locals.searchHistoryEnabled,
              subtitle: locals.searchHistoryEnabledDescription,
              value: state.isSearchHistoryEnabled,
              onChanged: (_) =>
                  context.read<SettingsBloc>().add(SettingsEvent.toggleSearchHistoryEnabled()),
            ),
            if (state.isSearchHistoryEnabled)
              SettingsSwitchTile(
                icon: CupertinoIcons.eye,
                title: locals.showSearchHistory,
                subtitle: locals.showSearchHistoryDescription,
                value: state.isSearchHistoryVisible,
                onChanged: (_) => context
                    .read<SettingsBloc>()
                    .add(SettingsEvent.toggleSearchHistoryVisibility()),
              ),
          ],
        );
      },
    );
  }
}

/// Full-width provider status note under the service picker — collapsed to
/// two lines so it doesn't crowd the settings list, expandable on tap.
class _ProviderNote extends StatefulWidget {
  const _ProviderNote({required this.text});

  final String text;

  @override
  State<_ProviderNote> createState() => _ProviderNoteState();
}

class _ProviderNoteState extends State<_ProviderNote> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(CupertinoIcons.info_circle,
                size: 16, color: scheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.topCenter,
                child: Text(
                  widget.text,
                  maxLines: _expanded ? null : 2,
                  overflow:
                      _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

