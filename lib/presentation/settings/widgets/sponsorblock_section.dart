import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/settings/settings_bloc.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/presentation/settings/widgets/settings_components.dart';

class SponsorBlockSettingsSection extends StatelessWidget {
  const SponsorBlockSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final locals = S.of(context);
    final scheme = Theme.of(context).colorScheme;

    return BlocBuilder<SettingsBloc, SettingsState>(
      buildWhen: (previous, current) =>
          previous.isSponsorBlockEnabled != current.isSponsorBlockEnabled ||
          previous.sponsorBlockCategories != current.sponsorBlockCategories,
      builder: (context, state) {
        return SettingsSectionCard(
          title: locals.sponsorBlock,
          children: [
            SettingsSwitchTile(
              icon: Icons.skip_next_outlined,
              title: locals.sponsorBlock,
              subtitle: locals.sponsorBlockDescription,
              value: state.isSponsorBlockEnabled,
              onChanged: (_) => context
                  .read<SettingsBloc>()
                  .add(SettingsEvent.toggleSponsorBlock()),
            ),
            if (state.isSponsorBlockEnabled)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locals.sponsorBlockCategories,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                    AppSpacing.height8,
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        _categoryChip(context, state, 'sponsor', locals.sponsor),
                        _categoryChip(context, state, 'intro', locals.intro),
                        _categoryChip(context, state, 'outro', locals.outro),
                        _categoryChip(context, state, 'selfpromo', locals.selfPromotion),
                        _categoryChip(context, state, 'interaction', locals.interaction),
                        _categoryChip(
                            context, state, 'music_offtopic', locals.musicOfftopic),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _categoryChip(
    BuildContext context,
    SettingsState state,
    String category,
    String label,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final isSelected = state.sponsorBlockCategories.contains(category);

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? scheme.onPrimary : scheme.onSurfaceVariant,
          fontSize: 13,
        ),
      ),
      selected: isSelected,
      onSelected: (_) {
        final categories = List<String>.from(state.sponsorBlockCategories);
        if (isSelected) {
          categories.remove(category);
        } else {
          categories.add(category);
        }
        context
            .read<SettingsBloc>()
            .add(SettingsEvent.setSponsorBlockCategories(categories: categories));
      },
      backgroundColor: scheme.surfaceContainerHigh,
      selectedColor: scheme.primary,
      checkmarkColor: scheme.onPrimary,
      side: BorderSide(
        color: isSelected ? scheme.primary : scheme.outlineVariant,
      ),
      shape: const StadiumBorder(),
      showCheckmark: true,
      visualDensity: VisualDensity.compact,
    );
  }
}
