



import 'package:cinemapedia/config/constants/environment.dart';
import 'package:cinemapedia/config/helpers/media_id.dart';
import 'package:cinemapedia/domain/datasources/actors_datasource.dart';
import 'package:cinemapedia/domain/entities/actor.dart';
import 'package:cinemapedia/infrastructure/mappers/actor_mapper.dart';
import 'package:cinemapedia/infrastructure/models/moviedb/credits_response.dart';
import 'package:dio/dio.dart';

class ActorMovieDbDatasource extends ActorsDatasource {

  final String language;

  ActorMovieDbDatasource({ this.language = 'es-MX' });

  late final Dio dio = Dio(BaseOptions(
    baseUrl: 'https://api.themoviedb.org/3',
    queryParameters: {
      'api_key': Environment.theMovieDbKey,
      'language': language
    }
  ));

  @override
  Future<List<Actor>> getActorsByMovie(String movieId) async{
    
    // Las series llegan con id negativo (ver MediaId)
    final id = int.tryParse( movieId );
    final path = ( id != null && MediaId.isSeries( id ) )
        ? '/tv/${ MediaId.tmdbId( id ) }/credits'
        : '/movie/$movieId/credits';

    final response = await dio.get( path );

    final castResponse = CreditsResponse.fromJson(response.data);

    List<Actor> actors = castResponse.cast.map(
      (cast) => ActorMapper.castToEntity(cast)
    ).toList();
    
    return actors;
  }

}