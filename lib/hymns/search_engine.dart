import 'package:spiewnik_pielgrzyma/hymns/hymn.dart';

class HymnsSearchEngine {
  final double minimalScoreValue;

  HymnsSearchEngine({this.minimalScoreValue = 10.0});

  List<Hymn> search(List<Hymn> list, String query) {
    if (query.isEmpty) {
      return list;
    }

    List<(Hymn, double)> scoredHymns = list
        .map((hymn) => (hymn, calculateScore(hymn, query)))
        .where((element) => element.$2 >= minimalScoreValue)
        .toList();

    scoredHymns.sort((a, b) {
      if (a.$2 > b.$2) {
        return -1;
      }
      if (a.$2 < b.$2) {
        return 1;
      }
      return a.$1.index.compareTo(b.$1.index);
    });

    return scoredHymns.map((e) => e.$1).toList();
  }

  double calculateScore(Hymn hymn, String query) {
    double score = 0.0;

    if (query.isEmpty) {
      return score;
    }

    String cleanQuery =
        _removeSpecialCharacters(_removeAccents(query.toLowerCase()));
    String cleanTitle =
        _removeSpecialCharacters(_removeAccents(hymn.fullTitle.toLowerCase()));
    String cleanText = _removeSpecialCharacters(
        _removeAccents(hymn.text.join(' ').toLowerCase()));

    cleanQuery.split(' ').forEach((word) {
      if (hymn.number == word) {
        score += 100.0;
      }
      if (hymn.number.contains(word)) {
        score += 50.0;
      }
    });

    if (cleanTitle.contains(cleanQuery)) {
      score += 40.0;
    }
    if (cleanText.contains(cleanQuery)) {
      score += 10.0;
    }

    return score;
  }

  String _removeAccents(String input) {
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

  String _removeSpecialCharacters(String input) {
    return input
        .replaceAll(RegExp(r'[^a-zA-Z0-9 ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}
