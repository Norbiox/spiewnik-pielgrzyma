import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/domain/custom_lists/model.dart';
import 'package:spiewnik_pielgrzyma/seed/entity.dart';

abstract class CustomListRepository extends ChangeNotifier {
  CustomList getById(EntityId listId);
  List<CustomList> getAll();
  void save(CustomList list);
  void saveAll(List<CustomList> list);
  void remove(CustomList list);
}
