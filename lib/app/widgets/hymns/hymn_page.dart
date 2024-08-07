import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/custom_lists/add_hymn_to_custom_list_dialog.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/hymns/favorite_icon.dart';
import 'package:spiewnik_pielgrzyma/models/hymn.dart';

class HymnPage extends StatelessWidget {
  final Hymn hymn;

  const HymnPage({super.key, required this.hymn});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(hymn.fullTitle),
          actions: <Widget>[
            FavoriteIconWidget(hymn: hymn),
            IconButton(
                onPressed: () =>
                    showDialogWithCustomListsToAddTheHymnTo(context, hymn),
                icon: const Icon(Icons.add))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: hymn.text!
                .map((line) => Text(line,
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.bodyLarge))
                .toList(),
          ),
        ));
  }
}
