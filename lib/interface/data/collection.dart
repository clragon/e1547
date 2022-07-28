extension UnmodifiableList<T> on List<T>? {
  /// Returns an unmodifiable version of this List or null.
  List<T>? maybeUnmodifiable() {
    return this != null ? List.unmodifiable(this!) : null;
  }
}

extension UnmodifiableMap<K, V> on Map<K, V>? {
  /// Returns an unmodifiable version of this Map or null.
  Map<K, V>? maybeUnmodifiable() {
    return this != null ? Map.unmodifiable(this!) : null;
  }
}
