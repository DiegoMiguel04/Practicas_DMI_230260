import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:toktik_app/config/theme/season_theme.dart';
import 'package:toktik_app/presentation/providers/discover_provider.dart';
import 'package:toktik_app/presentation/providers/for_you_provider.dart';
import 'package:toktik_app/presentation/screens/discover/discover_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.black,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarDividerColor: Colors.black,
    systemNavigationBarContrastEnforced: false,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SeasonProvider()),
        ChangeNotifierProvider(
          lazy: false,
          create: (_) => ForYouProvider()..loadNextPage(),
        ),
        ChangeNotifierProvider(create: (_) => DiscoverProvider()),
      ],
      child: Consumer<SeasonProvider>(builder: (context, season, _) => MaterialApp(
        title: 'TokTik',
        debugShowCheckedModeBanner: false,
        theme: season.season.theme,
        home: const DiscoverScreen()
      )),
    );
  }
}
