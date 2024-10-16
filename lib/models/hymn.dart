import 'package:isar/isar.dart';

part 'hymn.g.dart';

@collection
class Hymn {
  Id id = Isar.autoIncrement;

  String? number;
  String? title;
  String? group;
  String? subgroup;
  List<String>? text;
  bool? isFavorite;

  Hymn(this.number, this.title, this.group, this.subgroup, this.text,
      {this.isFavorite = false});

  String get fullTitle => "$number. $title";

  String get pdfPath => 'assets/pdf/nuty-${number!.toUpperCase()}.pdf';

  toggleIsFavorite() => isFavorite = !isFavorite!;

  @override
  String toString() => 'Hymn $id - "$fullTitle"';
}
