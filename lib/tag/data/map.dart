import 'dart:collection';

import 'package:collection/collection.dart';

class TagMap extends DelegatingMap<String, String?> {
  TagMap() : super(SplayTreeMap<String, String?>(_tagComparator));

  factory TagMap.from(Map<String, String?> tags) => TagMap()..addAll(tags);

  static TagMap parse(String value) {
    TagMap map = TagMap();
    RegExp tagRegex = RegExp(r'^(?<name>[^:]+)(:(?<value>[^:]*))?$');
    for (final tag in value.split(' ').where((e) => e.trim().isNotEmpty)) {
      RegExpMatch? match = tagRegex.firstMatch(tag);
      if (match == null) {
        throw FormatException(
          'Failed to parse tag',
          value,
          value.indexOf(tag),
        );
      }
      String name = match.namedGroup('name')!.toLowerCase();
      String? tagValue = match.namedGroup('value')?.toLowerCase();
      if (tagValue?.isEmpty ?? false) tagValue = null;
      map[name] = tagValue;
    }
    return map;
  }

  static TagMap? tryParse(String value) {
    try {
      return TagMap.parse(value);
    } on FormatException {
      return null;
    }
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

  String? getTag(String key) => this[key] != null ? '$key:${this[key]}' : key;

  Iterable<String> getTags() => keys.map(getTag).whereType<String>();

  @override
  String toString() => getTags().join(' ');
}

extension TagMapLink on TagMap {
  String get link => '/posts?tags=${toString()}';
}
