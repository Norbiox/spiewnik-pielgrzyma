import 'package:objectbox/objectbox.dart';

@Entity()
class Hymn {
  @Id()
  int id = 0;

  String? number;
  String? title;
  String? group;
  String? subgroup;
  List<String>? text;
  bool? isFavorite;

  Hymn(this.number, this.title, this.group, this.subgroup, this.text,
      {this.isFavorite = false});

  String get fullTitle => "$number. $title";

  String get pdfPath => 'assets/pdf/nuty-${int.parse(number!) + 15}.pdf';

  toggleIsFavorite() => isFavorite = !isFavorite!;

  @override
  String toString() => 'Hymn $id - "$fullTitle"';
}
