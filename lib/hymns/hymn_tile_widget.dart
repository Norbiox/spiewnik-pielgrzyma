import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiewnik_pielgrzyma/favorites/repository/shared_preferences.dart';
import 'package:spiewnik_pielgrzyma/hymns/hymn.dart';
import 'package:spiewnik_pielgrzyma/hymns/hymn_page.dart';

class HymnTileWidget extends StatelessWidget {
  final Hymn hymn;

  const HymnTileWidget({super.key, required this.hymn});

  Future<IconData> getFavoriteIcon() async {
    if (await SharedPreferencesFavoritesRepository(
            await SharedPreferences.getInstance())
        .isFavorite(hymn.number)) {
      return Icons.favorite;
    } else {
      return Icons.favorite_border;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getFavoriteIcon(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListTile(
                leading: Icon(snapshot.data),
                title: Text(hymn.fullTitle),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => HymnPage(hymn: hymn),
                  ));
                });
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}
