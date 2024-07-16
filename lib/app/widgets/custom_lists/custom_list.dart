import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/provider.dart';
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
    watch(provider);

    CustomList list = provider.getList(listId);

    if (list.hymns.isEmpty) {
      return const Text("Nie dodałeś jeszcze żadnej pieśni do tej listy");
    }

    return Scrollbar(
      thumbVisibility: true,
      thickness: 20.0,
      interactive: true,
      controller: scrollController,
      child: ReorderableListView.builder(
          onReorder: (oldIndex, newIndex) {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final item = list.hymns.removeAt(oldIndex);
            list.hymns.insert(newIndex, item);
            provider.save(list);
          },
          itemCount: list.hymns.length,
          prototypeItem: const ListTile(),
          itemBuilder: (context, index) => Container(
                key: ValueKey(list.hymns[index]),
                child: HymnTileWidget(list: list, hymn: list.hymns[index]),
              )),
    );
  }
}
