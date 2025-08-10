import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/cupertino.dart';

@optionalTypeArgs
class JsonSqlConverter<T> extends TypeConverter<T, String> {
  const JsonSqlConverter({this.decode});

  static JsonSqlConverter<List<R>> list<R>() => JsonSqlConverter<List<R>>(
    decode: (value) => (value as List<dynamic>).cast<R>(),
  );

  static JsonSqlConverter<Map<String, R>> map<R>() =>
      JsonSqlConverter<Map<String, R>>(
        decode: (value) => (value as Map<String, dynamic>)
            .map((key, dynamicValue) => MapEntry(key, dynamicValue as R))
            .cast(),
      );

  final T Function(dynamic value)? decode;

  @override
  T fromSql(String fromDb) {
    final dynamic value = json.decode(fromDb);
    if (decode != null) {
      return decode!(value);
    }
    return value as T;
  }

  @override
  String toSql(T value) => json.encode(value);
}
