import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/provider.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/custom_lists/hymn_tile.dart';
import 'package:spiewnik_pielgrzyma/models/custom_list.dart';
import 'package:watch_it/watch_it.dart';

class CustomListWidget extends WatchingWidget {
  final CustomList list;

  const CustomListWidget({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    final CustomListProvider provider = GetIt.I<CustomListProvider>();
    watch(provider);

    if (list.hymns.isEmpty) {
      return const Text("Nie dodałeś jeszcze żadnej pieśni do tej listy");
    }

    return Scrollbar(
      thumbVisibility: true,
      thickness: 20.0,
      interactive: true,
      controller: scrollController,
      child: ListView.builder(
          controller: scrollController,
          itemCount: list.hymns.length,
          prototypeItem: const ListTile(),
          itemBuilder: (context, index) {
            return HymnTileWidget(list: list, hymn: list.hymns[index]);
          }),
    );
  }
}
