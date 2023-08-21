import 'dart:math';

import 'package:drift/drift.dart';
import 'package:e1547/follow/follow.dart';

part 'database.g.dart';

@UseRowClass(Follow, generateInsertable: true)
class FollowsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get host => text()();
  TextColumn get tags => text()();
  TextColumn get title => text().nullable()();
  TextColumn get alias => text().nullable()();
  TextColumn get type => textEnum<FollowType>()();
  IntColumn get latest => integer().nullable()();
  IntColumn get unseen => integer().nullable()();
  TextColumn get thumbnail => text().nullable()();
  DateTimeColumn get updated => dateTime().nullable()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {host, tags}
      ];
}

@DriftDatabase(tables: [FollowsTable])
class FollowsDatabase extends _$FollowsDatabase {
  FollowsDatabase(super.e);

  @override
  int get schemaVersion => 1;

  T _simplifyHost<T extends String?>(T host) {
    if (host == null) return null as T;
    return Uri.parse(host).host as T;
  }

  Expression<bool> _hostQuery($FollowsTableTable tbl, String? host) =>
      Variable(host).isNull() | tbl.host.equalsNullable(_simplifyHost(host));

  Selectable<int> _lengthExpression({String? host}) {
    final Expression<int> count = followsTable.id.count();
    final Expression<bool> hosted = _hostQuery(followsTable, host);

    return (selectOnly(followsTable)
          ..where(hosted)
          ..addColumns([count]))
        .map((row) => row.read(count)!);
  }

  Stream<int> length({String? host}) =>
      _lengthExpression(host: host).watchSingle();

  Selectable<Follow> _itemExpression(int id) =>
      (select(followsTable)..where((tbl) => tbl.id.equals(id)));

  Stream<Follow> get(int id) => _itemExpression(id).watchSingle();

  SimpleSelectStatement<FollowsTable, Follow> _queryExpression({
    String? host,
    String? tagRegex,
    String? titleRegex,
    List<FollowType>? types,
    int? limit,
    int? offset,
  }) {
    final selectable = select(followsTable)
      ..orderBy([
        (t) => OrderingTerm(expression: t.latest, mode: OrderingMode.desc),
        (t) => OrderingTerm(
            expression: coalesce([t.title, t.tags]), mode: OrderingMode.desc)
      ])
      ..where((tbl) => _hostQuery(tbl, host));
    if (tagRegex != null) {
      selectable
          .where((tbl) => tbl.tags.regexp(tagRegex, caseSensitive: false));
    }
    if (titleRegex != null) {
      selectable
          .where((tbl) => tbl.title.regexp(titleRegex, caseSensitive: false));
    }
    if (types != null) {
      selectable.where((tbl) => tbl.type.isIn(types.map((e) => e.name)));
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

  Stream<List<Follow>> page({
    required int page,
    int? limit,
    String? host,
    String? tagRegex,
    String? titleRegex,
    List<FollowType>? types,
  }) {
    limit ??= 80;
    int offset = (max(1, page) - 1) * limit;
    return _queryExpression(
      host: host,
      tagRegex: tagRegex,
      titleRegex: titleRegex,
      types: types,
      limit: limit,
      offset: offset,
    ).watch();
  }

  Stream<List<Follow>> all({
    String? host,
    String? tagRegex,
    String? titleRegex,
    List<FollowType>? types,
    int? limit,
  }) =>
      _queryExpression(
        host: host,
        tagRegex: tagRegex,
        titleRegex: titleRegex,
        types: types,
        limit: limit,
      ).watch();

  Stream<List<Follow>> outdated({
    String? host,
    required Duration minAge,
    List<FollowType>? types,
  }) =>
      (_queryExpression(host: host, types: types)
            ..where((tbl) =>
                (tbl.updated
                    .isSmallerThanValue(DateTime.now().subtract(minAge))) |
                tbl.updated.isNull()))
          .watch();

  Stream<List<Follow>> fresh({
    String? host,
    List<FollowType>? types,
  }) =>
      (_queryExpression(host: host, types: types)
            ..where((tbl) => tbl.updated.isNull()))
          .watch();

  Stream<List<Follow>> unseen({
    String? host,
  }) =>
      (_queryExpression(host: host)
            ..where((tbl) => (tbl.unseen.isBiggerThanValue(0))))
          .watch();

  Future<void> markAsSeen({String? host}) => (update(followsTable)
        ..where((tbl) => _hostQuery(tbl, host))
        ..where((tbl) => (tbl.unseen.isBiggerThanValue(0))))
      .write(const FollowCompanion(unseen: Value(0)));

  Future<void> add(String host, FollowRequest item) =>
      into(followsTable).insert(
        FollowCompanion(
          host: Value(_simplifyHost(host)),
          tags: Value(item.tags),
          title: Value(item.title),
          alias: Value(item.alias),
          type: Value(item.type),
        ),
        mode: InsertMode.insertOrIgnore,
      );

  Future<void> addAll(String host, List<FollowRequest> items) => batch(
        (batch) => batch.insertAll(
          followsTable,
          items.map(
            (item) => FollowCompanion(
              host: Value(_simplifyHost(host)),
              tags: Value(item.tags),
              title: Value(item.title),
              alias: Value(item.alias),
              type: Value(item.type),
            ),
          ),
          mode: InsertMode.insertOrIgnore,
        ),
      );

  Future<void> replace(Follow item) =>
      ((update(followsTable))..where((tbl) => tbl.id.equals(item.id)))
          .write(item.toInsertable());

  Future<void> remove(Follow item) =>
      (delete(followsTable)..where((tbl) => tbl.id.equals(item.id))).go();

  Future<void> removeAll(List<Follow> items) => (delete(followsTable)
        ..where((tbl) => tbl.id.isIn(items.map((e) => e.id))))
      .go();
}
