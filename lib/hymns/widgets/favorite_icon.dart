import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/hymns/lib/provider.dart';
import 'package:spiewnik_pielgrzyma/hymns/model/hymn.dart';
import 'package:watch_it/watch_it.dart';

class FavoriteIconWidget extends WatchingWidget {
  final Hymn hymn;

  const FavoriteIconWidget({super.key, required this.hymn});

  @override
  Widget build(BuildContext context) {
    final HymnsListProvider hymnsList = GetIt.I<HymnsListProvider>();
    watch(hymnsList);

    return IconButton(
      icon: Icon(hymn.isFavorite ? Icons.favorite : Icons.favorite_border),
      onPressed: () async {
        await hymnsList.toggleIsFavorite(hymn);
      },
    );
  }
}
