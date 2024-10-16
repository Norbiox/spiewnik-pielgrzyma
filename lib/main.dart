import 'dart:io';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/provider.dart';
import 'package:spiewnik_pielgrzyma/app/providers/home/theme.dart';
import 'package:spiewnik_pielgrzyma/app/providers/hymns/provider.dart';
import 'package:spiewnik_pielgrzyma/infra/db.dart';
import 'package:spiewnik_pielgrzyma/infra/objectbox.dart';
import 'package:spiewnik_pielgrzyma/router.dart';
import 'package:watch_it/watch_it.dart';

final getIt = GetIt.instance;

void setup() {
  WidgetsFlutterBinding.ensureInitialized();
  getIt.registerSingleton<ThemeProvider>(ThemeProvider());
  getIt.registerSingletonAsync<ObjectBox>(() => ObjectBox.create());
  getIt.registerSingletonWithDependencies<HymnsListProvider>(
      () => HymnsListProvider(getIt<ObjectBox>().hymnBox),
      dependsOn: [ObjectBox]);
  getIt.registerSingletonWithDependencies<CustomListProvider>(
      () => CustomListProvider(getIt<ObjectBox>().customListBox),
      dependsOn: [ObjectBox]);
  getIt.registerSingletonAsync<SharedPreferences>(
      () => SharedPreferences.getInstance());
  getIt.registerSingletonAsync<Directory>(
      () => getApplicationDocumentsDirectory());
  getIt.registerSingletonAsync<Isar>(() async {
    return await initIsar(getIt<Directory>(), getIt<SharedPreferences>());
  }, dependsOn: [Directory, SharedPreferences]);
}

void main() {
  setup();
  runApp(const MyApp());
}

class MyApp extends WatchingWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider = GetIt.I<ThemeProvider>();
    watch(themeProvider);

    return MaterialApp.router(
        title: 'Śpiewnik Pielgrzyma',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: themeProvider.themeMode ?? ThemeMode.system,
        routerConfig: router,
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
