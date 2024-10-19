import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/custom_lists/add_hymn_to_custom_list_dialog.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/hymns/favorite_icon.dart';
import 'package:spiewnik_pielgrzyma/models/hymn.dart';
import 'package:go_router/go_router.dart';

class HymnTileWidget extends StatelessWidget {
  final Hymn hymn;

  const HymnTileWidget({
    super.key,
    required this.hymn,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: FavoriteIconWidget(hymn: hymn),
      horizontalTitleGap: 0,
      title: Text(
        hymn.fullTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => context.go('/${hymn.id}'),
      onLongPress: () => showDialogWithCustomListsToAddTheHymnTo(context, hymn),
    );
  }
}
