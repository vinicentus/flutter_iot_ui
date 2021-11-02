extension contains on List {
  bool containsElementAt(int index) {
    RangeError.checkNotNegative(index, "index");
    return index < this.length;
  }
}
