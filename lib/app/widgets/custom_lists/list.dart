import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/custom_lists/list_tile.dart';
import 'package:spiewnik_pielgrzyma/domain/custom_lists/model.dart';
import 'package:spiewnik_pielgrzyma/domain/custom_lists/repository.dart';
import 'package:watch_it/watch_it.dart';

class CustomListsListWidget extends StatelessWidget with WatchItMixin {
  const CustomListsListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    ScrollController scrollController = ScrollController();
    var repository = GetIt.I<CustomListRepository>();
    List<CustomList> list = repository.getAll();

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
    final repository = GetIt.I<CustomListRepository>();

    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    List<CustomList> lists = repository.getAll();
    CustomList list = lists.removeAt(oldIndex);
    lists.insert(newIndex, list);
    repository.saveAll(lists);
  }
}
