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

  String get fullTitle => "$number. $title";

  toggleIsFavorite() => isFavorite = !isFavorite!;
}
