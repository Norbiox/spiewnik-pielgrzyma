import 'dart:io';

import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiewnik_pielgrzyma/models/temp.dart';

Future<Isar> initIsar(
    Directory documentsDirectory, SharedPreferences sharedPreferences) async {
  final Isar isar = await Isar.open(
    [TempSchema],
    directory: documentsDirectory.path,
  );

  if (sharedPreferences.getInt('isar_schema_version') == null) {
    sharedPreferences.setInt('isar_schema_version', 1);
  }

  return isar;
}
