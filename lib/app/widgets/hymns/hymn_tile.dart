import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/custom_lists/add_hymn_to_custom_list_dialog.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/hymns/favorite_icon.dart';
import 'package:spiewnik_pielgrzyma/models/hymn.dart';
import 'package:spiewnik_pielgrzyma/settings/font_size.dart';
import 'package:watch_it/watch_it.dart';

class HymnTileWidget extends WatchingWidget {
  final Hymn hymn;

  const HymnTileWidget({
    super.key,
    required this.hymn,
  });

  @override
  Widget build(BuildContext context) {
    final fontSizeProvider = GetIt.I<FontSizeProvider>();
    watch(fontSizeProvider);
    final baseFontSize =
        Theme.of(context).textTheme.bodyLarge?.fontSize ?? 16.0;
    final scaledSize = fontSizeProvider.scaledFontSize(baseFontSize);

    return ListTile(
      leading: FavoriteIconWidget(hymn: hymn),
      horizontalTitleGap: 0,
      title: Text(
        hymn.fullTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: scaledSize),
      ),
      onTap: () => context.push('/hymn/${hymn.id}'),
      onLongPress: () => showDialogWithCustomListsToAddTheHymnTo(context, hymn),
    );
  }
}
