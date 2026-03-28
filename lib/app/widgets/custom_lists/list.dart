import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/provider.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/custom_lists/list_tile.dart';
import 'package:spiewnik_pielgrzyma/models/custom_list.dart';
import 'package:watch_it/watch_it.dart';

class CustomListsListWidget extends StatefulWidget {
  final List<CustomList> lists;
  final bool isSearching;

  const CustomListsListWidget({
    super.key,
    required this.lists,
    this.isSearching = false,
  });

  @override
  State<CustomListsListWidget> createState() => _CustomListsListWidgetState();
}

class _CustomListsListWidgetState extends State<CustomListsListWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CustomListProvider provider = GetIt.I<CustomListProvider>();

    return Scrollbar(
      thumbVisibility: true,
      thickness: 20.0,
      interactive: true,
      controller: _scrollController,
      child: widget.isSearching
          ? ListView.builder(
              controller: _scrollController,
              itemCount: widget.lists.length,
              prototypeItem: const ListTile(),
              itemBuilder: (context, index) => Container(
                key: ValueKey(widget.lists[index]),
                child: CustomListTileWidget(list: widget.lists[index]),
              ),
            )
          : ReorderableListView.builder(
              scrollController: _scrollController,
              onReorder: (oldIndex, newIndex) {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final reordered = List<CustomList>.from(widget.lists);
                final item = reordered.removeAt(oldIndex);
                reordered.insert(newIndex, item);
                provider.reindex(reordered);
              },
              itemCount: widget.lists.length,
              prototypeItem: const ListTile(),
              itemBuilder: (context, index) => Container(
                key: ValueKey(widget.lists[index]),
                child: CustomListTileWidget(list: widget.lists[index]),
              ),
            ),
    );
  }
}
