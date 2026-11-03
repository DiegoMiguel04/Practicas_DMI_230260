


import 'package:flutter/material.dart';

class AppTheme {


  ThemeData getTheme() {
    final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF7656F6), brightness: Brightness.dark,
      surface: const Color(0xFF11111A));
    return ThemeData(useMaterial3: true, colorScheme: scheme, scaffoldBackgroundColor: const Color(0xFF0B0B11),
      appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF0B0B11), surfaceTintColor: Colors.transparent),
      cardTheme: CardThemeData(color: const Color(0xFF171722), elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: const Color(0xFF11111A),
        selectedItemColor: scheme.primary, unselectedItemColor: Colors.white54, type: BottomNavigationBarType.fixed));
  }


}
