import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spiewnik_pielgrzyma/hymns/hymns_list.dart';

class HymnsListPage extends StatelessWidget {
  const HymnsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HymnsListProvider>(builder: (context, provider, child) {
      final hymnsList = provider.hymnsList;

      if (hymnsList.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      return CustomScrollView(slivers: [
        SliverList(delegate: SliverChildBuilderDelegate((context, index) {
          return ListTile(
            title: Text(hymnsList[index].fullTitle),
          );
        }))
      ]);
    });
  }
}
