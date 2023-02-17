/// Map extension which returns all elements with non-null keys and values.
extension MapNotNull<K, V> on Map<K, V> {
  Iterable<MapEntry<K, V>> get whereNotNull =>
      entries.where((MapEntry<K, V> e) => e.key != null && e.value != null);
}
