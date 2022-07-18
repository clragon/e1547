import 'package:e1547/interface/interface.dart';

class Tagset extends Iterable<StringTag> {
  final Map<String, StringTag> _tags;

  Tagset(Set<StringTag> tags) : _tags = {for (final t in tags) t.name: t};

  Tagset.parse(String tagString) : _tags = {} {
    for (final ts in tagString.split(' ').trim()) {
      if (ts.trim().isEmpty) {
        continue;
      }
      StringTag t = StringTag.parse(ts);
      _tags[t.name] = t;
    }
  }

  String get link => '/posts?tags=${toString()}';

  @override
  bool contains(Object? element) => _tags.containsKey(element);

  String? operator [](String? name) {
    StringTag? t = _tags[name!];
    if (t == null) {
      return null;
    }

    return t.value;
  }

  void operator []=(String name, String? value) {
    _tags[name] = StringTag(name, value);
  }

  void remove(String? name) {
    _tags.remove(name);
  }

  @override
  Iterator<StringTag> get iterator => _tags.values.iterator;

  @override
  String toString() {
    List<StringTag> meta = [];
    List<StringTag> normal = [];

    for (StringTag t in _tags.values) {
      if (t.value != null) {
        meta.add(t);
      } else {
        normal.add(t);
      }
    }

    // normal tags, then optional, then subtracting
    int order(StringTag a, StringTag b) {
      int getPrefixValue(String prefix) {
        switch (prefix) {
          case '-':
            return 1;
          case '~':
            return 0;
          default:
            return -1;
        }
      }

      int firstValue = getPrefixValue(a.name[0]);
      int secondValue = getPrefixValue(b.name[0]);
      return firstValue.compareTo(secondValue);
    }

    normal.sort(order);
    meta.sort(order);

    // meta tags first
    List<StringTag> output = [];
    output.addAll(meta);
    output.addAll(normal);
    return output.join(' ');
  }
}

class StringTag {
  final String name;
  final String? value;

  StringTag(this.name, [this.value]);

  factory StringTag.parse(String tag) {
    assert(tag.trim().isNotEmpty, "Can't parse an empty tag.");
    List<String> components = tag.trim().split(':');
    assert(components.length == 1 || components.length == 2);

    String name = components[0];
    String? value = components.length == 2 ? components[1] : null;
    return StringTag(name, value);
  }

  @override
  String toString() => '$name${value != null ? ':$value' : ''}';

  @override
  bool operator ==(Object other) =>
      other is StringTag && name == other.name && value == other.value;

  @override
  int get hashCode => toString().hashCode;
}
