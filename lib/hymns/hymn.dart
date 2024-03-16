class Hymn {
  final String number;
  final String title;
  final String group;
  final String subgroup;
  String? text;

  Hymn(this.number, this.title, this.group, this.subgroup);

  String get fullTitle => "$number. $title";
}
