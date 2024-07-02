import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:spiewnik_pielgrzyma/models/hymn.dart';
import 'package:spiewnik_pielgrzyma/objectbox.g.dart';

final getIt = GetIt.instance;

class ObjectBox {
  late final Store store;
  late final Box<Hymn> hymnBox;

  ObjectBox._create(this.store) {
    hymnBox = Box<Hymn>(store);
  }

  static Future<ObjectBox> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final store = await openStore(directory: p.join(docsDir.path, "objectbox"));
    return ObjectBox._create(store);
  }
}
