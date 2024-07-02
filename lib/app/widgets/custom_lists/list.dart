import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/custom_lists/list_tile.dart';
import 'package:spiewnik_pielgrzyma/infra/objectbox.dart';
import 'package:spiewnik_pielgrzyma/models/custom_list.dart';
import 'package:watch_it/watch_it.dart';

class CustomListsListWidget extends StatelessWidget with WatchItMixin {
  const CustomListsListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    ScrollController scrollController = ScrollController();
    var box = GetIt.I<ObjectBox>();
    List<CustomList> list = box.customListBox.getAll();

    if (list.isEmpty) {
      return const Text("Nie utworzyłeś jeszcze żadnej listy");
    }

    return Scrollbar(
      thumbVisibility: true,
      thickness: 10.0,
      interactive: true,
      controller: scrollController,
      child: ReorderableListView.builder(
        onReorder: (oldIndex, newIndex) {},
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
