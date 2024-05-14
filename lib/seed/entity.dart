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

  @override
  String toString() {
    return '{id: $id}';
  }

  @override
  bool operator ==(Object other) {
    if (other is Entity) {
      return other.runtimeType == runtimeType && other.id == id;
    }
    return false;
  }

  @override
  int get hashCode => id.hashCode;
}
