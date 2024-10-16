import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/provider.dart';
import 'package:spiewnik_pielgrzyma/app/providers/hymns/provider.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/custom_lists/hymn_tile.dart';
import 'package:spiewnik_pielgrzyma/models/custom_list.dart';
import 'package:watch_it/watch_it.dart';

class CustomListWidget extends WatchingWidget {
  final int listId;

  const CustomListWidget({super.key, required this.listId});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    final CustomListProvider provider = GetIt.I<CustomListProvider>();
    final HymnsListProvider hymnsProvider = GetIt.I<HymnsListProvider>();
    watch(provider);

    CustomList list = provider.getList(listId);

    if (list.hymnsIds.isEmpty) {
      return const Text("Nie dodałeś jeszcze żadnej pieśni do tej listy");
    }

    return Scrollbar(
      thumbVisibility: true,
      thickness: 20.0,
      interactive: true,
      controller: scrollController,
      child: ReorderableListView.builder(
          onReorder: (oldIndex, newIndex) {
            list.reorderHymns(oldIndex, newIndex);
            provider.save(list);
          },
          itemCount: list.hymnsIds.length,
          prototypeItem: const ListTile(),
          itemBuilder: (context, index) => Container(
                key: ValueKey(list.hymnsIds[index]),
                child: HymnTileWidget(
                    list: list,
                    hymn: hymnsProvider.getHymnById(list.hymnsIds[index])!),
              )),
    );
  }
}
