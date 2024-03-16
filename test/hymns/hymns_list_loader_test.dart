import 'package:flutter_test/flutter_test.dart';
import 'package:spiewnik_pielgrzyma/hymns/hymn.dart';

import 'package:spiewnik_pielgrzyma/hymns/hymns_list_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized(); // needed for access to assets

  test('Loads hymns', () {
    final loader = HymnsListLoader();
    return loader.loadHymnsList().then((hymns) {
      expect(hymns, isNotEmpty);
      expect(
        hymns[0],
        Hymn("1", "001.txt", "Alleluja, chwalcie Pana", "I. Bóg Trójjedyny",
            "1. Chwała i dziękczynienie"),
      );
    });
  });
}
