extension MapUtils<K, V> on Map<K, V> {
  /// Map extension which returns all elements with non-null keys and values.
  Map<K, V> whereNotNull() {
    return Map.fromEntries(
      entries.where((entry) => entry.key != null && entry.value != null),
    );
  }
}
