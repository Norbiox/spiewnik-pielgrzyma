import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:spiewnik_pielgrzyma/favorites/repository/abstract.dart';
import 'package:spiewnik_pielgrzyma/favorites/repository/shared_preferences.dart';
import 'package:spiewnik_pielgrzyma/hymns/hymn_tile_widget.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage>
    with AutomaticKeepAliveClientMixin<FavoritesPage> {
  late FavoritesRepository repository;

  @override
  void initState() {
    super.initState();
    repository = Provider.of<SharedPreferencesFavoritesRepository>(context,
        listen: false);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<SharedPreferencesFavoritesRepository>(
        builder: (builder, value, child) {
      return FutureBuilder(
        future: value.getFavorites(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: Text("Nie masz jeszcze ulubionych pieśni"));
          }

          return ListView(
              children: snapshot.data!
                  .map((hymn) => HymnTileWidget(hymn: hymn))
                  .toList());
        },
      );
    });
  }

  @override
  bool get wantKeepAlive => true;
}
