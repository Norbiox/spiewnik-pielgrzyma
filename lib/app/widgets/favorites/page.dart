import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/app/providers/hymns/provider.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/hymns/hymns_list.dart';
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
