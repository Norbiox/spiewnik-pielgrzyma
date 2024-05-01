import 'package:clock/clock.dart';

typedef EntityId = String;

class Entity {
  final EntityId id;
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
