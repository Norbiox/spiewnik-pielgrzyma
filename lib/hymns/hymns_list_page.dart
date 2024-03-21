import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spiewnik_pielgrzyma/hymns/hymns_list.dart';

class HymnsListPage extends StatefulWidget {
  const HymnsListPage({super.key});

  @override
  State<HymnsListPage> createState() => _HymnsListPageState();
}

class _HymnsListPageState extends State<HymnsListPage>
    with AutomaticKeepAliveClientMixin<HymnsListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<HymnsListProvider>(builder: (context, provider, child) {
      final hymnsList = provider.hymnsList;

      if (hymnsList.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      return Scrollbar(
        thumbVisibility: true,
        thickness: 10.0,
        interactive: true,
        controller: _scrollController,
        child: ListView.builder(
            controller: _scrollController,
            itemCount: hymnsList.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(hymnsList[index].fullTitle),
              );
            }),
      );
    });
  }

  @override
  bool get wantKeepAlive => true;
}
