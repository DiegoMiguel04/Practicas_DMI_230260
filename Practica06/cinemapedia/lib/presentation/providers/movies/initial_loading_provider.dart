import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cinemapedia/presentation/providers/series/series_providers.dart';
import 'package:cinemapedia/presentation/providers/settings/catalog_type_provider.dart';
import 'movies_providers.dart';

/// True while the selected catalog's first requests are still running.
final initialLoadingProvider = Provider<bool>((ref) {
  final isSeries = ref.watch(catalogTypeProvider) == CatalogType.series;
  final providers = isSeries
      ? [onTheAirSeriesProvider, popularSeriesProvider, topRatedSeriesProvider, airingTodaySeriesProvider]
      : [nowPlayingMoviesProvider, popularMoviesProvider, topRatedMoviesProvider, upcomingMoviesProvider];

  for (final provider in providers) {
    ref.watch(provider);
    if (!ref.read(provider.notifier).hasCompletedInitialLoad) return true;
  }
  return false;
});
