import 'dart:math' as math;

import 'package:cinemapedia/presentation/widgets/shared/cinemapedia_logo.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  static const name = 'splash-screen';

  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<double> _exit;

  @override
  void initState() {
    super.initState();
    _loadCatalog();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    );
    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.15, curve: Curves.easeOut),
    );
    // Al final se encoge y desaparece
    _exit = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.8, 1.0, curve: Curves.easeIn),
    );

    _controller.forward().whenComplete(() {
      if (mounted) context.go('/home/0');
    });
  }

  void _loadCatalog() {
    final isSeries = ref.read(catalogTypeProvider) == CatalogType.series;
    final providers = isSeries
        ? [
            onTheAirSeriesProvider,
            airingTodaySeriesProvider,
            popularSeriesProvider,
            topRatedSeriesProvider,
          ]
        : [
            nowPlayingMoviesProvider,
            upcomingMoviesProvider,
            popularMoviesProvider,
            topRatedMoviesProvider,
          ];

    for (final provider in providers) {
      if (ref.read(provider).isEmpty) {
        ref.read(provider.notifier).loadNextPage();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;

            final opacity = _fadeIn.value * (1 - _exit.value);
            final heartbeat = 1 + 0.035 * math.sin(t * math.pi * 6);
            final scale = heartbeat * (1.0 - 0.5 * _exit.value);

            return Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: const CinemapediaLogo(size: 130),
              ),
            );
          },
        ),
      ),
    );
  }
}
