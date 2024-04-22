import 'dart:math';

import 'package:drift/drift.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/identity/data/database.dart';
import 'package:e1547/interface/interface.dart';

// ignore: always_use_package_imports
import 'database.drift.dart';

@UseRowClass(History, generateInsertable: true)
class HistoriesTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get visitedAt => dateTime()();
  TextColumn get link => text()();
  TextColumn get category => textEnum<HistoryCategory>()();
  TextColumn get type => textEnum<HistoryType>()();
  TextColumn get title => text().nullable()();
  TextColumn get subtitle => text().nullable()();
  TextColumn get thumbnails => text().map(JsonSqlConverter.list<String>())();
}

@DataClassName('HistoryIdentity')
class HistoriesIdentitiesTable extends Table {
  IntColumn get identity => integer().references(IdentitiesTable, #id,
      onDelete: KeyAction.noAction, onUpdate: KeyAction.noAction)();
  IntColumn get history => integer().references(HistoriesTable, #id,
      onDelete: KeyAction.cascade, onUpdate: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {identity, history};
}

@DriftAccessor(tables: [
  HistoriesTable,
  HistoriesIdentitiesTable,
  IdentitiesTable,
])
class HistoryRepository extends DatabaseAccessor<GeneratedDatabase>
    with $HistoryRepositoryMixin {
  HistoryRepository({required GeneratedDatabase database}) : super(database);

  StreamFuture<History> get(int id) =>
      (select(historiesTable)..where((tbl) => tbl.id.equals(id)))
          .watchSingle()
          .future;

  Expression<bool> _identityQuery($HistoriesTableTable tbl, int? identity) {
    final subQuery = historiesIdentitiesTable.selectOnly()
      ..addColumns([historiesIdentitiesTable.history])
      ..where(Variable(identity).isNull() |
          historiesIdentitiesTable.identity.equalsNullable(identity));

    return tbl.id.isInQuery(subQuery);
  }

  SimpleSelectStatement<HistoriesTable, History> _querySelect({
    int? limit,
    int? offset,
    int? identity,
    String? link,
    String? title,
    String? subtitle,
    Set<HistoryCategory>? category,
    Set<HistoryType>? type,
    DateTime? day,
    Duration? maxAge,
  }) {
    final selectable = select(historiesTable)
      ..orderBy([
        (t) => OrderingTerm(expression: t.visitedAt, mode: OrderingMode.desc)
      ])
      ..where((tbl) => _identityQuery(tbl, identity));
    if (link != null) {
      selectable.where((tbl) => tbl.link.regexp(link, caseSensitive: false));
    }
    if (title != null) {
      selectable.where((tbl) => tbl.title.regexp(title, caseSensitive: false));
    }
    if (subtitle != null) {
      selectable
          .where((tbl) => tbl.subtitle.regexp(subtitle, caseSensitive: false));
    }
    if (category != null) {
      selectable.where((tbl) => tbl.category.isIn(category.map((e) => e.name)));
    }
    if (type != null) {
      selectable.where((tbl) => tbl.type.isIn(type.map((e) => e.name)));
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
    if (maxAge != null) {
      selectable.where((tbl) =>
          tbl.visitedAt.isBiggerThanValue(DateTime.now().subtract(maxAge)));
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

  StreamFuture<List<History>> page({
    int? page,
    int? limit,
    int? identity,
    DateTime? day,
    String? link,
    String? title,
    String? subtitle,
    Set<HistoryCategory>? category,
    Set<HistoryType>? type,
  }) {
    page ??= 1;
    limit ??= 80;
    int offset = (max(1, page) - 1) * limit;
    return _querySelect(
      limit: limit,
      offset: offset,
      identity: identity,
      day: day,
      link: link,
      title: title,
      subtitle: subtitle,
      category: category,
      type: type,
    ).watch().future;
  }

  StreamFuture<int> length({int? identity}) {
    final Expression<int> count = historiesTable.id.count();
    final Expression<bool> identified =
        _identityQuery(historiesTable, identity);

    return (selectOnly(historiesTable)
          ..where(identified)
          ..addColumns([count]))
        .map((row) => row.read(count)!)
        .watchSingle()
        .future;
  }

  StreamFuture<List<DateTime>> days({int? identity}) {
    final Expression<DateTime> time = historiesTable.visitedAt;
    final Expression<String> date = historiesTable.visitedAt.date;
    final Expression<bool> identified =
        _identityQuery(historiesTable, identity);

    return (selectOnly(historiesTable)
          ..where(identified)
          ..orderBy([OrderingTerm(expression: time)])
          ..groupBy([date])
          ..addColumns([time]))
        .map((row) {
          DateTime source = row.read(time)!;
          return DateTime(source.year, source.month, source.day);
        })
        .watch()
        .future;
  }

  Future<bool> isDuplicate(HistoryRequest item) =>
      (_querySelect(limit: 1, maxAge: const Duration(minutes: 3))
            ..where((tbl) => tbl.link.equals(item.link))
            ..where((tbl) => tbl.title.equalsNullable(item.title))
            ..where((tbl) => tbl.category.equals(item.category.name))
            ..where((tbl) => tbl.type.equals(item.type.name))
            ..where((tbl) => tbl.subtitle.equalsNullable(item.subtitle))
            ..where((tbl) => tbl.thumbnails.equalsNullable(
                JsonSqlConverter.list().toSql(item.thumbnails))))
          .get()
          .then((e) => e.isNotEmpty);

  Future<void> add(HistoryRequest item, int identity) async {
    History history = await into(historiesTable).insertReturning(
      HistoryCompanion(
        visitedAt: Value(item.visitedAt),
        link: Value(item.link),
        category: Value(item.category),
        type: Value(item.type),
        thumbnails: Value(item.thumbnails),
        title: Value(item.title),
        subtitle: Value(item.subtitle),
      ),
    );
    await into(historiesIdentitiesTable).insert(
      HistoryIdentityCompanion(
        identity: Value(identity),
        history: Value(history.id),
      ),
    );
  }

  Future<void> remove(int id) => removeAll([id]);

  Future<void> removeAll(List<int>? ids, {int? identity}) =>
      (delete(historiesTable)
            ..where((tbl) => _identityQuery(tbl, identity))
            ..where((tbl) => Variable(ids).isNull() | tbl.id.isIn(ids!)))
          .go();

  Future<void> trim({
    required int maxAmount,
    required Duration maxAge,
    int? identity,
  }) =>
      transaction(
        () => (delete(historiesTable)
              ..where((tbl) => _identityQuery(tbl, identity))
              ..where(
                (tbl) => tbl.id.isNotInQuery(
                  _querySelect(
                    limit: maxAmount,
                    maxAge: maxAge,
                    identity: identity,
                  ),
                ),
              ))
            .go(),
      );
}
