import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:spiewnik_pielgrzyma/app/providers/hymn_pdf.dart';
import 'package:spiewnik_pielgrzyma/app/providers/hymns/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'package:spiewnik_pielgrzyma/app/widgets/custom_lists/add_hymn_to_custom_list_dialog.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/hymns/favorite_icon.dart';
import 'package:spiewnik_pielgrzyma/models/hymn.dart';

class HymnPage extends StatelessWidget {
  final HymnsListProvider provider = GetIt.I<HymnsListProvider>();
  final HymnPdfProvider hymnPdfProvider = GetIt.I<HymnPdfProvider>();
  final int hymnId;

  HymnPage({super.key, required this.hymnId});

  @override
  Widget build(BuildContext context) {
    final Hymn hymn = provider.getHymn(hymnId);

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
                    if (!kIsWeb) Tab(text: "Nuty"),
                  ],
                )),
            body: TabBarView(children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SelectableText(hymn.text.join('\n\n'),
                    style: Theme.of(context).textTheme.bodyLarge),
              ),
              if (!kIsWeb)
                FutureBuilder(
                  future: hymnPdfProvider.getHymnPdfFile(hymn),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return SfPdfViewer.memory(snapshot.data!);
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(snapshot.error.toString()),
                      );
                    } else {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(hymnPdfProvider.loadingMessage),
                          ],
                        ),
                      );
                    }
                  },
                )
            ])));
  }
}
