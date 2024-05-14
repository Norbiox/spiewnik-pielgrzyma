import 'package:flutter_test/flutter_test.dart';

import 'package:spiewnik_pielgrzyma/domain/hymns/model.dart';

void main() {
  test("fullTitle should contain number and title - arabic number", () {
    Hymn hymn =
        Hymn("0", DateTime.now(), "1", "title", "group", "subgroup", []);
    expect(hymn.fullTitle, "1. title");
  });

  test("fullTitle should contain number and title - roman number", () {
    Hymn hymn =
        Hymn("0", DateTime.now(), "X", "title", "group", "subgroup", []);
    expect(hymn.fullTitle, "X. title");
  });
}
