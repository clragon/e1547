import 'dart:collection';

import 'package:collection/collection.dart';

class TagMap extends DelegatingMap<String, String?> {
  TagMap() : super(SplayTreeMap<String, String?>(_tagComparator));

  factory TagMap.from(Map<String, String?> tags) {
    final map = TagMap();
    tags.forEach((key, value) => map[key] = value);
    return map;
  }

  factory TagMap.parse(String value) {
    final map = TagMap();
    for (final tag in value.split(' ').where((e) => e.trim().isNotEmpty)) {
      final parts = tag.split(':');
      final name = parts.first;
      final tagValue = parts.length > 1 ? parts[1] : null;
      map[name] = tagValue;
    }
    return map;
  }

  static int _tagComparator(String a, String b) {
    int getPrefixValue(String prefix) {
      switch (prefix[0]) {
        case '-':
          return 1;
        case '~':
          return 0;
        default:
          return -1;
      }
    }

    int firstValue = getPrefixValue(a);
    int secondValue = getPrefixValue(b);

    if (firstValue != secondValue) {
      return firstValue.compareTo(secondValue);
    } else {
      return a.compareTo(b);
    }
  }

  String? getTag(String key) =>
      this[key] != null ? '$key:${this[key]}' : this[key];

  Iterable<String> getTags() => keys.map(getTag).whereType<String>();

  @override
  String toString() => getTags().join(' ');
}

extension TagMapLink on TagMap {
  String get link => '/posts?tags=${toString()}';
}
