import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/provider.dart';
import 'package:spiewnik_pielgrzyma/app/providers/home/theme.dart';
import 'package:spiewnik_pielgrzyma/app/providers/hymns/provider.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/home/home.dart';
import 'package:spiewnik_pielgrzyma/infra/objectbox.dart';
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

    return MaterialApp(
        title: 'Śpiewnik Pielgrzyma',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: themeProvider.themeMode ?? ThemeMode.system,
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
