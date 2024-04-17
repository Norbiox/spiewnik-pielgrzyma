import 'package:flutter/widgets.dart';
import 'package:spiewnik_pielgrzyma/favorites/repository/abstract.dart';
import 'package:spiewnik_pielgrzyma/hymns/model/hymn.dart';
import 'package:spiewnik_pielgrzyma/hymns/widgets/hymns_list.dart';
import 'package:watch_it/watch_it.dart';

class FavoritesPage extends StatelessWidget with WatchItMixin {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = watchFuture(
        (FavoritesRepository favRepo) => favRepo.getFavorites(),
        initialValue: <Hymn>[]);

    if (!favorites.hasData) {
      return const Text("Nie masz jeszcze ulubionych pieśni");
    }

    return HymnsListWidget(hymnsList: favorites.data!);
  }
}
