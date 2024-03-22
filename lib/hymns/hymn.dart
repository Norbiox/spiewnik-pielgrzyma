import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';

class Hymn extends Equatable {
  final String number;
  final String filename;
  final String title;
  final String group;
  final String subgroup;

  Hymn(this.number, this.filename, this.title, this.group, this.subgroup);

  String get fullTitle => "$number. $title";

  Future<List<String>> getText() async {
    final String text = await rootBundle.loadString("assets/texts/" + filename);
    return text.split('\n').sublist(1);
  }

  @override
  List<Object> get props => [number, filename, title, group, subgroup];
}
