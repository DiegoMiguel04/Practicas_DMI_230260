import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferencias guardadas en el dispositivo (idioma elegido, etc.).
/// Se inicializa en `main()` con `ProviderScope(overrides: [...])`.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider se inicializa en main()');
});
