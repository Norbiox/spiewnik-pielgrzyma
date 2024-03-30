import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spiewnik_pielgrzyma/hymns/hymns_list.dart';
import 'package:spiewnik_pielgrzyma/hymns/hymns_list_widget.dart';

class HymnsListPage extends StatelessWidget {
  const HymnsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HymnsListProvider>(builder: (context, provider, child) {
      return HymnsListWidget(hymnsList: provider.hymnsList);
    });
  }
}
