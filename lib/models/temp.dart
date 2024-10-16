import 'package:isar/isar.dart';

part 'temp.g.dart';

@collection
class Temp {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  String? name;
}
