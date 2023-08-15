import 'dart:collection';

abstract class TagSetBase with SetMixin<String> {
  (String, String?) split(String tag);

  String combine(String tag, String? value);

  int compare(String a, String b) => a.compareTo(b);

  late final SplayTreeSet<String> _tags = SplayTreeSet(compare);

  @override
  bool add(String value) => _tags.add(value);

  @override
  bool contains(Object? element) => _tags.contains(element);

  @override
  String? lookup(Object? element) => _tags.lookup(element);

  @override
  bool remove(Object? value) => _tags.remove(value);

  @override
  Iterator<String> get iterator => _tags.iterator;

  @override
  int get length => _tags.length;

  @override
  Set<String> toSet() => _tags.toSet();

  String? operator [](String key) {
    for (final tag in this) {
      final (name, value) = split(tag);
      if (name == key) return value;
    }
    return null;
  }

  void operator []=(String key, String? value) {
    for (final tag in this) {
      final (name, _) = split(tag);
      if (name == key) {
        remove(tag);
        add(combine(key, value));
        break;
      }
    }
  }

  bool containsKey(String key) {
    for (final tag in this) {
      final (name, _) = split(tag);
      if (name == key) return true;
    }
    return false;
  }

  Map<String, String?> toMap() =>
      toMapAll().map((name, values) => MapEntry(name, values.first));

  Map<String, List<String>> toMapAll() {
    final Map<String, List<String>> result = {};
    for (final tag in this) {
      final (name, value) = split(tag);
      result.putIfAbsent(name, () => []);
      if (value != null) {
        result[name]!.add(value);
      }
    }
    return result;
  }
}

class TagSet extends TagSetBase {
  TagSet();

  factory TagSet.from(Iterable<String> tags) => TagSet()..addAll(tags);

  factory TagSet.fromMap(Map<String, String?> tags) {
    TagSet set = TagSet();
    set.addAll(tags.entries.map((e) => set.combine(e.key, e.value)));
    return set;
  }

  factory TagSet.parse(String tags) =>
      TagSet.from(tags.trim().split(' ').where((e) => e.isNotEmpty));

  @override
  (String, String?) split(String tag) {
    List<String> result = tag.split(':');
    String? value;
    if (result.length > 1) {
      value = result.sublist(1).join(':');
    }
    return (result[0], value);
  }

  @override
  String combine(String tag, String? value) =>
      value == null ? tag : '$tag:$value';

  String _prefixOf(String tag) {
    if (tag.startsWith('-') || tag.startsWith('~')) {
      return tag[0];
    }
    return '';
  }

  @override
  int compare(String a, String b) {
    final (_, valueA) = split(a);
    final (_, valueB) = split(b);

    if (valueA != null && valueB == null) return -1;
    if (valueA == null && valueB != null) return 1;

    String? prefixA = _prefixOf(a);
    String? prefixB = _prefixOf(b);

    if (prefixA != prefixB) {
      if (prefixA == '') return -1;
      if (prefixB == '') return 1;
      return prefixA.compareTo(prefixB);
    }

    return a.compareTo(b);
  }

  @override
  String toString() => join(' ');
}

extension TagSetLink on TagSet {
  String get link => '/posts?tags=${toString()}';
}
