import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/search/search_bloc.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/core/di/injectable.dart';
import 'package:fluxtube/presentation/search/screen_search.dart';
import 'package:fluxtube/presentation/settings/screen_settings.dart';

/// The shared header used by every top-level tab (Home, Subscriptions,
/// Library, Shorts): wordmark, search entry point, and — since Settings is no
/// longer a bottom-nav tab in this design — the profile avatar that opens it.
///
/// The bar itself has no background of its own — it floats directly over
/// tab content — so all of its visual presence comes from the icon/avatar
/// "glass" chips ([_GlassBadge]) rather than a tinted/blurred backing strip.
class FluxTubeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FluxTubeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: SizedBox(
        height: 64,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: AppRadius.borderSm,
                child: Image.asset(
                  'assets/icon/icon.png',
                  width: 28,
                  height: 28,
                ),
              ),
              AppSpacing.width8,
              Expanded(
                child: Text(
                  'FLUXTUBE',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                ),
              ),
              AppSpacing.width8,
              _GlassBadge(
                size: 36,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    // SearchBloc isn't provided globally (it holds
                    // transient per-session search state), so it has to
                    // be scoped to this pushed route directly.
                    builder: (_) => BlocProvider(
                      create: (_) => getIt<SearchBloc>(),
                      child: const ScreenSearch(),
                    ),
                  ),
                ),
                child:
                    Icon(Icons.search, size: 20, color: colorScheme.onSurface),
              ),
              AppSpacing.width8,
              _GlassBadge(
                size: 36,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ScreenSettings()),
                ),
                child:
                    Icon(Icons.person, size: 18, color: colorScheme.onSurface),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A small frosted-glass "button" — blurred backdrop, a soft light-to-dark
/// gradient fill, a thin bright rim, and a lifted drop shadow — meant to
/// read as a real glass/3D object (the iOS-style "Liquid Glass" look)
/// floating over whatever content is behind it, since the header itself no
/// longer has any backing of its own to lean on for legibility.
class _GlassBadge extends StatelessWidget {
  const _GlassBadge({
    required this.size,
    required this.onTap,
    required this.child,
  });

  final double size;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: InkWell(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.24),
                  Colors.white.withValues(alpha: 0.06),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
