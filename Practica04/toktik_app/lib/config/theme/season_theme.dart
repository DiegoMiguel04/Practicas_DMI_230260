import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

enum AppSeason { normal, octubre, diciembre, febrero }

extension AppSeasonStyle on AppSeason {
  String get label => switch (this) {
    AppSeason.normal => 'Default',
    AppSeason.octubre => 'Octubre',
    AppSeason.diciembre => 'Diciembre',
    AppSeason.febrero => 'Febrero',
  };
  String get festivalName => switch (this) {
    AppSeason.normal => '',
    AppSeason.octubre => 'Halloween',
    AppSeason.diciembre => 'Navidad',
    AppSeason.febrero => 'Amor y Amistad',
  };
  bool get isSeasonal => this != AppSeason.normal;
  String? get likeAsset => isSeasonal ? 'assets/${name}_like_icon.png' : null;
  String? get bandAsset => isSeasonal ? 'assets/${name}_band_icon.png' : null;
  String get fontFamily => switch (this) {
    AppSeason.normal => '',
    AppSeason.octubre => 'sans-serif-condensed',
    AppSeason.diciembre => 'serif',
    AppSeason.febrero => 'cursive',
  };
  Color get accent => switch (this) {
    AppSeason.normal => ThemeData.dark(useMaterial3: true).colorScheme.primary,
    AppSeason.octubre => const Color(0xFFB85CFF),
    AppSeason.diciembre => const Color(0xFF36D985),
    AppSeason.febrero => const Color(0xFFFF628F),
  };
  Color get background => this == AppSeason.normal
      ? ThemeData.dark(useMaterial3: true).scaffoldBackgroundColor
      : const Color(0xFF09090D);
  Color get surface => const Color(0xFF17171F);
  ThemeData get theme {
    if (this == AppSeason.normal) return ThemeData.dark(useMaterial3: true);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(seedColor: accent, brightness: Brightness.dark, surface: surface),
      textTheme: const TextTheme().apply(bodyColor: Colors.white, displayColor: Colors.white),
    );
  }
}

class SeasonProvider extends ChangeNotifier {
  AppSeason _season = AppSeason.octubre;
  AppSeason get season => _season;

  SeasonProvider() { _restore(); }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('app_season');
    if (value == null) return;
    _season = AppSeason.values.firstWhere((item) => item.name == value, orElse: () => AppSeason.octubre);
    notifyListeners();
    try {
      await const MethodChannel('toktik/app_icon').invokeMethod<void>('setSeason', _season.name);
    } on PlatformException {
      // Icon switching is implemented by supported native launchers.
    } on MissingPluginException {
      // Web and desktop use the in-app theme without a native launcher icon.
    }
  }

  Future<void> select(AppSeason value) async {
    if (_season == value) return;
    _season = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_season', value.name);
  }
}
