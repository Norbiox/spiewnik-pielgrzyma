import 'dart:collection';

class ListOfBigNumbers extends ListBase<int> {
  List<int> innerList = [];

  ListOfBigNumbers();

  @override
  int get length => innerList.length;

  @override
  set length(int newLength) {
    innerList.length = newLength;
  }

  @override
  int operator [](int index) => innerList[index];

  @override
  void operator []=(int index, int value) {
    innerList[index] = value;
  }

  @override
  void add(int value) {
    if (value < 1000000) {
      throw ArgumentError("Value is not big enough");
    }
    innerList.add(value);
  }
}
