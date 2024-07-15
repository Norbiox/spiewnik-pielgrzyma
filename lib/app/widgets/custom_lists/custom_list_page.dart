import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/custom_lists/custom_list.dart';
import 'package:spiewnik_pielgrzyma/models/custom_list.dart';

class CustomListPage extends StatelessWidget {
  final CustomList list;

  const CustomListPage({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(list.name!),
      ),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomListWidget(list: list)),
    );
  }
}
