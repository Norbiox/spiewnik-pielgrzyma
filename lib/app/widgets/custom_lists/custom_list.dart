import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/provider.dart';
import 'package:spiewnik_pielgrzyma/app/providers/hymns/provider.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/custom_lists/archived_hymn_tile.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/custom_lists/hymn_tile.dart';
import 'package:spiewnik_pielgrzyma/models/custom_list.dart';
import 'package:watch_it/watch_it.dart';

class CustomListWidget extends WatchingStatefulWidget {
  final String listId;

  const CustomListWidget({super.key, required this.listId});

  @override
  State<CustomListWidget> createState() => _CustomListWidgetState();
}

class _CustomListWidgetState extends State<CustomListWidget> {
  late final ScrollController scrollController;
  bool _archiveExpanded = true;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CustomListProvider provider = GetIt.I<CustomListProvider>();
    final HymnsListProvider hymnsProvider = GetIt.I<HymnsListProvider>();
    watch(provider);

    CustomList list = provider.getList(widget.listId);

    return Scrollbar(
        controller: scrollController,
        thumbVisibility: false,
        child: SingleChildScrollView(
            controller: scrollController,
            child: Column(children: [
              _hymnsList(context, list, provider, hymnsProvider),
              _hymnsArchiveExpander(context, list, provider, hymnsProvider),
              _hymnsArchive(context, list, provider, hymnsProvider),
            ])));
  }

  Widget _hymnsList(BuildContext context, CustomList list,
      CustomListProvider provider, HymnsListProvider hymnsProvider) {
    if (list.hymnsIds.isEmpty) {
      return const Text("Nie dodałeś jeszcze żadnej pieśni do tej listy");
    }

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: true,
      itemCount: list.hymnsIds.length,
      prototypeItem: const ListTile(),
      itemBuilder: (context, index) => HymnTileWidget(
          key: ValueKey('active-${list.hymnsIds[index]}'),
          list: list,
          hymn: hymnsProvider.getHymn(list.hymnsIds[index])),
      onReorder: (oldIndex, newIndex) {
        list.reorderHymns(oldIndex, newIndex);
        provider.save(list);
      },
    );
  }

  Widget _hymnsArchiveExpander(BuildContext context, CustomList list,
      CustomListProvider provider, HymnsListProvider hymnsProvider) {
    return ListTile(
      tileColor: Theme.of(context).colorScheme.secondaryContainer,
      minTileHeight: 15,
      title: Center(
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Text(
            _archiveExpanded ? "Ukryj zarchiwizowane" : "Pokaż zarchiwizowane"),
        Icon(_archiveExpanded ? Icons.expand_less : Icons.expand_more)
      ])),
      titleTextStyle: Theme.of(context).textTheme.titleSmall,
      // trailing: Icon(_archiveExpanded ? Icons.expand_less : Icons.expand_more),
      onTap: () {
        setState(() {
          _archiveExpanded = !_archiveExpanded;
        });
      },
    );
  }

  Widget _hymnsArchive(BuildContext context, CustomList list,
      CustomListProvider provider, HymnsListProvider hymnsProvider) {
    if (!_archiveExpanded) return const SizedBox();

    if (list.archivedHymnsIds.isEmpty) return const Text("Nic tu nie ma");

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: true,
      itemCount: list.archivedHymnsIds.length,
      prototypeItem: const ListTile(),
      itemBuilder: (context, index) => ArchivedHymnTileWidget(
          key: ValueKey('archived-${list.archivedHymnsIds[index]}'),
          list: list,
          hymn: hymnsProvider.getHymn(list.archivedHymnsIds[index])),
      onReorder: (oldIndex, newIndex) {
        list.reorderArchivedHymns(oldIndex, newIndex);
        provider.save(list);
      },
    );
  }
}
