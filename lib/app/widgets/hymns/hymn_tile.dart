import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/hymns/favorite_icon.dart';
import 'package:spiewnik_pielgrzyma/domain/hymns/model.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/hymns/hymn_page.dart';

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
