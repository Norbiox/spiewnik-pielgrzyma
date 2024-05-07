import 'package:spiewnik_pielgrzyma/seed/entity.dart';

class Hymn extends Entity {
  final String number;
  final String title;
  final String group;
  final String subgroup;
  final List<String> text;
  bool _isFavorite;

  Hymn(super.id, super.modifiedAt, this.number, this.title, this.group,
      this.subgroup, this.text,
      [this._isFavorite = false]);

  String get fullTitle => "$number. $title";

  bool get isFavorite => _isFavorite;

  toggleIsFavorite() {
    recordModificationTime(() {
      _isFavorite = !_isFavorite;
    });
  }
}
