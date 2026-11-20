import 'package:cinemapedia/infrastructure/datasources/actor_moviedb_datasource.dart';
import 'package:cinemapedia/infrastructure/repositories/actor_repository_impl.dart';
import 'package:cinemapedia/presentation/providers/language/language_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


// Se vuelve a crear cuando cambia el idioma
final actorsRepositoryProvider = Provider((ref) {
  final language = ref.watch( languageProvider );
  return ActorRepositoryImpl( ActorMovieDbDatasource( language: language.apiCode ) );
});
