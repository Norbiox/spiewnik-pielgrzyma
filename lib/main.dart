import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spiewnik_pielgrzyma/hymns/hymns_list.dart';
import 'package:spiewnik_pielgrzyma/hymns/hymns_list_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => HymnsListProvider()),
  ], child: const MyApp()));
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

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          appBar: AppBar(
              title: const Text('Śpiewnik Pielgrzyma'),
              bottom: const TabBar(tabs: [
                Tab(
                  text: 'Lista pieśni',
                ),
                Tab(
                  text: 'Ulubione',
                ),
                Tab(
                  text: 'Twoje listy',
                ),
              ])),
          body: const TabBarView(
            children: [
              HymnsListPage(),
              Text('TODO: ulubione pieśni'),
              Text('TODO: listy użytkownika'),
            ],
          )),
    );
  }
}
