import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/hymns/hymn.dart';

class HymnPage extends StatelessWidget {
  final Hymn hymn;

  const HymnPage({super.key, required this.hymn});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: hymn.getText(),
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return Scaffold(
              appBar: AppBar(title: Text(hymn.fullTitle)),
              body: ListView(
                children: snapshot.data!
                    .map((line) => Text(line,
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.bodyLarge))
                    .toList(),
              ));
        });
  }
}
