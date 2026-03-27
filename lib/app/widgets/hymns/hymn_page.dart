import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/app/providers/hymn_pdf.dart';
import 'package:spiewnik_pielgrzyma/app/providers/hymns/provider.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/custom_lists/add_hymn_to_custom_list_dialog.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/hymns/favorite_icon.dart';
import 'package:spiewnik_pielgrzyma/models/hymn.dart';
import 'package:spiewnik_pielgrzyma/settings/font_size.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:watch_it/watch_it.dart';

class HymnPage extends WatchingStatefulWidget {
  final int hymnId;

  const HymnPage({super.key, required this.hymnId});

  @override
  State<HymnPage> createState() => _HymnPageState();
}

class _HymnPageState extends State<HymnPage> {
  final HymnsListProvider provider = GetIt.I<HymnsListProvider>();
  final HymnPdfProvider hymnPdfProvider = GetIt.I<HymnPdfProvider>();
  final FontSizeProvider fontSizeProvider = GetIt.I<FontSizeProvider>();

  double _scaleAtStart = 1.0;

  void _onScaleStart(ScaleStartDetails details) {
    _scaleAtStart = fontSizeProvider.scale;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount < 2) return;
    fontSizeProvider.setScale(_scaleAtStart * details.scale);
  }

  @override
  Widget build(BuildContext context) {
    watch(fontSizeProvider);
    final Hymn hymn = provider.getHymn(widget.hymnId);
    final baseFontSize =
        Theme.of(context).textTheme.bodyLarge?.fontSize ?? 16.0;
    final scaledSize = fontSizeProvider.scaledFontSize(baseFontSize);

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
              GestureDetector(
                onScaleStart: _onScaleStart,
                onScaleUpdate: _onScaleUpdate,
                child: SelectionArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(hymn.text.join('\n\n'),
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontSize: scaledSize)),
                  ),
                ),
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
