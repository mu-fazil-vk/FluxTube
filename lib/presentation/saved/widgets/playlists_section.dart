import 'package:flutter/material.dart';
import 'package:fluxtube/core/animations/animations.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/domain/playlist/models/local_playlist.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/infrastructure/playlist/local_playlist_service.dart';
import 'package:fluxtube/presentation/main_navigation/main_navigation_layout.dart';
import 'package:go_router/go_router.dart';

class PlaylistsSection extends StatefulWidget {
  const PlaylistsSection({super.key});

  @override
  State<PlaylistsSection> createState() => _PlaylistsSectionState();
}

class _PlaylistsSectionState extends State<PlaylistsSection> {
  final LocalPlaylistService _service = LocalPlaylistService();

  @override
  void initState() {
    super.initState();
    _service.addListener(_onChanged);
    _service.load();
  }

  @override
  void dispose() {
    _service.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final playlists = _service.playlists;
    final locals = S.of(context);

    if (playlists.isEmpty) {
      return _buildEmptyState(locals);
    }

    return GridView.builder(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.lg + MainNavigationLayout.navPadding(context).bottom,
      ),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.4,
      ),
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        final playlist = playlists[index];
        return AnimatedListItem(
          index: index,
          child: ScaleTap(
            enableHaptic: false,
            onTap: () => context.pushNamed(
              'playlistDetail',
              pathParameters: {'playlistId': playlist.id},
            ),
            scaleDown: 0.97,
            child: _PlaylistCard(playlist: playlist),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(S locals) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.video_library_outlined,
              size: AppIconSize.xxxl,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          AppSpacing.height24,
          Text(
            locals.noPlaylistsYet,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.height16,
          ScaleTap(
            enableHaptic: false,
            onTap: () => context.pushNamed('localPlaylists'),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm + 2,
              ),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: AppRadius.borderFull,
              ),
              child: Text(
                locals.localPlaylists,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  const _PlaylistCard({required this.playlist});

  final LocalPlaylist playlist;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final locals = S.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: AppRadius.borderLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                Icons.playlist_play,
                size: AppIconSize.lg,
                color: colorScheme.primary,
              ),
              const Spacer(),
              Text(
                '${playlist.videoIds.length}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          AppSpacing.height8,
          Text(
            playlist.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          AppSpacing.height4,
          Text(
            locals.videoCountLabel(playlist.videoIds.length),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
