import 'package:equatable/equatable.dart';

class Hymn extends Equatable {
  final String number;
  final String filename;
  final String title;
  final String group;
  final String subgroup;
  String? text;

  Hymn(this.number, this.filename, this.title, this.group, this.subgroup);

  String get fullTitle => "$number. $title";

  @override
  List<Object> get props => [number, filename, title, group, subgroup];
}
