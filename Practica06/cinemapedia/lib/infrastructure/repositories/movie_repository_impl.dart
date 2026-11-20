import 'package:cinemapedia/domain/datasources/movies_datasource.dart';
import 'package:cinemapedia/domain/entities/entities.dart';
import 'package:cinemapedia/domain/repositories/movies_repository.dart';


class MovieRepositoryImpl extends MoviesRepository {

  final MoviesDatasource datasource;
  MovieRepositoryImpl(this.datasource);

  
  @override
  Future<List<Movie>> getNowPlaying({int page = 1}) {
    return datasource.getNowPlaying(page: page);
  }
  
  @override
  Future<List<Movie>> getPopular({int page = 1}) {
    return datasource.getPopular(page: page);
  }
  
  @override
  Future<List<Movie>> getTopRated({int page = 1}) {
    return datasource.getTopRated(page: page);
  }
  
  @override
  Future<List<Movie>> getUpcoming({int page = 1}) {
    return datasource.getUpcoming(page: page);
  }
  
  @override
  Future<Movie> getMovieById(String id) {
    return datasource.getMovieById(id);
  }
  
  @override
  Future<List<Movie>> searchMovies(String query) {
    return datasource.searchMovies(query);
  }
  
  @override
  Future<List<Movie>> getSimilarMovies(int movieId) {
    return datasource.getSimilarMovies(movieId);
  }
  
  @override
  Future<List<Video>> getYoutubeVideosById(int movieId) {
    return datasource.getYoutubeVideosById(movieId);
  }

  @override
  Future<String> getCertification(int movieId) {
    return datasource.getCertification(movieId);
  }

  // ---- Series

  @override
  Future<List<Movie>> getSeriesOnTheAir({int page = 1}) {
    return datasource.getSeriesOnTheAir(page: page);
  }

  @override
  Future<List<Movie>> getSeriesAiringToday({int page = 1}) {
    return datasource.getSeriesAiringToday(page: page);
  }

  @override
  Future<List<Movie>> getSeriesPopular({int page = 1}) {
    return datasource.getSeriesPopular(page: page);
  }

  @override
  Future<List<Movie>> getSeriesTopRated({int page = 1}) {
    return datasource.getSeriesTopRated(page: page);
  }

  @override
  Future<List<Movie>> searchSeries(String query) {
    return datasource.searchSeries(query);
  }

}
