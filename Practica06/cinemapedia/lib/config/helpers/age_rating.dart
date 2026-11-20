/// Da formato a la clasificación de edad según el país.
class AgeRatings {

  /// Películas o series prohibidas en Egipto (se muestran con la etiqueta "BN").
  /// The Movie DB no marca cuáles están vetadas, así que se agregan a mano:
  /// el id de TMDB de la película, o el id NEGATIVO si es una serie.
  /// Ejemplo: `{ 550, -1399 }`
  static const Set<int> egyptBannedIds = <int>{};

  /// The Movie DB no tiene clasificación de Egipto, así que se usa la de
  /// EE. UU. como equivalente aproximado (no es la clasificación oficial):
  ///
  /// - G, PG  / TV-Y, TV-Y7, TV-G  ->  General
  /// - PG-13  / TV-PG              ->  +12
  /// - R      / TV-14              ->  +16
  /// - NC-17  / TV-MA              ->  +18
  ///
  /// Si no hay dato de EE. UU. devuelve '' (se mostrará "NR").
  static String egyptFromUs( String usCertification ) {
    switch ( usCertification.trim().toUpperCase() ) {
      case 'G':
      case 'PG':
      case 'TV-Y':
      case 'TV-Y7':
      case 'TV-G':
        return 'General';

      case 'PG-13':
      case 'TV-PG':
        return '+12';

      case 'R':
      case 'TV-14':
        return '+16';

      case 'NC-17':
      case 'TV-MA':
        return '+18';

      default:
        return '';
    }
  }

  /// [countryCode]: MX, US, DE, CN, EG.  [certification]: lo que devuelve la API.
  /// Si el país no tiene clasificación se muestra "NR" (sin clasificar).
  static String label( String countryCode, String certification ) {
    final value = certification.trim();
    if ( value.isEmpty ) return 'NR';

    // En Alemania TMDB devuelve solo el número (0, 6, 12, 16, 18): se muestra como FSK
    if ( countryCode == 'DE' && int.tryParse(value) != null ) return 'FSK $value';

    return value;
  }
}
