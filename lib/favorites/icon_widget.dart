import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spiewnik_pielgrzyma/favorites/repository/abstract.dart';
import 'package:spiewnik_pielgrzyma/favorites/repository/shared_preferences.dart';
import 'package:spiewnik_pielgrzyma/hymns/hymn.dart';

class FavoriteIconWidget extends StatelessWidget {
  final Hymn hymn;

  const FavoriteIconWidget({super.key, required this.hymn});

  @override
  Widget build(BuildContext context) {
    return Consumer<SharedPreferencesFavoritesRepository>(
      builder: (context, value, child) {
        return FutureBuilder(
            future: value.isFavorite(hymn),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox(child: CircularProgressIndicator());
              }

              return IconButton(
                icon: Icon(
                    snapshot.data! ? Icons.favorite : Icons.favorite_border),
                onPressed: () async {
                  if (await value.isFavorite(hymn)) {
                    await value.remove(hymn);
                  } else {
                    await value.add(hymn);
                  }
                },
              );
            });
      },
    );
  }
}
