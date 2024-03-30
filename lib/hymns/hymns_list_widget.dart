import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/hymns/hymn.dart';
import 'package:spiewnik_pielgrzyma/hymns/hymn_tile_widget.dart';

class HymnsListWidget extends StatefulWidget {
  final List<Hymn> hymnsList;

  const HymnsListWidget({super.key, required this.hymnsList});

  @override
  State<HymnsListWidget> createState() => _HymnsListWidgetState();
}

class _HymnsListWidgetState extends State<HymnsListWidget>
    with AutomaticKeepAliveClientMixin<HymnsListWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.hymnsList.isEmpty) {
      return const Center(child: Text("Brak pieśni"));
    }

    return Scrollbar(
      thumbVisibility: true,
      thickness: 10.0,
      interactive: true,
      controller: _scrollController,
      child: ListView.builder(
          controller: _scrollController,
          itemCount: widget.hymnsList.length,
          itemBuilder: (context, index) {
            return HymnTileWidget(hymn: widget.hymnsList[index]);
          }),
    );
  }

  @override
  bool get wantKeepAlive => true;
}