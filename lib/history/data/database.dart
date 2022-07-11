import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';

part 'database.g.dart';

@UseRowClass(History, generateInsertable: true)
class HistoriesTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get host => text()();
  DateTimeColumn get visitedAt => dateTime()();
  TextColumn get link => text()();
  TextColumn get thumbnails => text().map(const StringListConverter())();
  TextColumn get title => text().nullable()();
  TextColumn get subtitle => text().nullable()();
}

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String>? mapToDart(String? fromDb) {
    if (fromDb == null) {
      return null;
    }
    return json.decode(fromDb).cast<String>();
  }

  @override
  String? mapToSql(List<String>? value) {
    if (value == null) {
      return null;
    }
    return json.encode(value);
  }
}

@DriftDatabase(tables: [HistoriesTable])
class HistoriesDatabase extends _$HistoriesDatabase {
  static const String _defaultName = 'history.sqlite';

  HistoriesDatabase({String? path}) : super(openDatabase(path ?? _defaultName));

  HistoriesDatabase.connect({String? path})
      : super.connect(connectDatabase(path ?? _defaultName));

  @override
  int get schemaVersion => 1;

  Expression<bool?> _hostQuery($HistoriesTableTable tbl, String? host) =>
      Variable(host).isNull() | tbl.host.equals(host);

  Future<int> length({String? host}) async {
    final Expression<int> count = historiesTable.id.count();
    final Expression<bool?> hosted = _hostQuery(historiesTable, host);

    return (selectOnly(historiesTable)
          ..where(hosted)
          ..addColumns([count]))
        .map((row) => row.read(count))
        .getSingle();
  }

  Future<History> get(int id) async =>
      (select(historiesTable)..where((tbl) => tbl.id.equals(id))).getSingle();

  Future<List<History>> page({
    String? host,
    int page = 1,
    int limit = 80,
    String? linkRegex,
    DateTime? day,
  }) async {
    final selectable = select(historiesTable)
      ..where((tbl) => _hostQuery(tbl, host));
    if (linkRegex != null) {
      selectable.where((tbl) => tbl.link.regexp(linkRegex));
    }
    if (day != null) {
      selectable.where((tbl) => tbl.visitedAt.equals(day));
    }
    selectable.limit(page, offset: (page - 1) * max(limit, 320));
    return selectable.get();
  }

  Future<List<History>> getRecent({
    String? host,
    int range = 15,
    Duration maxAge = const Duration(minutes: 10),
  }) =>
      (select(historiesTable)
            ..where((tbl) => _hostQuery(tbl, host))
            ..orderBy([(t) => OrderingTerm(expression: t.visitedAt)])
            ..where((tbl) => (tbl.visitedAt.secondsSinceEpoch -
                    Variable(DateTime.now().millisecondsSinceEpoch ~/ 1000))
                .abs()
                .isSmallerOrEqual(Variable(maxAge.inSeconds)))
            ..limit(range))
          .get();

  Future<void> add(String host, HistoryRequest item) async =>
      into(historiesTable).insert(
        HistoryCompanion(
          host: Value(host),
          visitedAt: Value(item.visitedAt),
          link: Value(item.link),
          thumbnails: Value(item.thumbnails),
          title: Value(item.title),
          subtitle: Value(item.subtitle),
        ),
      );

  Future<void> addAll(String host, List<HistoryRequest> items) async => batch(
        (batch) => batch.insertAll(
          historiesTable,
          items.map(
            (item) => HistoryCompanion(
              host: Value(host),
              visitedAt: Value(item.visitedAt),
              link: Value(item.link),
              thumbnails: Value(item.thumbnails),
              title: Value(item.title),
              subtitle: Value(item.subtitle),
            ),
          ),
        ),
      );

  Future<void> remove(History item) async =>
      await (delete(historiesTable)..where((tbl) => tbl.id.equals(item.id)))
          .go();

  Future<void> removeAll(List<History> items) async =>
      await (delete(historiesTable)
            ..where((tbl) => tbl.id.isIn(items.map((e) => e.id))))
          .go();

  Future<void> trim({
    String? host,
    required int maxAmount,
    required Duration maxAge,
  }) async {
    List<int?> kept =
        (await getRecent(host: host, range: maxAmount, maxAge: maxAge))
            .map((e) => e.id)
            .toList();
    await (delete(historiesTable)..where((tbl) => tbl.id.isNotIn(kept))).go();
  }
}
