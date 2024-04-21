import 'package:sqflite/sqflite.dart';

void addIsFavoriteColumn(Batch batch) {
  batch.execute(
      'ALTER TABLE Hymns ADD COLUMN isFavorite INTEGER DEFAULT 0 NOT NULL CHECK (isFavorite IN (0, 1))');
}
