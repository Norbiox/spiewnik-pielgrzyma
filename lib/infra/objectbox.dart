import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:spiewnik_pielgrzyma/models/custom_list.dart';
import 'package:spiewnik_pielgrzyma/models/hymn.dart';
import 'package:spiewnik_pielgrzyma/objectbox.g.dart';

final getIt = GetIt.instance;

class ObjectBox {
  late final Store store;
  late final Box<Hymn> hymnBox;
  late final Box<CustomList> customListBox;

  ObjectBox._create(this.store) {
    hymnBox = Box<Hymn>(store);
    customListBox = Box<CustomList>(store);
  }

  static Future<ObjectBox> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final store = await openStore(directory: p.join(docsDir.path, "objectbox"));
    ObjectBox instance = ObjectBox._create(store);
    await instance._loadHymns();
    return instance;
  }

  _loadHymns() async {
    // Loads hymns from hymns.csv and texts files into ObjectBox
    // only on first run, when ObjectBox collection is empty
    if (hymnBox.count() > 0) return;

    final String hymnsData = await rootBundle.loadString('assets/hymns.csv');
    final List<List<String>> hymnsDetails =
        const CsvToListConverter(fieldDelimiter: ',', shouldParseNumbers: false)
            .convert(hymnsData);

    for (final hymnDetails in hymnsDetails.sublist(1)) {
      String filename = "assets/texts/${hymnDetails[0]}.txt";
      String rawText = await rootBundle.loadString(filename);
      Hymn hymn = Hymn(
        hymnDetails[0],
        hymnDetails[1],
        hymnDetails[2],
        hymnDetails[3],
        rawText.split('\n').sublist(1),
      );
      hymnBox.put(hymn);
    }
  }
}
