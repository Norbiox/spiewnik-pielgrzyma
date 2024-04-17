import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/custom_lists/model/list_of_lists.dart';
import 'package:spiewnik_pielgrzyma/custom_lists/widgets/list_tile.dart';
import 'package:spiewnik_pielgrzyma/custom_lists/repository/list_of_lists.dart';
import 'package:watch_it/watch_it.dart';

class CustomListsListWidget extends StatelessWidget with WatchItMixin {
  const CustomListsListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    ScrollController scrollController = ScrollController();
    final list = watchIt<CustomListsRepository>().customLists;

    if (list.elements.isEmpty) {
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

    ListOfCustomLists list = repository.customLists;
    list.setIndex(list[oldIndex], newIndex);
    repository.save(list);
  }
}
