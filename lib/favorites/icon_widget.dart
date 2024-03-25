import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spiewnik_pielgrzyma/favorites/repository/abstract.dart';
import 'package:spiewnik_pielgrzyma/favorites/repository/shared_preferences.dart';
import 'package:spiewnik_pielgrzyma/hymns/hymn.dart';

class FavoriteIconWidget extends StatefulWidget {
  final Hymn hymn;

  const FavoriteIconWidget({super.key, required this.hymn});

  @override
  State<FavoriteIconWidget> createState() => _FavoriteIconWidgetState();
}

class _FavoriteIconWidgetState extends State<FavoriteIconWidget> {
  late FavoritesRepository repository;

  @override
  void initState() {
    super.initState();
    repository = Provider.of<SharedPreferencesFavoritesRepository>(context,
        listen: false);
  }

  void _onPressed() async {
    if (await repository.isFavorite(widget.hymn.number)) {
      await repository.remove(widget.hymn.number);
    } else {
      await repository.add(widget.hymn.number);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: repository.isFavorite(widget.hymn.number),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return IconButton(
              icon:
                  Icon(snapshot.data! ? Icons.favorite : Icons.favorite_border),
              onPressed: _onPressed,
            );
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}
