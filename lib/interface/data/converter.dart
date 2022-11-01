import 'dart:convert';

import 'package:drift/drift.dart';

class StringEnumConverter<T extends Enum> extends TypeConverter<T, String> {
  const StringEnumConverter(this.values);

  final List<T> values;

  @override
  T fromSql(String fromDb) => values.asNameMap()[fromDb]!;

  @override
  String toSql(T value) => value.name;
}

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) => json.decode(fromDb).cast<String>();

  @override
  String toSql(List<String> value) => json.encode(value);
}
