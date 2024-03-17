import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/hymns/hymn.dart';
import 'package:spiewnik_pielgrzyma/hymns/hymns_list_loader.dart';

class HymnsListPage extends StatelessWidget {
  const HymnsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Future<List<Hymn>> _hymnsList = HymnsListLoader().loadHymnsList();

    return FutureBuilder(
        future: _hymnsList,
        builder: (BuildContext context, AsyncSnapshot<List<Hymn>> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(slivers: [
            SliverList(delegate:
                SliverChildBuilderDelegate((BuildContext context, int index) {
              return ListTile(
                title: Text(snapshot.data![index].fullTitle),
              );
            })),
          ]);
        });
  }
}
