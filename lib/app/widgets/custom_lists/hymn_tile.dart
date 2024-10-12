import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/provider.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/hymns/hymn_page.dart';
import 'package:spiewnik_pielgrzyma/models/custom_list.dart';
import 'package:spiewnik_pielgrzyma/models/hymn.dart';
import 'package:watch_it/watch_it.dart';

class HymnTileWidget extends StatelessWidget {
  final CustomList list;
  final Hymn hymn;

  const HymnTileWidget({super.key, required this.list, required this.hymn});

  @override
  Widget build(BuildContext context) {
    CustomListProvider provider = GetIt.I<CustomListProvider>();

    return ListTile(
      horizontalTitleGap: 0,
      title: Text(
        hymn.fullTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => HymnPage(hymnId: hymn.id),
        ));
      },
      trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                    content: Text(
                        'Na pewno chcesz usunąć pieśń "${hymn.fullTitle}" z listy "${list.name}"?'),
                    actions: <Widget>[
                      FilledButton.tonal(
                        child: const Text("Nie"),
                        onPressed: () => Navigator.pop(context),
                      ),
                      FilledButton(
                          child: const Text("Tak"),
                          onPressed: () {
                            list.removeHymn(hymn);
                            provider.save(list);
                            Navigator.pop(context);
                          })
                    ]);
              })),
    );
  }
}
