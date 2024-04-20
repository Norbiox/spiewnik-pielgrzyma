import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiewnik_pielgrzyma/custom_lists/repository/list_of_lists.dart';
import 'package:spiewnik_pielgrzyma/database.dart';
import 'package:spiewnik_pielgrzyma/favorites/repository/abstract.dart';
import 'package:spiewnik_pielgrzyma/favorites/repository/shared_preferences.dart';
import 'package:spiewnik_pielgrzyma/home.dart';
import 'package:spiewnik_pielgrzyma/hymns/lib/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

final getIt = GetIt.instance;

void setup() {
  WidgetsFlutterBinding.ensureInitialized();
  getIt.registerSingletonAsync<Database>(() async {
    var factory = databaseFactory;
    return await factory.openDatabase('db.sqlite', options: databaseOptions);
  });
  getIt.registerSingleton<HymnsListProvider>(HymnsListProvider());
  getIt.registerSingletonAsync<SharedPreferences>(
      () => SharedPreferences.getInstance());
  getIt.registerSingletonWithDependencies<FavoritesRepository>(
      () => SharedPreferencesFavoritesRepository(
          getIt<SharedPreferences>(), getIt<HymnsListProvider>()),
      dependsOn: [SharedPreferences]);
  getIt.registerSingletonWithDependencies<CustomListsRepository>(
      () => CustomListsRepository(
          getIt<SharedPreferences>(), getIt<HymnsListProvider>()),
      dependsOn: [SharedPreferences]);
}

void main() {
  setup();
  runApp(const MyApp());
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
