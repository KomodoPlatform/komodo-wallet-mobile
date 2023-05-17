//========= Collection-related methods inspired by package:collection ==========
// Could be replaced with package:collection in the future.

/// Utilties for working with collections which can return null.
/// Inspired by package:collection.
extension IterableUtils<T> on Iterable<T> {
  /// Returns the element at the given [index] in the [iterable], or `null` if the
  /// [index] is out of bounds.
  T? elementAtOrNull(int index) {
    if (index >= 0) {
      int i = 0;
      for (final T? element in this) {
        if (i == index) return element;
        i++;
      }
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

  /// Returns the i'th element in the list or the last element if the index is
  /// out of bounds.
  T elementAtOrLast(int index) {
    if (index >= 0) {
      int i = 0;
      for (final T element in this) {
        if (i == index) return element;
        i++;
      }
    }
    return last;
  }
}

/// Utilties for working with iterables where the elements can be null.
extension IterableNullableUtils<T> on Iterable<T?> {
  /// Returns all non-null elements of the given [iterable].
  Iterable<T> whereNotNull() sync* {
    for (var element in this) {
      if (element != null) yield element;
    }
  }
}

/// Convenience utilities for working with list that use IterableNullableUtils
extension ListNullableUtils<T> on List<T?> {
  /// Returns all non-null elements of the given [iterable].
  List<T> whereNotNull() {
    return IterableNullableUtils(this).whereNotNull().toList();
  }
}




//
//===========================================================================