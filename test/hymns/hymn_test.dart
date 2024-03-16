import 'package:flutter_test/flutter_test.dart';

import 'package:spiewnik_pielgrzyma/hymns/hymn.dart';

void main() {
  test("fullTitle should contain number and title - arabic number", () {
    final Hymn hymn = Hymn("1", "title", "group", "subgroup");
    expect(hymn.fullTitle, "1. title");
  });

  test("fullTitle should contain number and title - roman number", () {
    final Hymn hymn = Hymn("X", "title", "group", "subgroup");
    expect(hymn.fullTitle, "X. title");
  });
}
