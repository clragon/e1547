class Tag {
  final String name;
  final String value;

  Tag(this.name, [this.value]);

  factory Tag.parse(String tag) {
    assert(tag != null, "Can't parse a null tag.");
    assert(tag.trim().isNotEmpty, "Can't parse an empty tag.");
    List<String> components = tag.trim().split(':');
    assert(components.length == 1 || components.length == 2);

    String name = components[0];
    String value = components.length == 2 ? components[1] : null;
    return Tag(name, value);
  }

  @override
  String toString() => value == null ? name : '$name:$value';

  @override
  bool operator ==(dynamic other) => // ignore: avoid_annotating_with_dynamic
      other is Tag && name == other.name && value == other.value;

  @override
  int get hashCode => toString().hashCode;
}
