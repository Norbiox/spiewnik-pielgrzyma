import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/hymns/hymn.dart';

abstract class FavoritesRepository extends ChangeNotifier {
  Future<bool> isFavorite(Hymn hymn);
  Future<void> add(Hymn hymn);
  Future<void> remove(Hymn hymn);
  Future<List<Hymn>> getFavorites();
}
