import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/provider.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/custom_lists/list_tile.dart';
import 'package:spiewnik_pielgrzyma/models/custom_list.dart';
import 'package:watch_it/watch_it.dart';

class CustomListsListWidget extends WatchingWidget {
  const CustomListsListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    ScrollController scrollController = ScrollController();
    CustomListProvider provider = GetIt.I<CustomListProvider>();
    watch(provider);

    List<CustomList> list = provider.getLists();

    if (list.isEmpty) {
      return const Text("Nie utworzyłeś jeszcze żadnej listy");
    }

    return Scrollbar(
      thumbVisibility: true,
      thickness: 10.0,
      interactive: true,
      controller: scrollController,
      child: ReorderableListView.builder(
        onReorder: (oldIndex, newIndex) {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final item = list.removeAt(oldIndex);
          list.insert(newIndex, item);
          provider.reindex(list);
        },
        itemCount: list.length,
        prototypeItem: const ListTile(),
        itemBuilder: (context, index) => Container(
          key: ValueKey(list[index]),
          child: CustomListTileWidget(list: list[index]),
        ),
      ),
    );
  }
}
