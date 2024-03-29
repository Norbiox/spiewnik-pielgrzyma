import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/favorites/icon_widget.dart';
import 'package:spiewnik_pielgrzyma/hymns/hymn.dart';
import 'package:spiewnik_pielgrzyma/hymns/hymn_page.dart';

class HymnTileWidget extends StatelessWidget {
  final Hymn hymn;

  const HymnTileWidget({super.key, required this.hymn});

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: FavoriteIconWidget(hymn: hymn),
        title: Text(
          hymn.fullTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => HymnPage(hymn: hymn),
          ));
        });
  }
}
