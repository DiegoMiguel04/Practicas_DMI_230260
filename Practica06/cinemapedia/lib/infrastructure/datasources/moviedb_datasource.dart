import 'package:dio/dio.dart';

import 'package:cinemapedia/config/constants/environment.dart';
import 'package:cinemapedia/config/helpers/age_rating.dart';
import 'package:cinemapedia/config/helpers/media_id.dart';
import 'package:cinemapedia/domain/datasources/movies_datasource.dart';

import 'package:cinemapedia/infrastructure/models/models.dart';
import 'package:cinemapedia/infrastructure/mappers/mappers.dart';

import 'package:cinemapedia/domain/entities/entities.dart';


class MoviedbDatasource extends MoviesDatasource {

  /// Código de idioma de The Movie DB, p. ej. 'es-MX', 'en-US', 'de-DE'...
  final String language;

  MoviedbDatasource({ this.language = 'es-MX' });

  late final Dio dio = Dio(BaseOptions(
    baseUrl: 'https://api.themoviedb.org/3',
    queryParameters: {
      'api_key': Environment.theMovieDbKey,
      'language': language
    }
  ));

  List<Movie> _jsonToMovies( Map<String,dynamic> json ) {

    final movieDBResponse = MovieDbResponse.fromJson(json);

    final List<Movie> movies = movieDBResponse.results
    .where((moviedb) => moviedb.posterPath != 'no-poster' )
    .map(
      (moviedb) => MovieMapper.movieDBToEntity(moviedb)
    ).toList();

    return movies;

  }


  // ------------------------------------------------------------------
  //  Respaldo en inglés
  //
  //  Cuando una película no tiene traducción en el idioma elegido, The Movie DB
  //  devuelve el título ORIGINAL (p. ej. en español) y la sinopsis vacía.
  //  En ese caso se pide también la versión en inglés y se usa como respaldo.
  // ------------------------------------------------------------------

  String get _languageCode => language.split('-').first;

  bool _needsTitleFallback( Movie m ) =>
      m.title == m.originalTitle &&
      m.originalLanguage != _languageCode &&
      m.originalLanguage != 'en';

  bool _needsOverviewFallback( Movie m ) => m.overview.trim().isEmpty;

  bool _needsFallback( Movie m ) =>
      _needsTitleFallback(m) || _needsOverviewFallback(m);

  Movie _mergeEnglish( Movie m, Movie en ) => Movie(
    adult: m.adult,
    backdropPath: m.backdropPath,
    genreIds: m.genreIds,
    id: m.id,
    originalLanguage: m.originalLanguage,
    originalTitle: m.originalTitle,
    overview: ( _needsOverviewFallback(m) && en.overview.trim().isNotEmpty ) ? en.overview : m.overview,
    popularity: m.popularity,
    posterPath: m.posterPath,
    releaseDate: m.releaseDate,
    title: ( _needsTitleFallback(m) && en.title.trim().isNotEmpty ) ? en.title : m.title,
    video: m.video,
    voteAverage: m.voteAverage,
    voteCount: m.voteCount,
  );

  Future<List<Movie>> _withEnglishFallback(
    List<Movie> movies,
    String path,
    [ Map<String, dynamic>? params ]
  ) async {

    if ( language.startsWith('en') || !movies.any(_needsFallback) ) return movies;

    try {
      final response = await dio.get( path, queryParameters: {
        ...?params,
        'language': 'en-US',
      });

      final english = { for ( final m in _jsonToMovies(response.data) ) m.id: m };

      return movies.map((m) {
        final en = english[m.id];
        if ( en == null || !_needsFallback(m) ) return m;
        return _mergeEnglish(m, en);
      }).toList();

    } catch (_) {
      // Si falla el respaldo se deja lo que ya se tenía
      return movies;
    }
  }


  @override
  Future<List<Movie>> getNowPlaying({int page = 1}) async {
    
    final response = await dio.get('/movie/now_playing', 
      queryParameters: {
        'page': page
      }
    );
    
    final movies = _jsonToMovies(response.data);
    return _withEnglishFallback(movies, '/movie/now_playing', { 'page': page });
  }
  
  @override
  Future<List<Movie>> getPopular({int page = 1}) async {
     
    final response = await dio.get('/movie/popular', 
      queryParameters: {
        'page': page
      }
    );

    final movies = _jsonToMovies(response.data);
    return _withEnglishFallback(movies, '/movie/popular', { 'page': page });    
  }

  @override
  Future<List<Movie>> getTopRated({int page = 1}) async {
     
    final response = await dio.get('/movie/top_rated', 
      queryParameters: {
        'page': page
      }
    );

    final movies = _jsonToMovies(response.data);
    return _withEnglishFallback(movies, '/movie/top_rated', { 'page': page });    
  }

   @override
  Future<List<Movie>> getUpcoming({int page = 1}) async {
     
    final response = await dio.get('/movie/upcoming', 
      queryParameters: {
        'page': page
      }
    );

    final movies = _jsonToMovies(response.data);
    return _withEnglishFallback(movies, '/movie/upcoming', { 'page': page });    
  }


  @override
  Future<Movie> getMovieById( String id ) async {

    // Las series llegan con id negativo (ver MediaId)
    final numericId = int.tryParse( id );
    if ( numericId != null && MediaId.isSeries( numericId ) ) {
      return _getSeriesById( MediaId.tmdbId( numericId ) );
    }

    final response = await dio.get('/movie/$id');
    if ( response.statusCode != 200 ) throw Exception('Movie with id: $id not found');
    
    final movieDetails = MovieDetails.fromJson( response.data );
    final Movie movie = MovieMapper.movieDetailsToEntity(movieDetails);

    // Título/sinopsis en inglés si no existen en el idioma elegido
    if ( !language.startsWith('en') && _needsFallback(movie) ) {
      try {
        final enResponse = await dio.get('/movie/$id', queryParameters: { 'language': 'en-US' });
        final english = MovieMapper.movieDetailsToEntity( MovieDetails.fromJson( enResponse.data ) );
        return _mergeEnglish(movie, english);
      } catch (_) {
        return movie;
      }
    }

    return movie;
  }
  
  @override
  Future<List<Movie>> searchMovies(String query) async{

    if ( query.isEmpty ) return [];

    final response = await dio.get('/search/movie', 
      queryParameters: {
        'query': query
      }
    );

    return _jsonToMovies(response.data);    
  }
  


  @override
  Future<List<Movie>> getSimilarMovies(int movieId) async {

    if ( MediaId.isSeries( movieId ) ) {
      final path = '/tv/${ MediaId.tmdbId( movieId ) }/similar';
      final response = await dio.get( path );
      return _seriesWithEnglishFallback( _jsonToSeries( response.data ), path );
    }

    final response = await dio.get('/movie/$movieId/similar');
    final movies = _jsonToMovies(response.data);
    return _withEnglishFallback(movies, '/movie/$movieId/similar');
  }

  
  @override
  Future<List<Video>> getYoutubeVideosById(int movieId) async {
    // Si no hay tráiler en el idioma elegido, se usa el de inglés o el sin idioma
    final response = await dio.get('/${ MediaId.kind( movieId ) }/${ MediaId.tmdbId( movieId ) }/videos',
      queryParameters: {
        'include_video_language': '${ language.split('-').first },en,null'
      }
    );
    final moviedbVideosReponse = MoviedbVideosResponse.fromJson(response.data);
    final videos = <Video>[];

    for (final moviedbVideo in moviedbVideosReponse.results) {
      if ( moviedbVideo.site == 'YouTube' ) {
        final video = VideoMapper.moviedbVideoToEntity(moviedbVideo);
        videos.add(video);
      }
    }

    return videos;
  }

  // ------------------------------------------------------------------
  //  Clasificación de edad
  //
  //  The Movie DB guarda la clasificación por país:
  //   - Películas: /movie/{id}/release_dates  (MX: A, B, B15, C...  US: PG-13, R...  DE: 0, 6, 12, 16, 18)
  //   - Series:    /tv/{id}/content_ratings   (US: TV-14, TV-MA...)
  //  Se toma la del país del idioma elegido. Si ese país no tiene dato se devuelve ''.
  //
  //  Egipto (EG) no existe en The Movie DB: se usa la clasificación de EE. UU. como
  //  equivalente (General, +12, +16, +18) y "BN" para lo prohibido (ver AgeRatings).
  // ------------------------------------------------------------------
  @override
  Future<String> getCertification(int movieId) async {
    try {
      final country = language.split('-').last.toUpperCase();

      if ( country == 'EG' ) {
        if ( AgeRatings.egyptBannedIds.contains( movieId ) ) return 'BN';
        return AgeRatings.egyptFromUs( await _certificationFor( movieId, 'US' ) );
      }

      return await _certificationFor( movieId, country );
    } catch (_) {
      return '';
    }
  }

  Future<String> _certificationFor( int id, String country ) async {

    final tmdbId = MediaId.tmdbId( id );

    //* Series
    if ( MediaId.isSeries( id ) ) {
      final tvResponse = await dio.get('/tv/$tmdbId/content_ratings');
      final tvResults = (tvResponse.data['results'] as List?) ?? const [];

      for ( final entry in tvResults ) {
        if ( entry['iso_3166_1'] == country ) {
          return ((entry['rating'] as String?) ?? '').trim();
        }
      }
      return '';
    }

    //* Películas: se prefiere la clasificación de estreno en cines (type 3)
    final response = await dio.get('/movie/$tmdbId/release_dates');
    final results = (response.data['results'] as List?) ?? const [];

    for ( final entry in results ) {
      if ( entry['iso_3166_1'] != country ) continue;

      final dates = ((entry['release_dates'] as List?) ?? const [])
          .where((d) => ((d['certification'] as String?) ?? '').trim().isNotEmpty)
          .toList();
      if ( dates.isEmpty ) return '';

      final theatrical = dates.where((d) => d['type'] == 3).toList();
      final chosen = theatrical.isNotEmpty ? theatrical.first : dates.first;
      return (chosen['certification'] as String).trim();
    }

    return '';
  }


  // ------------------------------------------------------------------
  //  Series
  //
  //  Se convierten al mismo Movie que usa toda la app, con el id en negativo
  //  (ver MediaId). Tienen el mismo respaldo en inglés que las películas.
  // ------------------------------------------------------------------

  List<Movie> _jsonToSeries( Map<String, dynamic> json ) => TvMapper.listFromResponse( json );

  Future<List<Movie>> _seriesWithEnglishFallback(
    List<Movie> series,
    String path,
    [ Map<String, dynamic>? params ]
  ) async {

    if ( language.startsWith('en') || !series.any(_needsFallback) ) return series;

    try {
      final response = await dio.get( path, queryParameters: {
        ...?params,
        'language': 'en-US',
      });

      final english = { for ( final m in _jsonToSeries(response.data) ) m.id: m };

      return series.map((m) {
        final en = english[m.id];
        if ( en == null || !_needsFallback(m) ) return m;
        return _mergeEnglish(m, en);
      }).toList();

    } catch (_) {
      return series;
    }
  }

  Future<List<Movie>> _getSeriesList( String path, int page ) async {
    final response = await dio.get( path, queryParameters: { 'page': page } );
    final series = _jsonToSeries( response.data );
    return _seriesWithEnglishFallback( series, path, { 'page': page } );
  }

  Future<Movie> _getSeriesById( int tmdbId ) async {

    final response = await dio.get('/tv/$tmdbId');
    if ( response.statusCode != 200 ) throw Exception('Series with id: $tmdbId not found');

    final series = TvMapper.detailsToEntity( response.data );

    if ( !language.startsWith('en') && _needsFallback(series) ) {
      try {
        final enResponse = await dio.get('/tv/$tmdbId', queryParameters: { 'language': 'en-US' });
        return _mergeEnglish( series, TvMapper.detailsToEntity( enResponse.data ) );
      } catch (_) {
        return series;
      }
    }

    return series;
  }

  @override
  Future<List<Movie>> getSeriesOnTheAir({int page = 1}) => _getSeriesList('/tv/on_the_air', page);

  @override
  Future<List<Movie>> getSeriesAiringToday({int page = 1}) => _getSeriesList('/tv/airing_today', page);

  @override
  Future<List<Movie>> getSeriesPopular({int page = 1}) => _getSeriesList('/tv/popular', page);

  @override
  Future<List<Movie>> getSeriesTopRated({int page = 1}) => _getSeriesList('/tv/top_rated', page);

  @override
  Future<List<Movie>> searchSeries(String query) async {

    if ( query.isEmpty ) return [];

    final response = await dio.get('/search/tv', queryParameters: { 'query': query });

    return _jsonToSeries( response.data );
  }

}
