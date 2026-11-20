import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cinemapedia/config/i18n/app_language.dart';
import 'package:cinemapedia/presentation/providers/settings/shared_preferences_provider.dart';

const _languageKey = 'language';

/// Idioma actual de la app (textos + datos de la API).
/// Al cambiarlo se reconstruyen los repositorios y se recargan las películas.
///
/// Arranca con el último idioma que eligió la persona (se guarda en el
/// dispositivo); si todavía no eligió ninguno, usa español (MX).
final languageProvider = StateProvider<AppLanguage>((ref) {
  final saved = ref.watch( sharedPreferencesProvider ).getString( _languageKey );

  return AppLanguages.all.firstWhere(
    (language) => language.apiCode == saved,
    orElse: () => AppLanguages.defaultLanguage,
  );
});

/// Cambia el idioma y lo guarda para recordarlo la próxima vez que se abra la app.
void changeLanguage( WidgetRef ref, AppLanguage language ) {
  ref.read( languageProvider.notifier ).state = language;
  ref.read( sharedPreferencesProvider ).setString( _languageKey, language.apiCode );
}
