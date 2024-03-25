import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiewnik_pielgrzyma/favorites/provider.dart';
import 'package:spiewnik_pielgrzyma/favorites/repository/shared_preferences.dart';
import 'package:spiewnik_pielgrzyma/home.dart';
import 'package:spiewnik_pielgrzyma/hymns/hymns_list.dart';
import 'package:spiewnik_pielgrzyma/hymns/hymns_list_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.getInstance().then((value) {
    runApp(MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => HymnsListProvider()),
      ChangeNotifierProvider(
          create: (_) => SharedPreferencesFavoritesRepository(value)),
    ], child: const MyApp()));
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Śpiewnik Pielgrzyma',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}
