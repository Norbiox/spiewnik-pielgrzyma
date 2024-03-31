import 'package:spiewnik_pielgrzyma/hymns/hymn.dart';

class HymnsSearchEngine {
  static List<Hymn> search(List<Hymn> list, String query) {
    return list
        .where((element) =>
            _removePolishCharacters(element.fullTitle.toLowerCase())
                .contains(_removePolishCharacters(query.toLowerCase())))
        .toList();
  }

  static String _removePolishCharacters(String input) {
    Map<String, String> polishCharactersMap = {
      'ą': 'a',
      'ć': 'c',
      'ę': 'e',
      'ł': 'l',
      'ń': 'n',
      'ó': 'o',
      'ś': 's',
      'ź': 'z',
      'ż': 'z',
      'Ą': 'A',
      'Ć': 'C',
      'Ę': 'E',
      'Ł': 'L',
      'Ń': 'N',
      'Ó': 'O',
      'Ś': 'S',
      'Ź': 'Z',
      'Ż': 'Z'
    };

    polishCharactersMap.forEach((key, value) {
      input = input.replaceAll(RegExp(key), value);
    });

    return input;
  }
}
