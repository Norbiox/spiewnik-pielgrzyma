import 'package:clock/clock.dart';

class Entity {
  final String id;
  DateTime modifiedAt;

  Entity(this.id, this.modifiedAt);

  void recordModificationTime(void Function() body) {
    try {
      body();
      modifiedAt = clock.now();
    } catch (err) {
      rethrow;
    }
  }
}
