import 'package:flutter/material.dart';
import 'package:fluxtube/core/services/subscription_notifier.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/presentation/settings/widgets/settings_components.dart';

/// Switch for new-upload notifications from subscribed channels.
///
/// This tile owns its state rather than going through `SettingsBloc`: the bloc's
/// state and event unions are freezed-generated, and adding a field there needs
/// a `build_runner` pass. The preference is persisted in the same settings table
/// the bloc uses, so it can be folded into the bloc later without a migration.
class NewVideoNotificationTile extends StatefulWidget {
  const NewVideoNotificationTile({super.key});

  @override
  State<NewVideoNotificationTile> createState() =>
      _NewVideoNotificationTileState();
}

class _NewVideoNotificationTileState extends State<NewVideoNotificationTile> {
  final _notifier = SubscriptionNotifier();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _notifier.addListener(_onChanged);
    _notifier.loadEnabled();
  }

  @override
  void dispose() {
    _notifier.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _toggle(bool value) async {
    if (_busy) return;
    setState(() => _busy = true);
    final applied = await _notifier.setEnabled(value);
    if (!mounted) return;
    setState(() => _busy = false);

    // setEnabled returns false when the notification permission was refused,
    // so tell the user why the switch stayed off.
    if (value && !applied) {
      final locals = S.of(context);
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(locals.notificationsDenied)));
      return;
    }
    if (applied) {
      // Establishes the per-channel baseline right away so the first real check
      // has something to compare against.
      _notifier.checkForNewVideos(force: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!SubscriptionNotifier.isSupported) return const SizedBox.shrink();
    final locals = S.of(context);

    return SettingsSwitchTile(
      icon: Icons.notifications_active_outlined,
      title: locals.newVideoNotifications,
      subtitle: locals.newVideoNotificationsDescription,
      value: _notifier.isEnabled,
      onChanged: (value) {
        if (!_busy) _toggle(value);
      },
    );
  }
}
