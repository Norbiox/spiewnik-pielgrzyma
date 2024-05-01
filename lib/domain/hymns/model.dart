class Hymn {
  final int id;
  final String number;
  final String filename;
  final String title;
  final String group;
  final String subgroup;
  final List<String> text;
  bool isFavorite;

  Hymn(this.id, this.number, this.filename, this.title, this.group,
      this.subgroup, this.text,
      {this.isFavorite = false});

  String get fullTitle => "$number. $title";
}