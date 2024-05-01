import 'package:sqflite/sqflite.dart';

void createCustomListsTable(Batch batch) {
  batch.execute('''CREATE TABLE CustomLists (
    id TEXT PRIMARY KEY UNIQUE,
    name TEXT NOT NULL UNIQUE,
    createdAt TEXT NOT NULL,
    modifiedAt TEXT NOT NULL
    )''');
}
