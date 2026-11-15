import 'package:flutter/material.dart';
import 'package:fluxtube/core/animations/animations.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/domain/subscribes/models/subscribe.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/widgets/thumbnail_image.dart';

class ChannelGridCard extends StatelessWidget {
  const ChannelGridCard({
    super.key,
    required this.channel,
    required this.index,
    required this.onTap,
    required this.onLongPress,
  });

  final Subscribe channel;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedListItem(
      index: index,
      child: ScaleTap(
        onTap: onTap,
        onLongPress: onLongPress,
        scaleDown: 0.95,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: AppRadius.borderLg,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.surfaceContainerHigh,
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.25),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: channel.avatarUrl != null && channel.avatarUrl!.isNotEmpty
                      ? ThumbnailImage.small(
                          url: channel.avatarUrl!,
                          width: 64,
                          height: 64,
                          errorWidget: (_, __, ___) => _initial(context, channel, 28),
                        )
                      : _initial(context, channel, 28),
                ),
              ),
              AppSpacing.height12,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        channel.channelName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (channel.isVerified == true) ...[
                      AppSpacing.width4,
                      Icon(
                        Icons.verified,
                        size: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _initial(BuildContext context, Subscribe channel, double fontSize) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerHigh,
      alignment: Alignment.center,
      child: Text(
        channel.channelName.isNotEmpty ? channel.channelName[0].toUpperCase() : '?',
        style: theme.textTheme.headlineSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ChannelListTile extends StatelessWidget {
  const ChannelListTile({
    super.key,
    required this.channel,
    required this.index,
    required this.onTap,
    required this.onUnsubscribe,
  });

  final Subscribe channel;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onUnsubscribe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locals = S.of(context);

    return AnimatedListItem(
      index: index,
      child: ScaleTap(
        onTap: onTap,
        scaleDown: 0.98,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: AppRadius.borderLg,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.surfaceContainerHigh,
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.25),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: channel.avatarUrl != null && channel.avatarUrl!.isNotEmpty
                      ? ThumbnailImage.small(
                          url: channel.avatarUrl!,
                          width: 48,
                          height: 48,
                          errorWidget: (_, __, ___) => _initial(context, channel),
                        )
                      : _initial(context, channel),
                ),
              ),
              AppSpacing.width12,
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        channel.channelName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (channel.isVerified == true) ...[
                      AppSpacing.width4,
                      Icon(
                        Icons.verified,
                        size: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ],
                ),
              ),
              TextButton(
                onPressed: onUnsubscribe,
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
                child: Text(
                  locals.unsubscribe,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _initial(BuildContext context, Subscribe channel) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerHigh,
      alignment: Alignment.center,
      child: Text(
        channel.channelName.isNotEmpty ? channel.channelName[0].toUpperCase() : '?',
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ShimmerChannelCard extends StatelessWidget {
  const ShimmerChannelCard({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: AppRadius.borderLg,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.surfaceContainerHigh,
            ),
          ),
          AppSpacing.height12,
          Container(
            height: 12,
            width: 60,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: AppRadius.borderXs,
            ),
          ),
        ],
      ),
    );
  }
}

class ShimmerChannelListTile extends StatelessWidget {
  const ShimmerChannelListTile({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: AppRadius.borderLg,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.surfaceContainerHigh,
            ),
          ),
          AppSpacing.width12,
          Expanded(
            child: Container(
              height: 14,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                borderRadius: AppRadius.borderXs,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
