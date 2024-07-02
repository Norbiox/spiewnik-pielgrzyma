import 'package:objectbox/objectbox.dart';
import 'package:spiewnik_pielgrzyma/models/hymn.dart';

@Entity()
class CustomList {
  @Id()
  int id = 0;

  String? name;

  CustomList(this.name);

  final hymns = ToMany<Hymn>();
}
