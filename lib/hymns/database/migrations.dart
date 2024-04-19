import 'package:sqflite/sqflite.dart';

void createHymnsGroupsTable(Batch batch) {
  batch.execute('DROP TABLE IF EXISTS HymnGroups');
  batch.execute('''CREATE TABLE HymnGroups (
    id INTEGER PRIMARY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE
  )''');
}

void createHymnsSubgroupsTable(Batch batch) {
  batch.execute('DROP TABLE IF EXISTS HymnSubgroups');
  batch.execute('''CREATE TABLE HymnsSubgroups (
    id INTEGER PRIMARY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    groupId INTEGER,
    FOREIGN KEY (groupId) REFERENCES HymnGroups(id) ON DELETE CASCADE
  )''');
}

void createHymnsTable(Batch batch) {
  batch.execute('DROP TABLE IF EXISTS Hymns');
  batch.execute('''CREATE TABLE Hymns (
    id INTEGER PRIMARY AUTOINCREMENT,
    number CHAR(3) UNIQUE,
    title TEXT NOT NULL,
    groupId INTEGER,
    FOREIGN KEY (groupId) REFERENCES HymnSubgroups(id) ON DELETE CASCADE
  )
''');
}
