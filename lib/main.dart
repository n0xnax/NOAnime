import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:noanime_app/pages/home_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  Animate.restartOnHotReload = true;
  WidgetsFlutterBinding.ensureInitialized();

  // Plugin must be initialized before using
  await FlutterDownloader.initialize(
      debug: true, // Set to false to disable logging in production
      ignoreSsl: true // Set to false to enforce SSL (recommended for production)
      );
  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Animate.restartOnHotReload = true;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NOAnime',
      theme: FlexColorScheme.light(scheme: FlexScheme.sakura).toTheme,
      themeMode: ThemeMode.dark,
      darkTheme: FlexColorScheme.dark(scheme: FlexScheme.vesuviusBurn).toTheme,
      home: const HomePage(),
    );
  }
}
