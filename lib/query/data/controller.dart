import 'package:e1547/shared/shared.dart';
import 'package:flutter/foundation.dart';

export 'package:e1547/shared/data/map.dart';

class FilterController<T> extends ValueNotifier<QueryMap> {
  FilterController([QueryMap? value]) : super(value ?? {});

  QueryMap get query => value;

  QueryMap get request => value;

  set query(QueryMap newQuery) {
    if (mapEquals(query, newQuery)) return;
    value = newQuery.clone();
  }

  R? get<R>(String key) => query.get<R>(key);

  R? getEnum<R extends Enum>(String key, List<R> values) =>
      query.getEnum(key, values);

  void set(String key, Object? val) {
    final newQuery = query.clone();
    newQuery.set(key, val);
    query = newQuery;
  }

  bool has(String key) => get(key) != null;

  void clear() => query = {};

  List<List<T>> filter(List<List<T>> items) => items;
}
