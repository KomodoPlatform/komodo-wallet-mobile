
//========= Collection-related methods inspired by package:collection ==========
// Could be replaced with package:collection in the future.

/// Utilties for working with collections, inspired by package:collection.
extension IterableUtils<T> on Iterable<T> {
  /// Returns the element at the given [index] in the [iterable], or `null` if the
  /// [index] is out of bounds.
  T? elementAtOrNull(int index) {
    if (index < 0) return null;
    for (final T element in this) {
      if (index == 0) return element;
      index--;
    }
    return null;
  }

  /// Returns the first element that satisfies the given [predicate], or `null` if
  /// no element satisfies the predicate.
  T? firstWhereOrNull(bool Function(T element) predicate) {
    for (final T element in this) {
      if (predicate(element)) return element;
    }
    return null;
  }
}

//
//===========================================================================