import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/provider.dart';
import 'package:spiewnik_pielgrzyma/app/providers/hymns/provider.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/home.dart';
import 'package:spiewnik_pielgrzyma/infra/objectbox.dart';

final getIt = GetIt.instance;

void setup() {
  WidgetsFlutterBinding.ensureInitialized();
  getIt.registerSingletonAsync<ObjectBox>(() => ObjectBox.create());
  getIt.registerSingletonWithDependencies<HymnsListProvider>(
      () => HymnsListProvider(getIt<ObjectBox>().hymnBox),
      dependsOn: [ObjectBox]);
  getIt.registerSingletonWithDependencies<CustomListProvider>(
      () => CustomListProvider(getIt<ObjectBox>().customListBox),
      dependsOn: [ObjectBox]);
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
