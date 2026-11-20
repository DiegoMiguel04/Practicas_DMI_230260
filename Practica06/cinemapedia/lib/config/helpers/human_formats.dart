import 'package:intl/intl.dart';


class HumanFormats {


  static String number( double number, [ int decimals = 0 ] ) {

    return NumberFormat.compactCurrency(
      decimalDigits: decimals,
      symbol: '',
      locale: 'en'
    ).format(number);
  }

  /// Fecha corta en el idioma indicado (es, en, de, zh, ar).
  static String shortDate( DateTime date, [ String languageCode = 'es' ] ) {
    final format = DateFormat.yMMMEd(languageCode);
    return format.format(date);
  }

  /// Día de hoy para la etiqueta de "En cines", p. ej. "Domingo 1".
  static String today( [ String languageCode = 'es' ] ) {
    final text = DateFormat('EEEE d', languageCode).format(DateTime.now());
    return toBeginningOfSentenceCase(text, languageCode) ?? text;
  }

}