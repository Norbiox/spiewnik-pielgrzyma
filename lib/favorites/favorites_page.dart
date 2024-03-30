import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:spiewnik_pielgrzyma/favorites/repository/shared_preferences.dart';
import 'package:spiewnik_pielgrzyma/hymns/hymns_list_widget.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SharedPreferencesFavoritesRepository>(
        builder: (builder, value, child) {
      return FutureBuilder(
          future: value.getFavorites(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                  child: Text("Nie masz jeszcze ulubionych pieśni"));
            }

            return HymnsListWidget(hymnsList: snapshot.data!);
          });
    });
  }
}
