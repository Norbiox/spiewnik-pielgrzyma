import 'package:sqflite/sqflite.dart';

void addIsFavoriteColumn(Batch batch) {
  batch.execute(
      'ALTER TABLE Hymns ADD COLUMN isFavorite INTEGER DEFAULT 0 NOT NULL CHECK (isFavorite IN (0, 1))');
}

String getHymnsList = '''
SELECT
  Hymns.id AS id,
  Hymns.number AS number,
  Hymns.title AS title,
  Hymns.isFavorite AS isFavorite,
  HymnSubgroups.id AS subgroupId,
  HymnSubgroups.name AS subgroupName,
  HymnGroups.id AS groupId,
  HymnGroups.name AS groupName
FROM Hymns
LEFT JOIN HymnSubgroups ON Hymns.groupId = HymnSubgroups.id
LEFT JOIN HymnGroups ON HymnSubgroups.groupId = HymnGroups.id;
''';
