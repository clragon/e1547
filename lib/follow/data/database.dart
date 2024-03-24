import 'dart:math';

import 'package:drift/drift.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/identity/data/database.dart';
import 'package:e1547/interface/interface.dart';

// ignore: always_use_package_imports
import 'database.drift.dart';

@UseRowClass(Follow, generateInsertable: true)
class FollowsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tags => text()();
  TextColumn get title => text().nullable()();
  TextColumn get alias => text().nullable()();
  TextColumn get type => textEnum<FollowType>()();
  IntColumn get latest => integer().nullable()();
  IntColumn get unseen => integer().nullable()();
  TextColumn get thumbnail => text().nullable()();
  DateTimeColumn get updated => dateTime().nullable()();
}

@DataClassName('FollowIdentity')
class FollowsIdentitiesTable extends Table {
  IntColumn get identity => integer().references(IdentitiesTable, #id,
      onDelete: KeyAction.noAction, onUpdate: KeyAction.noAction)();
  IntColumn get follow => integer().references(FollowsTable, #id,
      onDelete: KeyAction.cascade, onUpdate: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {identity, follow};
}

@DriftAccessor(tables: [
  FollowsTable,
  FollowsIdentitiesTable,
  IdentitiesTable,
])
class FollowRepository extends DatabaseAccessor<GeneratedDatabase>
    with $FollowRepositoryMixin {
  FollowRepository({
    required GeneratedDatabase database,
    required this.identity,
  }) : super(database);

  final int? identity;

  Expression<bool> _identityQuery($FollowsTableTable tbl, int? identity) {
    final subQuery = followsIdentitiesTable.selectOnly()
      ..addColumns([followsIdentitiesTable.follow])
      ..where(Variable(identity).isNull() |
          followsIdentitiesTable.identity.equalsNullable(identity));

    return tbl.id.isInQuery(subQuery);
  }

  StreamFuture<int> length() {
    final Expression<int> count = followsTable.id.count();
    final Expression<bool> identified = _identityQuery(followsTable, identity);

    return (selectOnly(followsTable)
          ..where(identified)
          ..addColumns([count]))
        .map((row) => row.read(count)!)
        .watchSingle()
        .future;
  }

  StreamFuture<Follow> get(int id) {
    return (select(followsTable)..where((tbl) => tbl.id.equals(id)))
        .watchSingle()
        .future;
  }

  SimpleSelectStatement<FollowsTable, Follow> _queryExpression({
    String? tagRegex,
    String? titleRegex,
    List<FollowType>? types,
    bool? hasUnseen,
    int? limit,
    int? offset,
  }) {
    final selectable = select(followsTable)
      ..orderBy([
        (t) => OrderingTerm(expression: t.latest, mode: OrderingMode.desc),
        (t) => OrderingTerm(
            expression: coalesce([t.title, t.tags]), mode: OrderingMode.desc)
      ])
      ..where((tbl) => _identityQuery(tbl, identity));
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
    if (hasUnseen ?? false) {
      selectable.where((tbl) => tbl.unseen.isBiggerThanValue(0));
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

  StreamFuture<List<Follow>> page({
    required int page,
    int? limit,
    String? tagRegex,
    String? titleRegex,
    List<FollowType>? types,
    bool? hasUnseen,
  }) {
    limit ??= 80;
    int offset = (max(1, page) - 1) * limit;
    return _queryExpression(
      tagRegex: tagRegex,
      titleRegex: titleRegex,
      types: types,
      hasUnseen: hasUnseen,
      limit: limit,
      offset: offset,
    ).watch().future;
  }

  StreamFuture<List<Follow>> all({
    String? tagRegex,
    String? titleRegex,
    List<FollowType>? types,
    bool? hasUnseen,
    int? limit,
  }) =>
      _queryExpression(
        tagRegex: tagRegex,
        titleRegex: titleRegex,
        types: types,
        hasUnseen: hasUnseen,
        limit: limit,
      ).watch().future;

  StreamFuture<List<Follow>> outdated({
    required Duration minAge,
    List<FollowType>? types,
  }) =>
      (_queryExpression(types: types)
            ..where((tbl) =>
                (tbl.updated
                    .isSmallerThanValue(DateTime.now().subtract(minAge))) |
                tbl.updated.isNull()))
          .watch()
          .future;

  StreamFuture<List<Follow>> fresh({
    List<FollowType>? types,
  }) =>
      (_queryExpression(types: types)..where((tbl) => tbl.updated.isNull()))
          .watch()
          .future;

  StreamFuture<List<Follow>> unseen() =>
      (_queryExpression()..where((tbl) => (tbl.unseen.isBiggerThanValue(0))))
          .watch()
          .future;

  Future<void> markAsSeen() => (update(followsTable)
        ..where((tbl) => _identityQuery(tbl, identity))
        ..where((tbl) => (tbl.unseen.isBiggerThanValue(0))))
      .write(const FollowCompanion(unseen: Value(0)));

  Future<void> add(FollowRequest item, {int? identity}) async {
    if (this.identity == null && identity == null) {
      throw ArgumentError('Cannot add follow without identity!');
    }

    Follow follow;
    Follow? existing = await _queryExpression(
      tagRegex: r'^' + RegExp.escape(item.tags) + r'$',
    ).getSingleOrNull();
    if (existing != null) {
      follow = existing.copyWith(
        title: item.title,
        alias: item.alias,
        type: item.type,
      );
      await replace(follow);
    } else {
      follow = await into(followsTable).insertReturning(
        FollowCompanion(
          tags: Value(item.tags),
          title: Value(item.title),
          alias: Value(item.alias),
          type: Value(item.type),
        ),
        mode: InsertMode.insertOrIgnore,
      );
      await into(followsIdentitiesTable).insert(
        FollowIdentityCompanion(
          identity: Value(this.identity ?? identity!),
          follow: Value(follow.id),
        ),
      );
    }
  }

  Future<void> replace(Follow item) =>
      ((update(followsTable))..where((tbl) => tbl.id.equals(item.id)))
          .write(item.toInsertable());

  Future<void> remove(int id) =>
      (delete(followsTable)..where((tbl) => tbl.id.equals(id))).go();
}
