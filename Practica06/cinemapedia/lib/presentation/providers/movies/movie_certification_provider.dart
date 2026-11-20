import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cinemapedia/presentation/providers/movies/movies_repository_provider.dart';

/// Clasificación de edad de una película en el país del idioma elegido.
/// Depende de [movieRepositoryProvider], así que se vuelve a pedir sola
/// cuando cambia el idioma.
final movieCertificationProvider = FutureProvider.autoDispose.family<String, int>((ref, int movieId) {
  final movieRepository = ref.watch( movieRepositoryProvider );
  return movieRepository.getCertification( movieId );
});
