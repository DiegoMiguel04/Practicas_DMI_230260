import 'package:cinemapedia/config/helpers/media_id.dart';
import 'package:cinemapedia/domain/entities/movie.dart';

/// Convierte las series de The Movie DB al mismo [Movie] que usa toda la app,
/// con el id en negativo (ver [MediaId]).
class TvMapper {

  static const _imageBase = 'https://image.tmdb.org/t/p/w500';
  static const _noBackdrop = 'https://sd.keepcalms.com/i-w600/keep-calm-poster-not-found.jpg';
  static const _noPoster = 'https://www.movienewz.com/img/films/poster-holder.jpg';

  static String _image( dynamic path, String fallback ) {
    final value = ( path as String? ) ?? '';
    return value.isEmpty ? fallback : '$_imageBase$value';
  }

  static DateTime _date( dynamic value ) {
    final text = ( value as String? ) ?? '';
    return DateTime.tryParse( text ) ?? DateTime.now();
  }

  /// Respuesta de una lista (/tv/popular, /tv/on_the_air, /search/tv...).
  static List<Movie> listFromResponse( Map<String, dynamic> json ) {
    final results = ( json['results'] as List? ) ?? const [];

    return results
        .where(( item ) => (( item['poster_path'] as String? ) ?? '').isNotEmpty )
        .map(( item ) => listItemToEntity( item as Map<String, dynamic> ))
        .toList();
  }

  static Movie listItemToEntity( Map<String, dynamic> json ) => Movie(
    adult: json['adult'] ?? false,
    backdropPath: _image( json['backdrop_path'], _noBackdrop ),
    genreIds: (( json['genre_ids'] as List? ) ?? const []).map(( e ) => e.toString() ).toList(),
    id: MediaId.fromSeries( json['id'] as int ),
    originalLanguage: json['original_language'] ?? '',
    originalTitle: json['original_name'] ?? '',
    overview: json['overview'] ?? '',
    popularity: ( json['popularity'] as num? )?.toDouble() ?? 0,
    posterPath: _image( json['poster_path'], _noPoster ),
    releaseDate: _date( json['first_air_date'] ),
    title: json['name'] ?? 'No Title',
    video: false,
    voteAverage: ( json['vote_average'] as num? )?.toDouble() ?? 0,
    voteCount: json['vote_count'] ?? 0,
  );

  /// Detalle de una serie (/tv/{id}).
  static Movie detailsToEntity( Map<String, dynamic> json ) => Movie(
    adult: json['adult'] ?? false,
    backdropPath: _image( json['backdrop_path'], _noBackdrop ),
    genreIds: (( json['genres'] as List? ) ?? const []).map(( g ) => g['name'].toString() ).toList(),
    id: MediaId.fromSeries( json['id'] as int ),
    originalLanguage: json['original_language'] ?? '',
    originalTitle: json['original_name'] ?? '',
    overview: json['overview'] ?? '',
    popularity: ( json['popularity'] as num? )?.toDouble() ?? 0,
    posterPath: _image( json['poster_path'], _noBackdrop ),
    releaseDate: _date( json['first_air_date'] ),
    title: json['name'] ?? 'No Title',
    video: false,
    voteAverage: ( json['vote_average'] as num? )?.toDouble() ?? 0,
    voteCount: json['vote_count'] ?? 0,
  );
}
