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

  TextColumn get type =>
      text().map(const StringEnumConverter(FollowType.values))();

  IntColumn get latest => integer().nullable()();

  IntColumn get unseen => integer().nullable()();

  TextColumn get thumbnail => text().nullable()();

  DateTimeColumn get updated => dateTime().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {host, tags}
      ];
}

class StringEnumConverter<T extends Enum> extends TypeConverter<T, String> {
  const StringEnumConverter(this.values);

  final List<T> values;

  @override
  T fromSql(String fromDb) => values.asNameMap()[fromDb]!;

  @override
  String toSql(T value) => value.name;
}

@DriftDatabase(tables: [FollowsTable])
class FollowsDatabase extends _$FollowsDatabase {
  FollowsDatabase(super.e);

  FollowsDatabase.connect(super.e) : super.connect();

  @override
  int get schemaVersion => 1;

  Expression<bool> _hostQuery($FollowsTableTable tbl, String? host) =>
      Variable(host).isNull() | tbl.host.equalsNullable(host);

  Selectable<int> _lengthExpression({String? host}) {
    final Expression<int> count = followsTable.id.count();
    final Expression<bool> hosted = _hostQuery(followsTable, host);

    return (selectOnly(followsTable)
          ..where(hosted)
          ..addColumns([count]))
        .map((row) => row.read(count)!);
  }

  Future<int> length({String? host}) =>
      _lengthExpression(host: host).getSingle();

  Stream<int> watchLength({String? host}) =>
      _lengthExpression(host: host).watchSingle();

  Selectable<Follow> _itemExpression(int id) =>
      (select(followsTable)..where((tbl) => tbl.id.equals(id)));

  Future<Follow> get(int id) async => _itemExpression(id).getSingle();

  Stream<Follow> watch(int id) => _itemExpression(id).watchSingle();

  SimpleSelectStatement<FollowsTable, Follow> _queryExpression({
    String? host,
    String? tagRegex,
    String? titleRegex,
    FollowType? type,
    int? limit,
    int? offset,
  }) {
    final selectable = select(followsTable)
      ..orderBy([
        (t) => OrderingTerm(expression: t.unseen, mode: OrderingMode.desc),
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
    if (type != null) {
      selectable.where((tbl) => tbl.type.equals(type.name));
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

  Future<List<Follow>> page({
    required int page,
    int? limit,
    String? host,
    String? tagRegex,
    String? titleRegex,
    FollowType? type,
  }) {
    limit ??= 80;
    int offset = (max(1, page) - 1) * limit;
    return _queryExpression(
      host: host,
      tagRegex: tagRegex,
      titleRegex: titleRegex,
      type: type,
      limit: limit,
      offset: offset,
    ).get();
  }

  Future<List<Follow>> getAll({
    String? host,
    String? tagRegex,
    String? titleRegex,
    FollowType? type,
    int? limit,
  }) =>
      _queryExpression(
        host: host,
        tagRegex: tagRegex,
        titleRegex: titleRegex,
        type: type,
        limit: limit,
      ).get();

  Stream<List<Follow>> watchAll({
    String? host,
    String? tagRegex,
    String? titleRegex,
    FollowType? type,
    int? limit,
  }) =>
      _queryExpression(
        host: host,
        tagRegex: tagRegex,
        titleRegex: titleRegex,
        type: type,
        limit: limit,
      ).watch();

  Future<List<Follow>> getOutdated({
    String? host,
    required Duration minAge,
  }) =>
      (_queryExpression(host: host)
            ..where((tbl) =>
                (tbl.updated
                    .isSmallerThanValue(DateTime.now().subtract(minAge))) |
                tbl.updated.isNull()))
          .get();

  Future<List<Follow>> getUnseen({
    String? host,
  }) =>
      watchUnseen(host: host).first;

  Stream<List<Follow>> watchUnseen({String? host}) =>
      (_queryExpression(host: host)
            ..where((tbl) => (tbl.unseen.isBiggerThanValue(0))))
          .watch();

  Future<void> markAllAsRead({String? host}) => (update(followsTable)
        ..where((tbl) => _hostQuery(tbl, host))
        ..where((tbl) => (tbl.unseen.isBiggerThanValue(0))))
      .write(const FollowCompanion(unseen: Value(0)));

  Future<void> add(String host, FollowRequest item) =>
      into(followsTable).insert(
        FollowCompanion(
          host: Value(host),
          tags: Value(item.tags),
          title: Value(item.title),
          type: Value(item.type),
        ),
        mode: InsertMode.insertOrIgnore,
      );

  Future<void> addAll(String host, List<FollowRequest> items) => batch(
        (batch) => batch.insertAll(
          followsTable,
          items.map(
            (item) => FollowCompanion(
              host: Value(host),
              tags: Value(item.tags),
              title: Value(item.title),
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
