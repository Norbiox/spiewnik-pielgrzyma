import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';
import 'package:spiewnik_pielgrzyma/models/custom_list.dart';

class CustomListProvider with ChangeNotifier {
  final Box<CustomList> customListBox;

  CustomListProvider(this.customListBox);

  List<CustomList> getLists() {
    return customListBox.getAll();
  }

  createNewList(String name) {
    CustomList newList = CustomList(name);
    customListBox.put(newList);
    notifyListeners();
  }

  deleteList(CustomList list) {
    customListBox.remove(list.id);
    notifyListeners();
  }
}
