import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/provider.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/custom_lists/custom_list.dart';
import 'package:spiewnik_pielgrzyma/models/custom_list.dart';
import 'package:watch_it/watch_it.dart';

class CustomListPage extends StatelessWidget {
  final CustomList list;

  const CustomListPage({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: TextEditingController(text: list.name),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Nazwa listy",
            hintStyle: Theme.of(context).textTheme.titleLarge,
          ),
          onSubmitted: (value) {
            list.name = value;
            GetIt.I<CustomListProvider>().save(list);
          },
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomListWidget(list: list)),
    );
  }
}
