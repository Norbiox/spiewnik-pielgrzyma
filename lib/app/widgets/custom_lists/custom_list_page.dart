import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/provider.dart';
import 'package:spiewnik_pielgrzyma/app/providers/hymns/provider.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/custom_lists/custom_list.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/custom_lists/search_hymn.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/utils/list_action.dart';
import 'package:spiewnik_pielgrzyma/models/custom_list.dart';
import 'package:watch_it/watch_it.dart';

class CustomListPage extends StatelessWidget {
  final CustomListProvider provider = GetIt.I<CustomListProvider>();
  final HymnsListProvider hymnsProvider = GetIt.I<HymnsListProvider>();
  final String listId;

  CustomListPage({super.key, required this.listId});

  @override
  Widget build(BuildContext context) {
    final CustomList list = provider.getList(listId);
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          if (list.isShared)
            const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(Icons.share, size: 18),
            ),
          Expanded(
            child: TextField(
              controller: TextEditingController(text: list.name),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Kliknij aby nazwać listę",
                hintStyle: Theme.of(context).textTheme.titleLarge,
              ),
              onSubmitted: (value) =>
                  runListAction(context, () => provider.rename(list, value)),
            ),
          ),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Udostępnij listę',
            onPressed: () => _share(context, list),
          ),
        ],
      ),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomListWidget(listId: list.id)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showSearch(
            context: context,
            delegate: SearchForHymnToAddToCustomList(
                provider: hymnsProvider,
                hymns: hymnsProvider.getAll(),
                listId: listId)),
        tooltip: "Dodaj pieśń do listy",
        child: const Icon(Icons.add),
      ),
    );
  }

  static const String _shareBase =
      'https://spiewnikpielgrzyma.norbertchmiel.pl/dolacz.html';

  Future<void> _share(BuildContext context, CustomList list) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final shared = await provider.shareList(list);
      await SharePlus.instance.share(ShareParams(
        text: 'Śpiewnik Pielgrzyma — lista „${shared.name}”:\n'
            '$_shareBase?t=${shared.shareToken}',
      ));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Nie udało się udostępnić listy. Sprawdź połączenie.'),
        ),
      );
    }
  }
}
