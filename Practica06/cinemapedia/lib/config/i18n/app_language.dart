import 'package:flutter/material.dart';

/// Un idioma disponible en la app.
///
/// - [apiCode]: código que se envía a The Movie DB (`language=`).
/// - [locale]: idioma que usa Flutter para textos, fechas y dirección (RTL).
class AppLanguage {
  final String country;      // MX, US, DE, CN, EG
  final String nativeName;   // Cómo se llama el idioma en su propio idioma
  final Locale locale;

  const AppLanguage({
    required this.country,
    required this.nativeName,
    required this.locale,
  });

  String get code => locale.languageCode;
  String get apiCode => '${locale.languageCode}-${locale.countryCode}';

  /// Texto que se muestra en el menú, p. ej. "MX (Español)".
  String get label => '$country ($nativeName)';
}

class AppLanguages {

  static const mexico = AppLanguage(
    country: 'MX',
    nativeName: 'Español',
    locale: Locale('es', 'MX'),
  );

  static const unitedStates = AppLanguage(
    country: 'US',
    nativeName: 'English',
    locale: Locale('en', 'US'),
  );

  static const germany = AppLanguage(
    country: 'DE',
    nativeName: 'Deutsch',
    locale: Locale('de', 'DE'),
  );

  static const china = AppLanguage(
    country: 'CN',
    nativeName: '中文',
    locale: Locale('zh', 'CN'),
  );

  static const egypt = AppLanguage(
    country: 'EG',
    nativeName: 'العربية',
    locale: Locale('ar', 'EG'),
  );

  /// Orden en el que aparecen en el menú lateral.
  static const all = <AppLanguage>[mexico, unitedStates, germany, china, egypt];

  static const defaultLanguage = mexico;
}
