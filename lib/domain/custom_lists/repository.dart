import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/domain/custom_lists/model.dart';
import 'package:spiewnik_pielgrzyma/seed/entity.dart';
import 'package:spiewnik_pielgrzyma/seed/exceptions.dart';

class CustomListNotFoundException extends RepositoryException {}

abstract class CustomListRepository extends ChangeNotifier {
  Future<CustomList> getById(EntityId listId);
  Future<List<CustomList>> getAll();
  Future<void> save(CustomList list);
  Future<void> saveAll(List<CustomList> list);
  Future<void> remove(CustomList list);
}
