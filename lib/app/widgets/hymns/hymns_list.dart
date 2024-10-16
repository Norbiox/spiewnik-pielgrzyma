import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/models/hymn.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/hymns/hymn_tile.dart';

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

    return Scrollbar(
      thumbVisibility: true,
      thickness: 20.0,
      interactive: true,
      controller: _scrollController,
      child: ListView.builder(
          controller: _scrollController,
          itemCount: widget.hymnsList.length,
          prototypeItem: const ListTile(),
          itemBuilder: (context, index) {
            return HymnTileWidget(hymnId: widget.hymnsList[index].id);
          }),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
