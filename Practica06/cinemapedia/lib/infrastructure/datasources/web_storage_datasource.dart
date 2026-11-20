import 'dart:convert';

import 'package:cinemapedia/domain/datasources/local_storage_datasource.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:shared_preferences/shared_preferences.dart';

LocalStorageDatasource createLocalStorageDatasource() => WebStorageDatasource();

class WebStorageDatasource extends LocalStorageDatasource {
  static const _key = 'favorite_movies';

  Future<SharedPreferences> get _preferences => SharedPreferences.getInstance();

  Future<List<Movie>> _readMovies() async {
    final raw = (await _preferences).getString(_key);
    if (raw == null) return [];
    final values = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return values.map((value) => Movie(
      adult: value['adult'] as bool,
      backdropPath: value['backdropPath'] as String,
      genreIds: (value['genreIds'] as List).cast<String>(),
      id: value['id'] as int,
      originalLanguage: value['originalLanguage'] as String,
      originalTitle: value['originalTitle'] as String,
      overview: value['overview'] as String,
      popularity: (value['popularity'] as num).toDouble(),
      posterPath: value['posterPath'] as String,
      releaseDate: DateTime.parse(value['releaseDate'] as String),
      title: value['title'] as String,
      video: value['video'] as bool,
      voteAverage: (value['voteAverage'] as num).toDouble(),
      voteCount: value['voteCount'] as int,
    )).toList();
  }

  Future<void> _writeMovies(List<Movie> movies) async {
    final values = movies.map((movie) => {
      'adult': movie.adult,
      'backdropPath': movie.backdropPath,
      'genreIds': movie.genreIds,
      'id': movie.id,
      'originalLanguage': movie.originalLanguage,
      'originalTitle': movie.originalTitle,
      'overview': movie.overview,
      'popularity': movie.popularity,
      'posterPath': movie.posterPath,
      'releaseDate': movie.releaseDate.toIso8601String(),
      'title': movie.title,
      'video': movie.video,
      'voteAverage': movie.voteAverage,
      'voteCount': movie.voteCount,
    }).toList();
    await (await _preferences).setString(_key, jsonEncode(values));
  }

  @override
  Future<bool> isMovieFavorite(int movieId) async =>
      (await _readMovies()).any((movie) => movie.id == movieId);

  @override
  Future<void> toggleFavorite(Movie movie) async {
    final movies = await _readMovies();
    if (movies.any((saved) => saved.id == movie.id)) {
      movies.removeWhere((saved) => saved.id == movie.id);
    } else {
      movies.add(movie);
    }
    await _writeMovies(movies);
  }

  @override
  Future<List<Movie>> loadMovies({int limit = 10, int offset = 0}) async {
    final movies = await _readMovies();
    if (offset >= movies.length) return [];
    return movies.skip(offset).take(limit).toList();
  }
}
