import 'package:flutter/material.dart';
import 'package:fluxtube/core/animations/animations.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/generated/l10n.dart';

/// The real NewPipeExtractor "kiosk" categories for YouTube (verified
/// against the bundled extractor jar — these are the exact ids
/// `YoutubeService.getKioskList()` registers, not a guess). `home` isn't a
/// kiosk at all — it's the default personalized/subscription feed this
/// screen already shows, kept as the first, normally-selected option.
///
/// No `trending` entry: the "Trending" kiosk is currently broken upstream —
/// confirmed against the real NewPipe app hitting the exact same parsing
/// failure on the latest NewPipeExtractor release (there is no newer version
/// to bump to), e.g. github.com/TeamNewPipe/NewPipe issues #13723 and
/// #13559. YouTube changed the trending page format again in a way nothing
/// upstream has caught up with yet, so there's nothing to fix on our side —
/// leaving the chip in would just be a button that always errors. Re-add it
/// once an extractor release actually fixes this.
enum HomeCategory {
  home(kioskId: null),
  music(kioskId: 'trending_music'),
  moviesAndShows(kioskId: 'trending_movies_and_shows'),
  gaming(kioskId: 'trending_gaming'),
  podcasts(kioskId: 'trending_podcasts_episodes'),
  live(kioskId: 'live');

  const HomeCategory({required this.kioskId});

  /// Null for [home] (not a kiosk — the existing feed logic applies), the
  /// exact kiosk id to pass to `NewPipeChannel.getTrending` otherwise.
  final String? kioskId;

  String label(S locals) => switch (this) {
        HomeCategory.home => locals.home,
        HomeCategory.music => locals.filterMusic,
        HomeCategory.moviesAndShows => locals.categoryMoviesAndShows,
        HomeCategory.gaming => locals.categoryGaming,
        HomeCategory.podcasts => locals.categoryPodcasts,
        HomeCategory.live => locals.live,
      };
}

/// Rounded category-selector row shown under Home's header. Kiosks are a
/// NewPipeExtractor-only concept, so the caller should only show this for
/// the NewPipe backend.
class HomeCategoryRow extends StatelessWidget {
  const HomeCategoryRow({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final HomeCategory selected;
  final ValueChanged<HomeCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    final locals = S.of(context);

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: HomeCategory.values.length,
        separatorBuilder: (_, __) => AppSpacing.width8,
        itemBuilder: (context, index) {
          final category = HomeCategory.values[index];
          return _CategoryChip(
            label: category.label(locals),
            selected: category == selected,
            onTap: () => onSelected(category),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ScaleTap(
      enableHaptic: false,
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        curve: AppAnimations.defaultCurve,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHigh,
          borderRadius: AppRadius.borderFull,
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: selected
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
