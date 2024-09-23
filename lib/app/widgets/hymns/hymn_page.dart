import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/custom_lists/add_hymn_to_custom_list_dialog.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/hymns/favorite_icon.dart';
import 'package:spiewnik_pielgrzyma/models/hymn.dart';

class HymnPage extends StatelessWidget {
  final Hymn hymn;

  const HymnPage({super.key, required this.hymn});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        initialIndex: 1,
        child: Scaffold(
            appBar: AppBar(
                title: Text(hymn.fullTitle),
                actions: <Widget>[
                  FavoriteIconWidget(hymn: hymn),
                  IconButton(
                      onPressed: () => showDialogWithCustomListsToAddTheHymnTo(
                          context, hymn),
                      icon: const Icon(Icons.add))
                ],
                bottom: const TabBar(
                  tabs: [
                    Tab(text: "Tekst+akordy"),
                    Tab(text: "Tekst"),
                    Tab(text: "Nuty")
                  ],
                )),
            body: TabBarView(children: [
              Center(child: Text("Cierpliwości! 😉")),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                    children: hymn.text!
                        .map((line) => Text(line,
                            textAlign: TextAlign.left,
                            style: Theme.of(context).textTheme.bodyLarge))
                        .toList()),
              ),
              Text("Nuty")
            ])));
  }
}
