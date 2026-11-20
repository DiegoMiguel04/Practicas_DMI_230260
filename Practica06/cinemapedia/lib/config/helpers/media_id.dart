/// Las películas y las series de The Movie DB pueden tener el mismo número de id.
/// Como comparten pantalla de detalle, rutas y favoritos, las series se manejan
/// dentro de la app con el id en NEGATIVO (-id de TMDB). Al hablar con la API
/// se vuelve a usar el id real con [tmdbId].
class MediaId {

  static bool isSeries( int id ) => id < 0;

  /// id con el que se maneja una serie dentro de la app.
  static int fromSeries( int tmdbId ) => -tmdbId.abs();

  /// id real de The Movie DB (siempre positivo).
  static int tmdbId( int id ) => id.abs();

  /// 'tv' o 'movie': parte de la ruta de la API.
  static String kind( int id ) => isSeries(id) ? 'tv' : 'movie';
}
