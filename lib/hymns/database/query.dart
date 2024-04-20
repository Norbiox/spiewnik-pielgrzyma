String getHymnsList = '''
SELECT
  Hymns.id AS id,
  Hymns.number AS number,
  Hymns.title AS title,
  HymnSubgroups.id AS subgroupId,
  HymnSubgroups.name AS subgroupName,
  HymnGroups.id AS groupId,
  HymnGroups.name AS groupName
FROM Hymns
LEFT JOIN HymnSubgroups ON Hymns.groupId = HymnSubgroups.id
LEFT JOIN HymnGroups ON HymnSubgroups.groupId = HymnGroups.id;
''';

String getHymns = 'SELECT * FROM Hymns;';
