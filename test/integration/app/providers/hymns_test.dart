import 'package:flutter_test/flutter_test.dart';
import 'package:spiewnik_pielgrzyma/app/providers/hymns/search_engine.dart';
import 'package:spiewnik_pielgrzyma/domain/hymns/model.dart';

void main() {
  group('Test SearchEngine', () {
    HymnsSearchEngine engine = HymnsSearchEngine();
    List<Hymn> hymns = [
      Hymn("0", DateTime.now(), "1", "Pieśń pierwsza", "group", "subgroup",
          ["Jednak", "druga"]),
      Hymn("1", DateTime.now(), "2", "Pieśń druga", "group", "subgroup", []),
      Hymn("2", DateTime.now(), "10", "Pieśń dziesiąta", "group", "subgroup",
          []),
      Hymn("3", DateTime.now(), "20", "Pieśń dwudziesta", "group", "subgroup",
          ["Niechaj teraz, za Twą wolą"]),
    ];

    test("should return full list if query is empty", () {
      expect(engine.search(hymns, ""), hymns);
    });

    test("should order hymns by score", () {
      expect(engine.search(hymns, "2"), <Hymn>[hymns[1], hymns[3]]);
    });

    test("should order hymns with same score by index", () {
      expect(engine.search(hymns, "pieśń"), hymns);
    });

    test("should ignore polish letters", () {
      expect(engine.search(hymns, "piesn"), hymns);
    });

    test("should find by part of word", () {
      expect(engine.search(hymns, "ier"), <Hymn>[hymns[0]]);
    });

    test("should score by part of title higher than part of text", () {
      expect(engine.search(hymns, "druga"), <Hymn>[hymns[1], hymns[0]]);
    });

    test("should ignore special characters", () {
      expect(engine.search(hymns, "teraz za twa"), <Hymn>[hymns[3]]);
    });
  });
}
