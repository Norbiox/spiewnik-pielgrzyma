import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:spiewnik_pielgrzyma/app/providers/hymns/provider.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/custom_lists/add_hymn_to_custom_list_dialog.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/hymns/favorite_icon.dart';
import 'package:spiewnik_pielgrzyma/models/hymn.dart';
import 'package:go_router/go_router.dart';

class HymnTileWidget extends StatelessWidget {
  final HymnsListProvider provider = GetIt.I<HymnsListProvider>();
  final int hymnId;

  HymnTileWidget({
    super.key,
    required this.hymnId,
  });

  @override
  Widget build(BuildContext context) {
    final Hymn hymn = provider.getHymn(hymnId);

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
