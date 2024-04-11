import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:spiewnik_pielgrzyma/custom_lists/custom_list_tile_widget.dart';
import 'package:spiewnik_pielgrzyma/custom_lists/list.dart';
import 'package:spiewnik_pielgrzyma/custom_lists/repository.dart';

class CustomListsListWidget extends StatefulWidget {
  const CustomListsListWidget({super.key});

  @override
  State<CustomListsListWidget> createState() => _CustomListsListWidgetState();
}

class _CustomListsListWidgetState extends State<CustomListsListWidget> {
  final ScrollController _scrollController = ScrollController();
  CustomListsRepository repository = GetIt.I<CustomListsRepository>();

  @override
  Widget build(BuildContext context) {
    final list = repository.customLists;

    if (list.isEmpty) {
      return const Text("Nie utworzyłeś jeszcze żadnej listy");
    }

    return Scrollbar(
      thumbVisibility: true,
      thickness: 10.0,
      interactive: true,
      controller: _scrollController,
      child: ReorderableListView.builder(
        onReorder: (oldIndex, newIndex) {
          setState(() {
            _updateItems(oldIndex, newIndex);
          });
        },
        itemCount: list.length,
        prototypeItem: const ListTile(),
        itemBuilder: (context, index) => Container(
          key: ValueKey(list[index]),
          child: CustomListTileWidget(list: list[index]),
        ),
      ),
      // CustomListTileWidget(list: list[index])),
    );
  }

  void _updateItems(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    List<CustomList> list = repository.customLists;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    repository.save(list);
  }
}
