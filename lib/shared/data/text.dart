extension StringListTrimming on List<String> {
  /// Trims all strings in the list and removes empty strings.
  List<String> trim() =>
      map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
}
