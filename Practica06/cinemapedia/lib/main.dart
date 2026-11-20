import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:cinemapedia/config/router/app_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:cinemapedia/config/i18n/app_language.dart';
import 'package:cinemapedia/config/i18n/app_strings.dart';
import 'package:cinemapedia/config/theme/app_theme.dart';
import 'package:cinemapedia/presentation/providers/language/language_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cinemapedia/presentation/providers/settings/shared_preferences_provider.dart';

Future<void> main() async{

  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  // Formatos de fecha de todos los idiomas (es, en, de, zh, ar)
  await initializeDateFormatting();

  // Preferencias guardadas (aquí se recuerda el idioma elegido)
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue( prefs ),
      ],
      child: const MainApp(),
    )
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // Cuando cambia el idioma se reconstruye toda la app
    final language = ref.watch( languageProvider );

    return MaterialApp.router(
      title: 'Cinemapedia',
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: AppTheme().getTheme(),
      themeMode: ThemeMode.dark,

      // El diseño no se voltea en árabe: siempre de izquierda a derecha
      builder: (context, child) => Directionality(
        textDirection: TextDirection.ltr,
        child: child!,
      ),

      locale: language.locale,
      supportedLocales: [ for (final l in AppLanguages.all) l.locale ],
      localizationsDelegates: const [
        AppStrings.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
