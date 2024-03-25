import 'package:flutter/material.dart';

abstract class FavoritesRepository extends ChangeNotifier {
  Future<bool> isFavorite(String id);
  Future<void> add(String id);
  Future<void> remove(String id);
  Future<List<String>> getFavorites();
}
