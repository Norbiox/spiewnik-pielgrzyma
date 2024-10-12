import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'package:spiewnik_pielgrzyma/app/widgets/custom_lists/add_hymn_to_custom_list_dialog.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/hymns/favorite_icon.dart';
import 'package:spiewnik_pielgrzyma/models/hymn.dart';

class HymnPage extends StatelessWidget {
  final Hymn hymn;

  const HymnPage({super.key, required this.hymn});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        initialIndex: 0,
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
                    Tab(text: "Tekst"),
                    Tab(text: "Nuty"),
                  ],
                )),
            body: TabBarView(children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SelectableText(hymn.text!.join('\n'),
                    style: Theme.of(context).textTheme.bodyLarge),
              ),
              SfPdfViewer.asset(hymn.pdfPath),
            ])));
  }
}
