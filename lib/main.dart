import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/provider.dart';
import 'package:spiewnik_pielgrzyma/settings/theme.dart';
import 'package:spiewnik_pielgrzyma/app/providers/hymn_pdf.dart';
import 'package:spiewnik_pielgrzyma/app/providers/hymns/provider.dart';
import 'package:spiewnik_pielgrzyma/infra/db.dart';
import 'package:spiewnik_pielgrzyma/models/hymn.dart';
import 'package:spiewnik_pielgrzyma/router.dart';
import 'package:watch_it/watch_it.dart';

final getIt = GetIt.instance;

void setup() {
  WidgetsFlutterBinding.ensureInitialized();
  getIt.registerSingleton<ThemeProvider>(ThemeProvider());
  getIt.registerSingletonAsync<SharedPreferences>(
      () => SharedPreferences.getInstance());
  getIt.registerSingletonAsync<List<Hymn>>(
    () async => loadHymns(getIt.get<SharedPreferences>()),
    dependsOn: [SharedPreferences],
  );
  getIt.registerSingletonWithDependencies<HymnsListProvider>(
      () => HymnsListProvider(
          getIt.get<SharedPreferences>(), getIt.get<List<Hymn>>()),
      dependsOn: [SharedPreferences, List<Hymn>]);
  getIt.registerSingletonWithDependencies<CustomListProvider>(
      () => CustomListProvider(getIt.get<SharedPreferences>()),
      dependsOn: [SharedPreferences]);
  getIt.registerSingletonAsync<HymnPdfProvider>(
    () => hymnPdfProviderFactory(),
  );
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
                  return const Center(child: CircularProgressIndicator());
                }
              });
        });
  }
}
