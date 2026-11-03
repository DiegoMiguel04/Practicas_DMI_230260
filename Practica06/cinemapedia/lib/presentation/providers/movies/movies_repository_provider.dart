import 'package:cinemapedia/infrastructure/datasources/moviedb_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cinemapedia/infrastructure/repositories/movie_repository_impl.dart';
import 'package:cinemapedia/presentation/providers/country_provider.dart';

// Este repositorio es inmutable
final movieRepositoryProvider = Provider((ref) {
  final country = ref.watch(movieCountryProvider);
  return MovieRepositoryImpl(MoviedbDatasource(language: country.language, region: country.code));
});


