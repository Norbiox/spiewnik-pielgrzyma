import 'package:sqflite/sqflite.dart';

void createCustomListsTable(Batch batch) {
  batch.execute('''CREATE TABLE CustomLists (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    orderingIndex INTEGER NOT NULL UNIQUE,
    createdAt TEXT NOT NULL,
    modifiedAt TEXT NOT NULL
    )''');
}
