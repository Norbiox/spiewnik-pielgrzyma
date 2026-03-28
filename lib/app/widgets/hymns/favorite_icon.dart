import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/app/providers/hymns/provider.dart';
import 'package:spiewnik_pielgrzyma/models/hymn.dart';
import 'package:spiewnik_pielgrzyma/settings/confirm_favorite_removal.dart';
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
        if (hymn.isFavorite &&
            GetIt.I<ConfirmFavoriteRemovalProvider>().isEnabled) {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              content: Text(
                  'Na pewno chcesz usunąć pieśń "${hymn.fullTitle}" z ulubionych?'),
              actions: [
                FilledButton.tonal(
                  child: const Text("Nie"),
                  onPressed: () => Navigator.pop(context, false),
                ),
                FilledButton(
                  child: const Text("Tak"),
                  onPressed: () => Navigator.pop(context, true),
                ),
              ],
            ),
          );
          if (confirmed != true) return;
        }
        await hymnsList.toggleIsFavorite(hymn);
      },
    );
  }
}
