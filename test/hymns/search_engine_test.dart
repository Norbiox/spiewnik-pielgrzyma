import 'package:flutter_test/flutter_test.dart';
import 'package:spiewnik_pielgrzyma/hymns/hymn.dart';
import 'package:spiewnik_pielgrzyma/hymns/search_engine.dart';

void main() {
  HymnsSearchEngine engine = HymnsSearchEngine();
  const List<Hymn> hymns = [
    Hymn(0, "1", "001.txt", "Pieśń pierwsza", "group", "subgroup",
        ["Jednak", "druga"]),
    Hymn(1, "2", "002.txt", "Pieśń druga", "group", "subgroup", []),
    Hymn(2, "10", "010.txt", "Pieśń dziesiąta", "group", "subgroup", []),
    Hymn(3, "20", "020.txt", "Pieśń dwudziesta", "group", "subgroup", []),
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
}
