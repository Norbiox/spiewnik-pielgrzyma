import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/provider.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/custom_lists/list_tile.dart';
import 'package:spiewnik_pielgrzyma/models/custom_list.dart';
import 'package:watch_it/watch_it.dart';

class CustomListsListWidget extends StatelessWidget {
  final List<CustomList> lists;
  final bool isSearching;

  const CustomListsListWidget({
    super.key,
    required this.lists,
    this.isSearching = false,
  });

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    final CustomListProvider provider = GetIt.I<CustomListProvider>();

    return Scrollbar(
      thumbVisibility: true,
      thickness: 20.0,
      interactive: true,
      controller: scrollController,
      child: isSearching
          ? ListView.builder(
              controller: scrollController,
              itemCount: lists.length,
              prototypeItem: const ListTile(),
              itemBuilder: (context, index) => Container(
                key: ValueKey(lists[index]),
                child: CustomListTileWidget(list: lists[index]),
              ),
            )
          : ReorderableListView.builder(
              scrollController: scrollController,
              onReorder: (oldIndex, newIndex) {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final reordered = List<CustomList>.from(lists);
                final item = reordered.removeAt(oldIndex);
                reordered.insert(newIndex, item);
                provider.reindex(reordered);
              },
              itemCount: lists.length,
              prototypeItem: const ListTile(),
              itemBuilder: (context, index) => Container(
                key: ValueKey(lists[index]),
                child: CustomListTileWidget(list: lists[index]),
              ),
            ),
    );
  }
}
