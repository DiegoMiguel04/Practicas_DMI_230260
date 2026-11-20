import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Qué catálogo se muestra en la app: películas o series.
/// Se cambia desde Configuración, en el menú lateral.
enum CatalogType { movies, series }

final catalogTypeProvider = StateProvider<CatalogType>((ref) => CatalogType.movies);
