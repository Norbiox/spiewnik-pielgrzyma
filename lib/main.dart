import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiewnik_pielgrzyma/app/providers/hymns/provider.dart';
import 'package:spiewnik_pielgrzyma/domain/custom_lists/repository.dart';
import 'package:spiewnik_pielgrzyma/domain/hymns/repository.dart';
import 'package:spiewnik_pielgrzyma/infra/persistence/in_memory/custom_lists_repository.dart';
import 'package:spiewnik_pielgrzyma/infra/persistence/sqlite/database.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/home.dart';
import 'package:spiewnik_pielgrzyma/infra/persistence/sqlite/hymns_repository.dart';
import 'package:sqflite/sqflite.dart';

final getIt = GetIt.instance;

void setup() {
  WidgetsFlutterBinding.ensureInitialized();
  getIt.registerSingletonAsync<Database>(() async {
    var factory = databaseFactory;
    return await factory.openDatabase('db.sqlite', options: databaseOptions);
  });
  getIt.registerSingletonAsync<HymnRepository>(() async {
    await getIt.isReady<Database>();
    return await SqliteHymnRepository.create(getIt.get<Database>());
  });
  getIt.registerSingletonWithDependencies<HymnsListProvider>(
      () => HymnsListProvider(getIt<HymnRepository>()),
      dependsOn: [HymnRepository]);
  getIt.registerSingletonAsync<CustomListRepository>(() async {
    return InMemoryCustomListRepository();
  });
  getIt.registerSingletonAsync<SharedPreferences>(
      () => SharedPreferences.getInstance());
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
        builder: (context, widget) {
          return FutureBuilder(
              future: getIt.allReady(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  return widget!;
                } else {
                  return Container(color: Colors.white);
                }
              });
        });
  }
}
