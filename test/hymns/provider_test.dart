import 'package:flutter_test/flutter_test.dart';
import 'package:spiewnik_pielgrzyma/hymns/model/hymn.dart';

import 'package:spiewnik_pielgrzyma/hymns/lib/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized(); // needed for access to assets

  test('Loads hymns', () {
    return loadHymnsList().then((hymns) {
      expect(hymns, isNotEmpty);
      expect(
        hymns[0],
        const Hymn(
          0,
          "1",
          "001.txt",
          "Alleluja, chwalcie Pana",
          "I. Bóg Trójjedyny",
          "1. Chwała i dziękczynienie",
          [],
        ),
      );
    });
  });
}
