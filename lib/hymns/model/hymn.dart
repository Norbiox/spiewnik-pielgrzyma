import 'package:equatable/equatable.dart';

class Hymn extends Equatable {
  final int index;
  final String number;
  final String filename;
  final String title;
  final String group;
  final String subgroup;
  final List<String> text;

  const Hymn(this.index, this.number, this.filename, this.title, this.group,
      this.subgroup, this.text);

  String get fullTitle => "$number. $title";

  @override
  List<Object> get props => [number, filename, title, group, subgroup];
}
