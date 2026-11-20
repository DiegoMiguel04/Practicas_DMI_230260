import 'package:cinemapedia/infrastructure/datasources/moviedb_datasource.dart';
import 'package:cinemapedia/presentation/providers/language/language_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cinemapedia/infrastructure/repositories/movie_repository_impl.dart';

// El repositorio se vuelve a crear cuando cambia el idioma, y con él
// todos los providers que dependen de él (películas, detalle, búsqueda...).
final movieRepositoryProvider = Provider((ref) {
  final language = ref.watch( languageProvider );
  return MovieRepositoryImpl( MoviedbDatasource( language: language.apiCode ) );
});
