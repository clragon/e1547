import 'dart:math';

import 'package:drift/drift.dart';
import 'package:e1547/follow/data/client.drift.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/identity/data/database.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/stream/stream.dart';
import 'package:e1547/tag/tag.dart';

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
  IntColumn get identity => integer().references(
    IdentitiesTable,
    #id,
    onDelete: KeyAction.noAction,
    onUpdate: KeyAction.noAction,
  )();
  IntColumn get follow => integer().references(
    FollowsTable,
    #id,
    onDelete: KeyAction.cascade,
    onUpdate: KeyAction.cascade,
  )();

  @override
  Set<Column> get primaryKey => {identity, follow};
}

@DriftAccessor(tables: [FollowsTable, FollowsIdentitiesTable, IdentitiesTable])
class FollowClient extends DatabaseAccessor<GeneratedDatabase>
    with $FollowClientMixin {
  FollowClient({required GeneratedDatabase database}) : super(database);

  StreamFuture<Follow> get(int id) => (select(
    followsTable,
  )..where((tbl) => tbl.id.equals(id))).watchSingle().future;

  StreamFuture<Follow?> getByTags(String tags, int identity) =>
      (select(followsTable)
            ..where((tbl) => _identityQuery(tbl, identity))
            ..where((tbl) => tbl.tags.equals(tags)))
          .watchSingleOrNull()
          .future;

  Expression<bool> _identityQuery($FollowsTableTable tbl, int? identity) {
    final subQuery = followsIdentitiesTable.selectOnly()
      ..addColumns([followsIdentitiesTable.follow])
      ..where(
        Variable(identity).isNull() |
            followsIdentitiesTable.identity.equalsNullable(identity),
      );

    return tbl.id.isInQuery(subQuery);
  }

  SimpleSelectStatement<FollowsTable, Follow> _querySelect({
    int? limit,
    int? offset,
    int? identity,
    QueryMap? query,
  }) {
    final FollowParams(:tags, :title, :types, :hasUnseen) = FollowParams(
      value: query,
    );
    final String? tagRegex = tags?.infixRegex;
    final String? titleRegex = title?.infixRegex;

    final selectable = select(followsTable)
      ..orderBy([
        (t) => OrderingTerm(expression: t.latest, mode: OrderingMode.desc),
        (t) => OrderingTerm(
          expression: coalesce([t.title, t.tags]),
          mode: OrderingMode.desc,
        ),
      ])
      ..where((tbl) => _identityQuery(tbl, identity));
    if (tagRegex != null) {
      selectable.where(
        (tbl) => tbl.tags.regexp(tagRegex, caseSensitive: false),
      );
    }
    if (titleRegex != null) {
      selectable.where(
        (tbl) => tbl.title.regexp(titleRegex, caseSensitive: false),
      );
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
    int? page,
    int? limit,
    int? identity,
    QueryMap? query,
  }) {
    page ??= 1;
    limit ??= 75;
    int offset = (max(1, page) - 1) * limit;
    return _querySelect(
      limit: limit,
      offset: offset,
      identity: identity,
      query: query,
    ).watch().future;
  }

  StreamFuture<List<Follow>> all({
    int? limit,
    int? identity,
    QueryMap? query,
  }) => _querySelect(
    limit: limit,
    identity: identity,
    query: query,
  ).watch().future;

  StreamFuture<int> length({int? identity}) {
    final Expression<int> count = followsTable.id.count();
    final Expression<bool> identified = _identityQuery(followsTable, identity);

    return (selectOnly(followsTable)
          ..where(identified)
          ..addColumns([count]))
        .map((row) => row.read(count)!)
        .watchSingle()
        .future;
  }

  StreamFuture<List<Follow>> outdated({
    required Duration minAge,
    List<FollowType>? types,
    int? identity,
  }) =>
      (_querySelect(
            identity: identity,
            query: types != null
                ? (FollowParams()..types = types.toSet()).query
                : null,
          )..where(
            (tbl) =>
                (tbl.updated.isSmallerThanValue(
                  DateTime.now().subtract(minAge),
                )) |
                tbl.updated.isNull(),
          ))
          .watch()
          .future;

  StreamFuture<List<Follow>> fresh({List<FollowType>? types, int? identity}) =>
      (_querySelect(
        identity: identity,
        query: types != null
            ? (FollowParams()..types = types.toSet()).query
            : null,
      )..where((tbl) => tbl.updated.isNull())).watch().future;

  Future<void> add(FollowRequest item, int identity) async {
    Follow follow;
    Follow? existing = await _querySelect(
      identity: identity,
      query: (FollowParams()..tags = item.tags).query,
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
          identity: Value(identity),
          follow: Value(follow.id),
        ),
      );
    }
  }

  Future<void> markAllSeen({List<int>? ids, int? identity}) =>
      (update(followsTable)
            ..where((tbl) => _identityQuery(tbl, identity))
            ..where((tbl) => Variable(ids).isNull() | tbl.id.isIn(ids ?? []))
            ..where((tbl) => (tbl.unseen.isBiggerThanValue(0))))
          .write(const FollowCompanion(unseen: Value(0)));

  Future<void> replace(Follow item) => ((update(
    followsTable,
  ))..where((tbl) => tbl.id.equals(item.id))).write(item.toInsertable());

  Future<void> remove(int id) =>
      (delete(followsTable)..where((tbl) => tbl.id.equals(id))).go();

  Future<void> updateFollow(FollowUpdate update) => transaction(() async {
    await ((this.update(
      followsTable,
    ))..where((tbl) => tbl.id.equals(update.id))).write(
      FollowCompanion(
        title: update.title != null
            ? Value(update.title!.nullWhenEmpty)
            : const Value.absent(),
        type: update.type != null ? Value(update.type!) : const Value.absent(),
      ),
    );
    if (update.tags?.nullWhenEmpty != null) {
      await ((this.update(
        followsTable,
      ))..where((tbl) => tbl.id.equals(update.id))).write(
        FollowCompanion(
          tags: Value(update.tags!),
          updated: const Value(null),
          unseen: const Value(null),
          thumbnail: const Value(null),
          latest: const Value(null),
        ),
      );
    }
  });

  Future<void> syncWith({required int id, List<Post>? posts, Pool? pool}) =>
      ((update(followsTable))..where((tbl) => tbl.id.equals(id))).write(
        FollowCompanion(
          latest: posts?.isNotEmpty ?? false
              ? Value(posts!.first.id)
              : const Value.absent(),
          thumbnail: posts?.isNotEmpty ?? false
              ? Value(posts!.first.sample)
              : const Value.absent(),
          title: pool?.name != null
              ? Value(tagToName(pool!.name))
              : const Value.absent(),
        ),
      );
}
