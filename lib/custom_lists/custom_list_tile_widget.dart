import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/custom_lists/list.dart';

class CustomListTileWidget extends StatelessWidget {
  final CustomList list;

  const CustomListTileWidget({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(list.name),
      trailing: Text("pieśni: ${list.hymnNumbers.length.toString()}"),
    );
  }
}
