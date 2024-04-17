import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/favorites/repository/abstract.dart';
import 'package:spiewnik_pielgrzyma/hymns/model/hymn.dart';
import 'package:watch_it/watch_it.dart';

class FavoriteIconWidget extends StatelessWidget with WatchItMixin {
  final Hymn hymn;

  const FavoriteIconWidget({super.key, required this.hymn});

  @override
  Widget build(BuildContext context) {
    final FavoritesRepository favRepo = GetIt.I<FavoritesRepository>();
    watchIt<FavoritesRepository>();

    return FutureBuilder(
        future: favRepo.isFavorite(hymn),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox(child: CircularProgressIndicator());
          }

          return IconButton(
            icon: Icon(snapshot.data! ? Icons.favorite : Icons.favorite_border),
            onPressed: () async {
              if (await favRepo.isFavorite(hymn)) {
                await favRepo.remove(hymn);

                // if (!context.mounted) return;
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(
                //     content:
                //         Text("Usunięto pieśń ${hymn.number} z ulubionych"),
                //     action: SnackBarAction(
                //       label: 'Przywróć',
                //       onPressed: () async => await value.add(hymn),
                //     ),
                //     duration: const Duration(seconds: 2),
                //   ),
                // );
              } else {
                await favRepo.add(hymn);

                // if (!context.mounted) return;
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(
                //     content:
                //         Text("Dodano pieśń ${hymn.number} do ulubionych"),
                //     action: SnackBarAction(
                //       label: 'Cofnij',
                //       onPressed: () async => await value.remove(hymn),
                //     ),
                //     duration: const Duration(seconds: 2),
                //   ),
                // );
              }
            },
          );
        });
  }
}
