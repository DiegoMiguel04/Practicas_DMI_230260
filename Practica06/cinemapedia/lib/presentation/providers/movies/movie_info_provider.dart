import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cinemapedia/domain/entities/movie.dart';

final movieInfoProvider = StateNotifierProvider<MovieMapNotifier, Map<String, Movie>>((ref) {
  final movieRepository = ref.watch( movieRepositoryProvider );
  return MovieMapNotifier(getMovie: movieRepository.getMovieById );
});


/*
  {
    '505642': Movie(),
    '505643': Movie(),
    '505645': Movie(),
    '501231': Movie(),
  }
*/

typedef GetMovieCallback = Future<Movie>Function(String movieId);

class MovieMapNotifier extends StateNotifier<Map<String,Movie>> {

  final GetMovieCallback getMovie;
  final Map<String, Object> _loadErrors = {};

  MovieMapNotifier({
    required this.getMovie,
  }): super({});

  Object? loadErrorFor(String movieId) => _loadErrors[movieId];

  Future<void> loadMovie( String movieId ) async {
    if ( state[movieId] != null ) return;
    _loadErrors.remove(movieId);
    try {
      final movie = await getMovie( movieId );
      if ( !mounted ) return;
      state = { ...state, movieId: movie };
    } catch (error) {
      if ( !mounted ) return;
      _loadErrors[movieId] = error;
      // Notify the detail screen so it can show a retry instead of spinning forever.
      state = { ...state };
    }
  }

}
