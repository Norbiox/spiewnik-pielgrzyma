import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:spiewnik_pielgrzyma/custom_lists/custom_list_tile_widget.dart';
import 'package:spiewnik_pielgrzyma/custom_lists/list.dart';
import 'package:spiewnik_pielgrzyma/custom_lists/repository.dart';
import 'package:watch_it/watch_it.dart';

class CustomListsListWidget extends StatelessWidget with WatchItMixin {
  const CustomListsListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    ScrollController scrollController = ScrollController();
    final list = watchIt<CustomListsRepository>().customLists;

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
          _updateItems(oldIndex, newIndex);
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

  void _updateItems(int oldIndex, int newIndex) {
    final repository = GetIt.I<CustomListsRepository>();

    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    List<CustomList> list = repository.customLists;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    repository.save(list);
  }
}
