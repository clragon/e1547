import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:e1547/history/history.dart';

part 'database.g.dart';

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) => json.decode(fromDb).cast<String>();

  @override
  String toSql(List<String> value) => json.encode(value);
}

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

@DriftDatabase(tables: [HistoriesTable])
class HistoriesDatabase extends _$HistoriesDatabase {
  HistoriesDatabase(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            String linkRegex = r'/posts\?tags=(?<tags>.+)';
            List<History> entries = await all(linkRegex: linkRegex).first;

            for (final entry in entries) {
              String tags =
                  RegExp(linkRegex).firstMatch(entry.link)!.namedGroup('tags')!;

              String decoded = Uri.decodeQueryComponent(tags);
              if (decoded != tags) {
                tags = decoded;
              }

              String link = Uri(
                path: '/posts',
                queryParameters: {'tags': tags},
              ).toString();

              await (update(historiesTable)
                    ..where((tbl) => tbl.id.equals(entry.id)))
                  .write(HistoryCompanion(
                link: Value(link),
              ));
            }
          }
        },
      );

  T _simplifyHost<T extends String?>(T host) {
    if (host == null) return null as T;
    return Uri.parse(host).host as T;
  }

  Expression<bool> _hostQuery($HistoriesTableTable tbl, String? host) =>
      Variable(host).isNull() | tbl.host.equalsNullable(_simplifyHost(host));

  Selectable<int> _lengthExpression({String? host}) {
    final Expression<int> count = historiesTable.id.count();
    final Expression<bool> hosted = _hostQuery(historiesTable, host);

    return (selectOnly(historiesTable)
          ..where(hosted)
          ..addColumns([count]))
        .map((row) => row.read(count)!);
  }

  Stream<int> length({String? host}) =>
      _lengthExpression(host: host).watchSingle();

  Stream<List<DateTime>> dates({String? host}) {
    final Expression<DateTime> time = historiesTable.visitedAt;
    final Expression<String> date = historiesTable.visitedAt.date;
    final Expression<bool> hosted = _hostQuery(historiesTable, host);

    return (selectOnly(historiesTable)
          ..where(hosted)
          ..orderBy([OrderingTerm(expression: time)])
          ..groupBy([date])
          ..addColumns([time]))
        .map((row) {
      DateTime source = row.read(time)!;
      return DateTime(source.year, source.month, source.day);
    }).watch();
  }

  Selectable<History> _itemExpression(int id) =>
      (select(historiesTable)..where((tbl) => tbl.id.equals(id)));

  Stream<History> get(int id) => _itemExpression(id).watchSingle();

  SimpleSelectStatement<HistoriesTable, History> _queryExpression({
    String? host,
    DateTime? day,
    String? linkRegex,
    String? titleRegex,
    String? subtitleRegex,
    int? limit,
    int? offset,
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
          day!,
          day.add(const Duration(days: 1, milliseconds: -1)),
        ),
      );
    }
    assert(
      offset == null || limit != null,
      'Cannot specify offset without limit!',
    );
    if (limit != null) {
      selectable.limit(limit, offset: offset);
    }
    return selectable;
  }

  Stream<List<History>> page({
    required int page,
    int? limit,
    String? host,
    DateTime? day,
    String? linkRegex,
    String? titleRegex,
    String? subtitleRegex,
  }) {
    limit ??= 80;
    int offset = (max(1, page) - 1) * limit;
    return _queryExpression(
      host: host,
      day: day,
      linkRegex: linkRegex,
      titleRegex: titleRegex,
      subtitleRegex: subtitleRegex,
      limit: limit,
      offset: offset,
    ).watch();
  }

  Stream<List<History>> all({
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

  Stream<List<History>> recent({
    String? host,
    int limit = 15,
    Duration maxAge = const Duration(minutes: 10),
  }) =>
      (_queryExpression(host: host)
            ..where((tbl) => (tbl.visitedAt
                .isBiggerThanValue(DateTime.now().subtract(maxAge))))
            ..limit(limit))
          .watch();

  Future<void> add(String host, HistoryRequest item) async =>
      into(historiesTable).insert(
        HistoryCompanion(
          host: Value(_simplifyHost(host)),
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
              host: Value(_simplifyHost(host)),
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
      (delete(historiesTable)..where((tbl) => tbl.id.equals(item.id))).go();

  Future<void> removeAll(List<History> items) async => (delete(historiesTable)
        ..where((tbl) => tbl.id.isIn(items.map((e) => e.id))))
      .go();

  Future<void> trim({
    String? host,
    required int maxAmount,
    required Duration maxAge,
  }) async =>
      transaction(() async {
        List<int> kept =
            (await recent(host: host, limit: maxAmount, maxAge: maxAge).first)
                .map((e) => e.id)
                .toList();
        await (delete(historiesTable)
              ..where((tbl) => tbl.host.equalsNullable(host))
              ..where((tbl) => tbl.id.isNotIn(kept)))
            .go();
      });
}
