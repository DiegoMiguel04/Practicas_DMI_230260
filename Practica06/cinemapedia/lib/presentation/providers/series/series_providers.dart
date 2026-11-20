import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentation/providers/movies/movies_providers.dart';
import 'package:cinemapedia/presentation/providers/movies/movies_repository_provider.dart';

// Mismas listas con scroll infinito que las películas ([MoviesNotifier]),
// pero pidiendo series. Se reinician solas cuando cambia el idioma.

final onTheAirSeriesProvider = StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
  final fetchMoreMovies = ref.watch( movieRepositoryProvider ).getSeriesOnTheAir;
  return MoviesNotifier(
    fetchMoreMovies: fetchMoreMovies
  );
});

final airingTodaySeriesProvider = StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
  final fetchMoreMovies = ref.watch( movieRepositoryProvider ).getSeriesAiringToday;
  return MoviesNotifier(
    fetchMoreMovies: fetchMoreMovies
  );
});

final popularSeriesProvider = StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
  final fetchMoreMovies = ref.watch( movieRepositoryProvider ).getSeriesPopular;
  return MoviesNotifier(
    fetchMoreMovies: fetchMoreMovies
  );
});

final topRatedSeriesProvider = StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
  final fetchMoreMovies = ref.watch( movieRepositoryProvider ).getSeriesTopRated;
  return MoviesNotifier(
    fetchMoreMovies: fetchMoreMovies
  );
});

/// Las 6 series del carrusel de arriba.
final seriesSlideshowProvider = Provider<List<Movie>>((ref) {
  final onTheAir = ref.watch( onTheAirSeriesProvider );
  return onTheAir.take(6).toList();
});
