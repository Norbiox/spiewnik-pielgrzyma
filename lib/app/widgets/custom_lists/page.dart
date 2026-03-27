import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/provider.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/custom_lists/list.dart';
import 'package:spiewnik_pielgrzyma/models/custom_list.dart';
import 'package:watch_it/watch_it.dart';

class CustomListsPage extends WatchingWidget {
  final String searchQuery;

  const CustomListsPage({super.key, this.searchQuery = ''});

  @override
  Widget build(BuildContext context) {
    final CustomListProvider provider = GetIt.I<CustomListProvider>();
    watch(provider);

    List<CustomList> lists = provider.getLists();
    final isSearching = searchQuery.isNotEmpty;
    if (isSearching) {
      lists = lists
          .where(
              (l) => l.name.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    if (provider.getLists().isEmpty) {
      return const Center(child: Text("Nie utworzyłeś jeszcze żadnej listy"));
    } else if (lists.isEmpty) {
      return const Center(child: Text("Nic nie znaleziono"));
    } else {
      return CustomListsListWidget(lists: lists, isSearching: isSearching);
    }
  }
}
