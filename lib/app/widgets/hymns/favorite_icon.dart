import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/app/providers/hymns/provider.dart';
import 'package:spiewnik_pielgrzyma/domain/hymns/model.dart';
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
