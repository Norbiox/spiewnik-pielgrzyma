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

class HymnPage extends StatefulWidget {
  final int hymnId;

  const HymnPage({super.key, required this.hymnId});

  @override
  State<HymnPage> createState() => _HymnPageState();
}

class _HymnPageState extends State<HymnPage> {
  final HymnsListProvider provider = GetIt.I<HymnsListProvider>();
  final HymnPdfProvider hymnPdfProvider = GetIt.I<HymnPdfProvider>();

  late final Hymn _hymn;
  late final Future<Uint8List> _pdfFuture;

  @override
  void initState() {
    super.initState();
    _hymn = provider.getHymn(widget.hymnId);
    _pdfFuture = hymnPdfProvider.getHymnPdfFile(_hymn);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        initialIndex: 0,
        child: Scaffold(
            appBar: AppBar(
                title: Text(_hymn.fullTitle),
                actions: <Widget>[
                  FavoriteIconWidget(hymn: _hymn),
                  IconButton(
                      onPressed: () => showDialogWithCustomListsToAddTheHymnTo(
                          context, _hymn),
                      icon: const Icon(Icons.add))
                ],
                bottom: const TabBar(
                  tabs: [
                    Tab(text: "Tekst"),
                    if (!kIsWeb) Tab(text: "Nuty"),
                  ],
                )),
            body: TabBarView(children: [
              _HymnTextTab(hymn: _hymn),
              if (!kIsWeb)
                FutureBuilder(
                  future: _pdfFuture,
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

class _HymnTextTab extends WatchingStatefulWidget {
  final Hymn hymn;

  const _HymnTextTab({required this.hymn});

  @override
  State<_HymnTextTab> createState() => _HymnTextTabState();
}

class _HymnTextTabState extends State<_HymnTextTab> {
  final FontSizeProvider _fontSizeProvider = GetIt.I<FontSizeProvider>();

  double _scaleAtStart = 1.0;
  double _visualScale = 1.0;
  bool _isPinching = false;

  void _onScaleStart(ScaleStartDetails details) {
    _scaleAtStart = _fontSizeProvider.scale;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount < 2) return;
    setState(() {
      _isPinching = true;
      _visualScale = details.scale;
    });
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (!_isPinching) return;
    final newScale = _scaleAtStart * _visualScale;
    setState(() {
      _isPinching = false;
      _visualScale = 1.0;
    });
    _fontSizeProvider.setScale(newScale);
  }

  @override
  Widget build(BuildContext context) {
    watch(_fontSizeProvider);
    final baseFontSize =
        Theme.of(context).textTheme.bodyLarge?.fontSize ?? 16.0;
    final scaledSize = _fontSizeProvider.scaledFontSize(baseFontSize);

    return GestureDetector(
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      onScaleEnd: _onScaleEnd,
      child: Transform.scale(
        scale: _isPinching ? _visualScale : 1.0,
        child: SelectionArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: Text(widget.hymn.text.join('\n\n'),
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontSize: scaledSize)),
          ),
        ),
      ),
    );
  }
}
