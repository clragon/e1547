import 'dart:convert';

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

  Selectable<int> _lengthExpression({String? host}) {
    final Expression<int> count = historiesTable.id.count();
    final Expression<bool?> hosted = _hostQuery(historiesTable, host);

    return (selectOnly(historiesTable)
          ..where(hosted)
          ..addColumns([count]))
        .map((row) => row.read(count));
  }

  Future<int> length({String? host}) async =>
      _lengthExpression(host: host).getSingle();
  Stream<int> watchLength({String? host}) =>
      _lengthExpression(host: host).watchSingle();

  Future<List<DateTime>> dates({String? host}) async {
    final Expression<DateTime?> time = historiesTable.visitedAt;
    final Expression<bool?> hosted = _hostQuery(historiesTable, host);

    List<DateTime?> results = await (selectOnly(historiesTable)
          ..where(hosted)
          ..orderBy([OrderingTerm(expression: time)])
          ..addColumns([time]))
        .map((row) => row.read(time))
        .get();
    results.removeWhere((e) => e == null);
    return results.cast<DateTime>();
  }

  Selectable<History> _itemExpression(int id) =>
      (select(historiesTable)..where((tbl) => tbl.id.equals(id)));

  Future<History> get(int id) async => _itemExpression(id).getSingle();
  Stream<History> watch(int id) => _itemExpression(id).watchSingle();

  SimpleSelectStatement<HistoriesTable, History> _queryExpression({
    String? host,
    DateTime? day,
    String? linkRegex,
    String? titleRegex,
    String? subtitleRegex,
    int? limit,
  }) {
    final selectable = select(historiesTable)
      ..orderBy([
        (t) => OrderingTerm(expression: t.visitedAt, mode: OrderingMode.desc)
      ])
      ..where((tbl) => _hostQuery(tbl, host));
    if (linkRegex != null) {
      selectable
          .where((tbl) => tbl.link.regexp(linkRegex, caseSensitive: false));
    }
    if (titleRegex != null) {
      selectable
          .where((tbl) => tbl.title.regexp(titleRegex, caseSensitive: false));
    }
    if (subtitleRegex != null) {
      selectable.where(
          (tbl) => tbl.subtitle.regexp(subtitleRegex, caseSensitive: false));
    }
    if (day != null) {
      day = DateTime(day.year, day.month, day.day);
      selectable.where(
        (tbl) => tbl.visitedAt.isBetweenValues(
          day,
          day!.add(const Duration(days: 1, milliseconds: -1)),
        ),
      );
    }
    if (limit != null) {
      selectable.limit(limit);
    }
    return selectable;
  }

  Future<List<History>> getAll({
    String? host,
    DateTime? day,
    String? linkRegex,
    String? titleRegex,
    String? subtitleRegex,
    int? limit,
  }) =>
      _queryExpression(
        host: host,
        day: day,
        linkRegex: linkRegex,
        titleRegex: titleRegex,
        subtitleRegex: subtitleRegex,
        limit: limit,
      ).get();

  Stream<List<History>> watchAll({
    String? host,
    DateTime? day,
    String? linkRegex,
    String? titleRegex,
    String? subtitleRegex,
    int? limit,
  }) =>
      _queryExpression(
        host: host,
        day: day,
        linkRegex: linkRegex,
        titleRegex: titleRegex,
        subtitleRegex: subtitleRegex,
        limit: limit,
      ).watch();

  Future<List<History>> getRecent({
    String? host,
    int limit = 15,
    Duration maxAge = const Duration(minutes: 10),
  }) =>
      (_queryExpression(host: host)
            ..where((tbl) => (tbl.visitedAt
                .isBiggerThanValue(DateTime.now().subtract(maxAge))))
            ..limit(limit))
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
        (await getRecent(host: host, limit: maxAmount, maxAge: maxAge))
            .map((e) => e.id)
            .toList();
    await (delete(historiesTable)
          ..where((tbl) => tbl.host.equals(host))
          ..where((tbl) => tbl.id.isNotIn(kept)))
        .go();
  }
}
