/// Moves an item in a fixed-length list to a new index.
///
/// This function takes a list and two indices, `oldIndex` and `newIndex`,
/// and moves the item at `oldIndex` to `newIndex`. If the indices are the same,
/// the function returns the original list.
///
/// The function handles both forward and backward movements within the list.
///
/// Example usage:
/// ```dart
List<T> moveItem<T>(List<T> list, int oldIndex, int newIndex) {
  if (oldIndex == newIndex) return list;

  final length = list.length;
  final newList = List<T?>.filled(length, null);
  final item = list[oldIndex];

  if (oldIndex < newIndex) {
    newIndex -= 1;
    // Moving forward
    for (int i = 0; i < length; i++) {
      if (i < oldIndex || i > newIndex) {
        newList[i] = list[i];
      } else if (i < newIndex) {
        newList[i] = list[i + 1];
      } else if (i == newIndex) {
        newList[i] = item;
      }
    }
  } else {
    // Moving backward
    for (int i = 0; i < length; i++) {
      if (i < newIndex || i > oldIndex) {
        newList[i] = list[i];
      } else if (i > newIndex && i <= oldIndex) {
        newList[i] = list[i - 1];
      } else if (i == newIndex) {
        newList[i] = item;
      }
    }
  }

  return newList.cast<T>();
}
