import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/gateway.dart';
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/provider.dart';
import 'package:spiewnik_pielgrzyma/app/providers/hymns/provider.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/custom_lists/archived_hymn_tile.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/custom_lists/hymn_tile.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/utils/list_action.dart';
import 'package:spiewnik_pielgrzyma/models/custom_list.dart';
import 'package:watch_it/watch_it.dart';

class CustomListWidget extends WatchingStatefulWidget {
  final String listId;
  final bool locked;

  const CustomListWidget(
      {super.key, required this.listId, this.locked = false});

  @override
  State<CustomListWidget> createState() => _CustomListWidgetState();
}

class _CustomListWidgetState extends State<CustomListWidget>
    with WidgetsBindingObserver {
  late final ScrollController scrollController;
  bool _archiveExpanded = true;
  SharedListSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    WidgetsBinding.instance.addObserver(this);

    final provider = GetIt.I<CustomListProvider>();
    final list = provider.getList(widget.listId);
    if (!list.isShared) return;

    unawaited(provider.refreshSharedLists());
    _subscription = GetIt.I<SharedListGateway>().subscribe(
      widget.listId,
      onChange: (remote) {
        remote.shareToken = list.shareToken;
        provider.applyRemote(remote);
      },
      onDelete: () {
        provider.deleteList(list);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Lista została usunięta przez właściciela'),
        ));
        context.pop();
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(GetIt.I<CustomListProvider>().refreshSharedLists());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_subscription?.close());
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
      buildDefaultDragHandles: !widget.locked,
      itemCount: list.hymnsIds.length,
      prototypeItem: const ListTile(),
      itemBuilder: (context, index) => HymnTileWidget(
          key: ValueKey('active-${list.hymnsIds[index]}'),
          list: list,
          hymn: hymnsProvider.getHymn(list.hymnsIds[index])),
      onReorder: (oldIndex, newIndex) {
        if (oldIndex < newIndex) newIndex -= 1;
        final hymnId = list.hymnsIds[oldIndex];
        final rest = list.hymnsIds.where((id) => id != hymnId).toList();
        final beforeHymnId = newIndex < rest.length ? rest[newIndex] : null;
        runListAction(
            context, () => provider.moveHymn(list, hymnId, beforeHymnId));
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
      buildDefaultDragHandles: !widget.locked,
      itemCount: list.archivedHymnsIds.length,
      prototypeItem: const ListTile(),
      itemBuilder: (context, index) => ArchivedHymnTileWidget(
          key: ValueKey('archived-${list.archivedHymnsIds[index]}'),
          list: list,
          hymn: hymnsProvider.getHymn(list.archivedHymnsIds[index])),
      onReorder: (oldIndex, newIndex) {
        if (oldIndex < newIndex) newIndex -= 1;
        final hymnId = list.archivedHymnsIds[oldIndex];
        final rest = list.archivedHymnsIds.where((id) => id != hymnId).toList();
        final beforeHymnId = newIndex < rest.length ? rest[newIndex] : null;
        runListAction(context,
            () => provider.moveArchivedHymn(list, hymnId, beforeHymnId));
      },
    );
  }
}
