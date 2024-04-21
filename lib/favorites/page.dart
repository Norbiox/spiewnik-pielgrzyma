import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/hymns/lib/provider.dart';
import 'package:spiewnik_pielgrzyma/hymns/widgets/hymns_list.dart';
import 'package:watch_it/watch_it.dart';

class FavoritesPage extends WatchingWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final HymnsListProvider hymnsList = GetIt.I<HymnsListProvider>();
    watch(hymnsList);

    return HymnsListWidget(
        hymnsList: hymnsList.hymnsList
            .where((element) => element.isFavorite == true)
            .toList());
  }
}
