import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/provider.dart';
import 'package:spiewnik_pielgrzyma/models/custom_list.dart';
import 'package:watch_it/watch_it.dart';

class ArchivedListsPage extends WatchingWidget {
  const ArchivedListsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = GetIt.I<CustomListProvider>();
    watch(provider);

    final List<CustomList> archivedLists = provider.getArchivedLists();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Przywracanie list'),
      ),
      body: archivedLists.isEmpty
          ? const Center(
              child: Text('Brak zarchiwizowanych list'),
            )
          : ListView.builder(
              itemCount: archivedLists.length,
              itemBuilder: (context, index) {
                final list = archivedLists[index];
                return ListTile(
                  title: Text(list.name),
                  subtitle: Text('pieśni: ${list.hymnsIds.length}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.unarchive),
                    onPressed: () => provider.restoreList(list),
                  ),
                );
              },
            ),
    );
  }
}
