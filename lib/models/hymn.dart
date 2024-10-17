class Hymn {
  final int id;
  final String number;
  final String title;
  final String group;
  final String subgroup;
  final List<String> text;
  bool isFavorite;

  Hymn(this.id, this.number, this.title, this.group, this.subgroup, this.text,
      {this.isFavorite = false});

  String get fullTitle => "$number. $title";

  String get pdfPath => 'assets/pdf/nuty-${number.toUpperCase()}.pdf';

  void toggleIsFavorite() => isFavorite = !isFavorite;

  @override
  String toString() => 'Hymn $number - "$fullTitle"';
}
