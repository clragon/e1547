// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:drift/src/runtime/api/runtime_api.dart' as i1;
import 'package:e1547/follow/data/client.drift.dart' as i2;
import 'package:drift/internal/modular.dart' as i3;
import 'package:e1547/identity/data/database.drift.dart' as i4;
import 'package:e1547/follow/data/follow.dart' as i5;
import 'package:e1547/follow/data/client.dart' as i6;

typedef $$FollowsTableTableCreateCompanionBuilder =
    i2.FollowCompanion Function({
      i0.Value<int> id,
      required String tags,
      i0.Value<String?> title,
      i0.Value<String?> alias,
      required i5.FollowType type,
      i0.Value<int?> latest,
      i0.Value<int?> unseen,
      i0.Value<String?> thumbnail,
      i0.Value<DateTime?> updated,
    });
typedef $$FollowsTableTableUpdateCompanionBuilder =
    i2.FollowCompanion Function({
      i0.Value<int> id,
      i0.Value<String> tags,
      i0.Value<String?> title,
      i0.Value<String?> alias,
      i0.Value<i5.FollowType> type,
      i0.Value<int?> latest,
      i0.Value<int?> unseen,
      i0.Value<String?> thumbnail,
      i0.Value<DateTime?> updated,
    });

final class $$FollowsTableTableReferences
    extends
        i0.BaseReferences<
          i0.GeneratedDatabase,
          i2.$FollowsTableTable,
          i5.Follow
        > {
  $$FollowsTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static i0.MultiTypedResultKey<
    i2.$FollowsIdentitiesTableTable,
    List<i2.FollowIdentity>
  >
  _followsIdentitiesTableRefsTable(i0.GeneratedDatabase db) =>
      i0.MultiTypedResultKey.fromTable(
        i3.ReadDatabaseContainer(db).resultSet<i2.$FollowsIdentitiesTableTable>(
          'follows_identities_table',
        ),
        aliasName: i0.$_aliasNameGenerator(
          i3.ReadDatabaseContainer(
            db,
          ).resultSet<i2.$FollowsTableTable>('follows_table').id,
          i3.ReadDatabaseContainer(db)
              .resultSet<i2.$FollowsIdentitiesTableTable>(
                'follows_identities_table',
              )
              .follow,
        ),
      );

  i2.$$FollowsIdentitiesTableTableProcessedTableManager
  get followsIdentitiesTableRefs {
    final manager = i2
        .$$FollowsIdentitiesTableTableTableManager(
          $_db,
          i3.ReadDatabaseContainer(
            $_db,
          ).resultSet<i2.$FollowsIdentitiesTableTable>(
            'follows_identities_table',
          ),
        )
        .filter((f) => f.follow.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _followsIdentitiesTableRefsTable($_db),
    );
    return i0.ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FollowsTableTableFilterComposer
    extends i0.Composer<i0.GeneratedDatabase, i2.$FollowsTableTable> {
  $$FollowsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get alias => $composableBuilder(
    column: $table.alias,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnWithTypeConverterFilters<i5.FollowType, i5.FollowType, String>
  get type => $composableBuilder(
    column: $table.type,
    builder: (column) => i0.ColumnWithTypeConverterFilters(column),
  );

  i0.ColumnFilters<int> get latest => $composableBuilder(
    column: $table.latest,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<int> get unseen => $composableBuilder(
    column: $table.unseen,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get thumbnail => $composableBuilder(
    column: $table.thumbnail,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<DateTime> get updated => $composableBuilder(
    column: $table.updated,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.Expression<bool> followsIdentitiesTableRefs(
    i0.Expression<bool> Function(
      i2.$$FollowsIdentitiesTableTableFilterComposer f,
    )
    f,
  ) {
    final i2.$$FollowsIdentitiesTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: i3.ReadDatabaseContainer($db)
              .resultSet<i2.$FollowsIdentitiesTableTable>(
                'follows_identities_table',
              ),
          getReferencedColumn: (t) => t.follow,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => i2.$$FollowsIdentitiesTableTableFilterComposer(
                $db: $db,
                $table: i3.ReadDatabaseContainer($db)
                    .resultSet<i2.$FollowsIdentitiesTableTable>(
                      'follows_identities_table',
                    ),
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$FollowsTableTableOrderingComposer
    extends i0.Composer<i0.GeneratedDatabase, i2.$FollowsTableTable> {
  $$FollowsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get alias => $composableBuilder(
    column: $table.alias,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<int> get latest => $composableBuilder(
    column: $table.latest,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<int> get unseen => $composableBuilder(
    column: $table.unseen,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get thumbnail => $composableBuilder(
    column: $table.thumbnail,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<DateTime> get updated => $composableBuilder(
    column: $table.updated,
    builder: (column) => i0.ColumnOrderings(column),
  );
}

class $$FollowsTableTableAnnotationComposer
    extends i0.Composer<i0.GeneratedDatabase, i2.$FollowsTableTable> {
  $$FollowsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  i0.GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  i0.GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  i0.GeneratedColumn<String> get alias =>
      $composableBuilder(column: $table.alias, builder: (column) => column);

  i0.GeneratedColumnWithTypeConverter<i5.FollowType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  i0.GeneratedColumn<int> get latest =>
      $composableBuilder(column: $table.latest, builder: (column) => column);

  i0.GeneratedColumn<int> get unseen =>
      $composableBuilder(column: $table.unseen, builder: (column) => column);

  i0.GeneratedColumn<String> get thumbnail =>
      $composableBuilder(column: $table.thumbnail, builder: (column) => column);

  i0.GeneratedColumn<DateTime> get updated =>
      $composableBuilder(column: $table.updated, builder: (column) => column);

  i0.Expression<T> followsIdentitiesTableRefs<T extends Object>(
    i0.Expression<T> Function(
      i2.$$FollowsIdentitiesTableTableAnnotationComposer a,
    )
    f,
  ) {
    final i2.$$FollowsIdentitiesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: i3.ReadDatabaseContainer($db)
              .resultSet<i2.$FollowsIdentitiesTableTable>(
                'follows_identities_table',
              ),
          getReferencedColumn: (t) => t.follow,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => i2.$$FollowsIdentitiesTableTableAnnotationComposer(
                $db: $db,
                $table: i3.ReadDatabaseContainer($db)
                    .resultSet<i2.$FollowsIdentitiesTableTable>(
                      'follows_identities_table',
                    ),
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$FollowsTableTableTableManager
    extends
        i0.RootTableManager<
          i0.GeneratedDatabase,
          i2.$FollowsTableTable,
          i5.Follow,
          i2.$$FollowsTableTableFilterComposer,
          i2.$$FollowsTableTableOrderingComposer,
          i2.$$FollowsTableTableAnnotationComposer,
          $$FollowsTableTableCreateCompanionBuilder,
          $$FollowsTableTableUpdateCompanionBuilder,
          (i5.Follow, i2.$$FollowsTableTableReferences),
          i5.Follow,
          i0.PrefetchHooks Function({bool followsIdentitiesTableRefs})
        > {
  $$FollowsTableTableTableManager(
    i0.GeneratedDatabase db,
    i2.$FollowsTableTable table,
  ) : super(
        i0.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              i2.$$FollowsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              i2.$$FollowsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              i2.$$FollowsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                i0.Value<int> id = const i0.Value.absent(),
                i0.Value<String> tags = const i0.Value.absent(),
                i0.Value<String?> title = const i0.Value.absent(),
                i0.Value<String?> alias = const i0.Value.absent(),
                i0.Value<i5.FollowType> type = const i0.Value.absent(),
                i0.Value<int?> latest = const i0.Value.absent(),
                i0.Value<int?> unseen = const i0.Value.absent(),
                i0.Value<String?> thumbnail = const i0.Value.absent(),
                i0.Value<DateTime?> updated = const i0.Value.absent(),
              }) => i2.FollowCompanion(
                id: id,
                tags: tags,
                title: title,
                alias: alias,
                type: type,
                latest: latest,
                unseen: unseen,
                thumbnail: thumbnail,
                updated: updated,
              ),
          createCompanionCallback:
              ({
                i0.Value<int> id = const i0.Value.absent(),
                required String tags,
                i0.Value<String?> title = const i0.Value.absent(),
                i0.Value<String?> alias = const i0.Value.absent(),
                required i5.FollowType type,
                i0.Value<int?> latest = const i0.Value.absent(),
                i0.Value<int?> unseen = const i0.Value.absent(),
                i0.Value<String?> thumbnail = const i0.Value.absent(),
                i0.Value<DateTime?> updated = const i0.Value.absent(),
              }) => i2.FollowCompanion.insert(
                id: id,
                tags: tags,
                title: title,
                alias: alias,
                type: type,
                latest: latest,
                unseen: unseen,
                thumbnail: thumbnail,
                updated: updated,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  i2.$$FollowsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({followsIdentitiesTableRefs = false}) {
            return i0.PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (followsIdentitiesTableRefs)
                  i3.ReadDatabaseContainer(
                    db,
                  ).resultSet<i2.$FollowsIdentitiesTableTable>(
                    'follows_identities_table',
                  ),
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (followsIdentitiesTableRefs)
                    await i0.$_getPrefetchedData<
                      i5.Follow,
                      i2.$FollowsTableTable,
                      i2.FollowIdentity
                    >(
                      currentTable: table,
                      referencedTable: i2.$$FollowsTableTableReferences
                          ._followsIdentitiesTableRefsTable(db),
                      managerFromTypedResult: (p0) => i2
                          .$$FollowsTableTableReferences(db, table, p0)
                          .followsIdentitiesTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.follow == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$FollowsTableTableProcessedTableManager =
    i0.ProcessedTableManager<
      i0.GeneratedDatabase,
      i2.$FollowsTableTable,
      i5.Follow,
      i2.$$FollowsTableTableFilterComposer,
      i2.$$FollowsTableTableOrderingComposer,
      i2.$$FollowsTableTableAnnotationComposer,
      $$FollowsTableTableCreateCompanionBuilder,
      $$FollowsTableTableUpdateCompanionBuilder,
      (i5.Follow, i2.$$FollowsTableTableReferences),
      i5.Follow,
      i0.PrefetchHooks Function({bool followsIdentitiesTableRefs})
    >;
typedef $$FollowsIdentitiesTableTableCreateCompanionBuilder =
    i2.FollowIdentityCompanion Function({
      required int identity,
      required int follow,
      i0.Value<int> rowid,
    });
typedef $$FollowsIdentitiesTableTableUpdateCompanionBuilder =
    i2.FollowIdentityCompanion Function({
      i0.Value<int> identity,
      i0.Value<int> follow,
      i0.Value<int> rowid,
    });

final class $$FollowsIdentitiesTableTableReferences
    extends
        i0.BaseReferences<
          i0.GeneratedDatabase,
          i2.$FollowsIdentitiesTableTable,
          i2.FollowIdentity
        > {
  $$FollowsIdentitiesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static i4.$IdentitiesTableTable _identityTable(i0.GeneratedDatabase db) =>
      i3.ReadDatabaseContainer(db)
          .resultSet<i4.$IdentitiesTableTable>('identities_table')
          .createAlias(
            i0.$_aliasNameGenerator(
              i3.ReadDatabaseContainer(db)
                  .resultSet<i2.$FollowsIdentitiesTableTable>(
                    'follows_identities_table',
                  )
                  .identity,
              i3.ReadDatabaseContainer(
                db,
              ).resultSet<i4.$IdentitiesTableTable>('identities_table').id,
            ),
          );

  i4.$$IdentitiesTableTableProcessedTableManager get identity {
    final $_column = $_itemColumn<int>('identity')!;

    final manager = i4
        .$$IdentitiesTableTableTableManager(
          $_db,
          i3.ReadDatabaseContainer(
            $_db,
          ).resultSet<i4.$IdentitiesTableTable>('identities_table'),
        )
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_identityTable($_db));
    if (item == null) return manager;
    return i0.ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static i2.$FollowsTableTable _followTable(i0.GeneratedDatabase db) =>
      i3.ReadDatabaseContainer(db)
          .resultSet<i2.$FollowsTableTable>('follows_table')
          .createAlias(
            i0.$_aliasNameGenerator(
              i3.ReadDatabaseContainer(db)
                  .resultSet<i2.$FollowsIdentitiesTableTable>(
                    'follows_identities_table',
                  )
                  .follow,
              i3.ReadDatabaseContainer(
                db,
              ).resultSet<i2.$FollowsTableTable>('follows_table').id,
            ),
          );

  i2.$$FollowsTableTableProcessedTableManager get follow {
    final $_column = $_itemColumn<int>('follow')!;

    final manager = i2
        .$$FollowsTableTableTableManager(
          $_db,
          i3.ReadDatabaseContainer(
            $_db,
          ).resultSet<i2.$FollowsTableTable>('follows_table'),
        )
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_followTable($_db));
    if (item == null) return manager;
    return i0.ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FollowsIdentitiesTableTableFilterComposer
    extends i0.Composer<i0.GeneratedDatabase, i2.$FollowsIdentitiesTableTable> {
  $$FollowsIdentitiesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i4.$$IdentitiesTableTableFilterComposer get identity {
    final i4.$$IdentitiesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.identity,
      referencedTable: i3.ReadDatabaseContainer(
        $db,
      ).resultSet<i4.$IdentitiesTableTable>('identities_table'),
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i4.$$IdentitiesTableTableFilterComposer(
            $db: $db,
            $table: i3.ReadDatabaseContainer(
              $db,
            ).resultSet<i4.$IdentitiesTableTable>('identities_table'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  i2.$$FollowsTableTableFilterComposer get follow {
    final i2.$$FollowsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.follow,
      referencedTable: i3.ReadDatabaseContainer(
        $db,
      ).resultSet<i2.$FollowsTableTable>('follows_table'),
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i2.$$FollowsTableTableFilterComposer(
            $db: $db,
            $table: i3.ReadDatabaseContainer(
              $db,
            ).resultSet<i2.$FollowsTableTable>('follows_table'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FollowsIdentitiesTableTableOrderingComposer
    extends i0.Composer<i0.GeneratedDatabase, i2.$FollowsIdentitiesTableTable> {
  $$FollowsIdentitiesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i4.$$IdentitiesTableTableOrderingComposer get identity {
    final i4.$$IdentitiesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.identity,
      referencedTable: i3.ReadDatabaseContainer(
        $db,
      ).resultSet<i4.$IdentitiesTableTable>('identities_table'),
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i4.$$IdentitiesTableTableOrderingComposer(
            $db: $db,
            $table: i3.ReadDatabaseContainer(
              $db,
            ).resultSet<i4.$IdentitiesTableTable>('identities_table'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  i2.$$FollowsTableTableOrderingComposer get follow {
    final i2.$$FollowsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.follow,
      referencedTable: i3.ReadDatabaseContainer(
        $db,
      ).resultSet<i2.$FollowsTableTable>('follows_table'),
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i2.$$FollowsTableTableOrderingComposer(
            $db: $db,
            $table: i3.ReadDatabaseContainer(
              $db,
            ).resultSet<i2.$FollowsTableTable>('follows_table'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FollowsIdentitiesTableTableAnnotationComposer
    extends i0.Composer<i0.GeneratedDatabase, i2.$FollowsIdentitiesTableTable> {
  $$FollowsIdentitiesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i4.$$IdentitiesTableTableAnnotationComposer get identity {
    final i4.$$IdentitiesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.identity,
          referencedTable: i3.ReadDatabaseContainer(
            $db,
          ).resultSet<i4.$IdentitiesTableTable>('identities_table'),
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => i4.$$IdentitiesTableTableAnnotationComposer(
                $db: $db,
                $table: i3.ReadDatabaseContainer(
                  $db,
                ).resultSet<i4.$IdentitiesTableTable>('identities_table'),
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  i2.$$FollowsTableTableAnnotationComposer get follow {
    final i2.$$FollowsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.follow,
      referencedTable: i3.ReadDatabaseContainer(
        $db,
      ).resultSet<i2.$FollowsTableTable>('follows_table'),
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i2.$$FollowsTableTableAnnotationComposer(
            $db: $db,
            $table: i3.ReadDatabaseContainer(
              $db,
            ).resultSet<i2.$FollowsTableTable>('follows_table'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FollowsIdentitiesTableTableTableManager
    extends
        i0.RootTableManager<
          i0.GeneratedDatabase,
          i2.$FollowsIdentitiesTableTable,
          i2.FollowIdentity,
          i2.$$FollowsIdentitiesTableTableFilterComposer,
          i2.$$FollowsIdentitiesTableTableOrderingComposer,
          i2.$$FollowsIdentitiesTableTableAnnotationComposer,
          $$FollowsIdentitiesTableTableCreateCompanionBuilder,
          $$FollowsIdentitiesTableTableUpdateCompanionBuilder,
          (i2.FollowIdentity, i2.$$FollowsIdentitiesTableTableReferences),
          i2.FollowIdentity,
          i0.PrefetchHooks Function({bool identity, bool follow})
        > {
  $$FollowsIdentitiesTableTableTableManager(
    i0.GeneratedDatabase db,
    i2.$FollowsIdentitiesTableTable table,
  ) : super(
        i0.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              i2.$$FollowsIdentitiesTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              i2.$$FollowsIdentitiesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              i2.$$FollowsIdentitiesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                i0.Value<int> identity = const i0.Value.absent(),
                i0.Value<int> follow = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i2.FollowIdentityCompanion(
                identity: identity,
                follow: follow,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int identity,
                required int follow,
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i2.FollowIdentityCompanion.insert(
                identity: identity,
                follow: follow,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  i2.$$FollowsIdentitiesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({identity = false, follow = false}) {
            return i0.PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends i0.TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (identity) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.identity,
                                referencedTable: i2
                                    .$$FollowsIdentitiesTableTableReferences
                                    ._identityTable(db),
                                referencedColumn: i2
                                    .$$FollowsIdentitiesTableTableReferences
                                    ._identityTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (follow) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.follow,
                                referencedTable: i2
                                    .$$FollowsIdentitiesTableTableReferences
                                    ._followTable(db),
                                referencedColumn: i2
                                    .$$FollowsIdentitiesTableTableReferences
                                    ._followTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FollowsIdentitiesTableTableProcessedTableManager =
    i0.ProcessedTableManager<
      i0.GeneratedDatabase,
      i2.$FollowsIdentitiesTableTable,
      i2.FollowIdentity,
      i2.$$FollowsIdentitiesTableTableFilterComposer,
      i2.$$FollowsIdentitiesTableTableOrderingComposer,
      i2.$$FollowsIdentitiesTableTableAnnotationComposer,
      $$FollowsIdentitiesTableTableCreateCompanionBuilder,
      $$FollowsIdentitiesTableTableUpdateCompanionBuilder,
      (i2.FollowIdentity, i2.$$FollowsIdentitiesTableTableReferences),
      i2.FollowIdentity,
      i0.PrefetchHooks Function({bool identity, bool follow})
    >;
mixin $FollowClientMixin on i0.DatabaseAccessor<i1.GeneratedDatabase> {
  i2.$FollowsTableTable get followsTable => i3.ReadDatabaseContainer(
    attachedDatabase,
  ).resultSet<i2.$FollowsTableTable>('follows_table');
  i4.$IdentitiesTableTable get identitiesTable => i3.ReadDatabaseContainer(
    attachedDatabase,
  ).resultSet<i4.$IdentitiesTableTable>('identities_table');
  i2.$FollowsIdentitiesTableTable get followsIdentitiesTable =>
      i3.ReadDatabaseContainer(
        attachedDatabase,
      ).resultSet<i2.$FollowsIdentitiesTableTable>('follows_identities_table');
}

class $FollowsTableTable extends i6.FollowsTable
    with i0.TableInfo<$FollowsTableTable, i5.Follow> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FollowsTableTable(this.attachedDatabase, [this._alias]);
  static const i0.VerificationMeta _idMeta = const i0.VerificationMeta('id');
  @override
  late final i0.GeneratedColumn<int> id = i0.GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: i0.DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: i0.GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const i0.VerificationMeta _tagsMeta = const i0.VerificationMeta(
    'tags',
  );
  @override
  late final i0.GeneratedColumn<String> tags = i0.GeneratedColumn<String>(
    'tags',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const i0.VerificationMeta _titleMeta = const i0.VerificationMeta(
    'title',
  );
  @override
  late final i0.GeneratedColumn<String> title = i0.GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const i0.VerificationMeta _aliasMeta = const i0.VerificationMeta(
    'alias',
  );
  @override
  late final i0.GeneratedColumn<String> alias = i0.GeneratedColumn<String>(
    'alias',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final i0.GeneratedColumnWithTypeConverter<i5.FollowType, String> type =
      i0.GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<i5.FollowType>(i2.$FollowsTableTable.$convertertype);
  static const i0.VerificationMeta _latestMeta = const i0.VerificationMeta(
    'latest',
  );
  @override
  late final i0.GeneratedColumn<int> latest = i0.GeneratedColumn<int>(
    'latest',
    aliasedName,
    true,
    type: i0.DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const i0.VerificationMeta _unseenMeta = const i0.VerificationMeta(
    'unseen',
  );
  @override
  late final i0.GeneratedColumn<int> unseen = i0.GeneratedColumn<int>(
    'unseen',
    aliasedName,
    true,
    type: i0.DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const i0.VerificationMeta _thumbnailMeta = const i0.VerificationMeta(
    'thumbnail',
  );
  @override
  late final i0.GeneratedColumn<String> thumbnail = i0.GeneratedColumn<String>(
    'thumbnail',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const i0.VerificationMeta _updatedMeta = const i0.VerificationMeta(
    'updated',
  );
  @override
  late final i0.GeneratedColumn<DateTime> updated =
      i0.GeneratedColumn<DateTime>(
        'updated',
        aliasedName,
        true,
        type: i0.DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<i0.GeneratedColumn> get $columns => [
    id,
    tags,
    title,
    alias,
    type,
    latest,
    unseen,
    thumbnail,
    updated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'follows_table';
  @override
  i0.VerificationContext validateIntegrity(
    i0.Insertable<i5.Follow> instance, {
    bool isInserting = false,
  }) {
    final context = i0.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    } else if (isInserting) {
      context.missing(_tagsMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('alias')) {
      context.handle(
        _aliasMeta,
        alias.isAcceptableOrUnknown(data['alias']!, _aliasMeta),
      );
    }
    if (data.containsKey('latest')) {
      context.handle(
        _latestMeta,
        latest.isAcceptableOrUnknown(data['latest']!, _latestMeta),
      );
    }
    if (data.containsKey('unseen')) {
      context.handle(
        _unseenMeta,
        unseen.isAcceptableOrUnknown(data['unseen']!, _unseenMeta),
      );
    }
    if (data.containsKey('thumbnail')) {
      context.handle(
        _thumbnailMeta,
        thumbnail.isAcceptableOrUnknown(data['thumbnail']!, _thumbnailMeta),
      );
    }
    if (data.containsKey('updated')) {
      context.handle(
        _updatedMeta,
        updated.isAcceptableOrUnknown(data['updated']!, _updatedMeta),
      );
    }
    return context;
  }

  @override
  Set<i0.GeneratedColumn> get $primaryKey => {id};
  @override
  i5.Follow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i5.Follow.new(
      id: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tags: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}tags'],
      )!,
      title: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      alias: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}alias'],
      ),
      type: i2.$FollowsTableTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      latest: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.int,
        data['${effectivePrefix}latest'],
      ),
      unseen: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.int,
        data['${effectivePrefix}unseen'],
      ),
      thumbnail: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}thumbnail'],
      ),
      updated: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.dateTime,
        data['${effectivePrefix}updated'],
      ),
    );
  }

  @override
  $FollowsTableTable createAlias(String alias) {
    return $FollowsTableTable(attachedDatabase, alias);
  }

  static i0.JsonTypeConverter2<i5.FollowType, String, String> $convertertype =
      const i0.EnumNameConverter<i5.FollowType>(i5.FollowType.values);
}

class FollowCompanion extends i0.UpdateCompanion<i5.Follow> {
  final i0.Value<int> id;
  final i0.Value<String> tags;
  final i0.Value<String?> title;
  final i0.Value<String?> alias;
  final i0.Value<i5.FollowType> type;
  final i0.Value<int?> latest;
  final i0.Value<int?> unseen;
  final i0.Value<String?> thumbnail;
  final i0.Value<DateTime?> updated;
  const FollowCompanion({
    this.id = const i0.Value.absent(),
    this.tags = const i0.Value.absent(),
    this.title = const i0.Value.absent(),
    this.alias = const i0.Value.absent(),
    this.type = const i0.Value.absent(),
    this.latest = const i0.Value.absent(),
    this.unseen = const i0.Value.absent(),
    this.thumbnail = const i0.Value.absent(),
    this.updated = const i0.Value.absent(),
  });
  FollowCompanion.insert({
    this.id = const i0.Value.absent(),
    required String tags,
    this.title = const i0.Value.absent(),
    this.alias = const i0.Value.absent(),
    required i5.FollowType type,
    this.latest = const i0.Value.absent(),
    this.unseen = const i0.Value.absent(),
    this.thumbnail = const i0.Value.absent(),
    this.updated = const i0.Value.absent(),
  }) : tags = i0.Value(tags),
       type = i0.Value(type);
  static i0.Insertable<i5.Follow> custom({
    i0.Expression<int>? id,
    i0.Expression<String>? tags,
    i0.Expression<String>? title,
    i0.Expression<String>? alias,
    i0.Expression<String>? type,
    i0.Expression<int>? latest,
    i0.Expression<int>? unseen,
    i0.Expression<String>? thumbnail,
    i0.Expression<DateTime>? updated,
  }) {
    return i0.RawValuesInsertable({
      if (id != null) 'id': id,
      if (tags != null) 'tags': tags,
      if (title != null) 'title': title,
      if (alias != null) 'alias': alias,
      if (type != null) 'type': type,
      if (latest != null) 'latest': latest,
      if (unseen != null) 'unseen': unseen,
      if (thumbnail != null) 'thumbnail': thumbnail,
      if (updated != null) 'updated': updated,
    });
  }

  i2.FollowCompanion copyWith({
    i0.Value<int>? id,
    i0.Value<String>? tags,
    i0.Value<String?>? title,
    i0.Value<String?>? alias,
    i0.Value<i5.FollowType>? type,
    i0.Value<int?>? latest,
    i0.Value<int?>? unseen,
    i0.Value<String?>? thumbnail,
    i0.Value<DateTime?>? updated,
  }) {
    return i2.FollowCompanion(
      id: id ?? this.id,
      tags: tags ?? this.tags,
      title: title ?? this.title,
      alias: alias ?? this.alias,
      type: type ?? this.type,
      latest: latest ?? this.latest,
      unseen: unseen ?? this.unseen,
      thumbnail: thumbnail ?? this.thumbnail,
      updated: updated ?? this.updated,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (id.present) {
      map['id'] = i0.Variable<int>(id.value);
    }
    if (tags.present) {
      map['tags'] = i0.Variable<String>(tags.value);
    }
    if (title.present) {
      map['title'] = i0.Variable<String>(title.value);
    }
    if (alias.present) {
      map['alias'] = i0.Variable<String>(alias.value);
    }
    if (type.present) {
      map['type'] = i0.Variable<String>(
        i2.$FollowsTableTable.$convertertype.toSql(type.value),
      );
    }
    if (latest.present) {
      map['latest'] = i0.Variable<int>(latest.value);
    }
    if (unseen.present) {
      map['unseen'] = i0.Variable<int>(unseen.value);
    }
    if (thumbnail.present) {
      map['thumbnail'] = i0.Variable<String>(thumbnail.value);
    }
    if (updated.present) {
      map['updated'] = i0.Variable<DateTime>(updated.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FollowCompanion(')
          ..write('id: $id, ')
          ..write('tags: $tags, ')
          ..write('title: $title, ')
          ..write('alias: $alias, ')
          ..write('type: $type, ')
          ..write('latest: $latest, ')
          ..write('unseen: $unseen, ')
          ..write('thumbnail: $thumbnail, ')
          ..write('updated: $updated')
          ..write(')'))
        .toString();
  }
}

class _$FollowInsertable implements i0.Insertable<i5.Follow> {
  i5.Follow _object;
  _$FollowInsertable(this._object);
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    return i2.FollowCompanion(
      id: i0.Value(_object.id),
      tags: i0.Value(_object.tags),
      title: i0.Value(_object.title),
      alias: i0.Value(_object.alias),
      type: i0.Value(_object.type),
      latest: i0.Value(_object.latest),
      unseen: i0.Value(_object.unseen),
      thumbnail: i0.Value(_object.thumbnail),
      updated: i0.Value(_object.updated),
    ).toColumns(false);
  }
}

extension FollowToInsertable on i5.Follow {
  _$FollowInsertable toInsertable() {
    return _$FollowInsertable(this);
  }
}

class $FollowsIdentitiesTableTable extends i6.FollowsIdentitiesTable
    with i0.TableInfo<$FollowsIdentitiesTableTable, i2.FollowIdentity> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FollowsIdentitiesTableTable(this.attachedDatabase, [this._alias]);
  static const i0.VerificationMeta _identityMeta = const i0.VerificationMeta(
    'identity',
  );
  @override
  late final i0.GeneratedColumn<int> identity = i0.GeneratedColumn<int>(
    'identity',
    aliasedName,
    false,
    type: i0.DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: i0.GeneratedColumn.constraintIsAlways(
      'REFERENCES identities_table (id) ON UPDATE NO ACTION ON DELETE NO ACTION',
    ),
  );
  static const i0.VerificationMeta _followMeta = const i0.VerificationMeta(
    'follow',
  );
  @override
  late final i0.GeneratedColumn<int> follow = i0.GeneratedColumn<int>(
    'follow',
    aliasedName,
    false,
    type: i0.DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: i0.GeneratedColumn.constraintIsAlways(
      'REFERENCES follows_table (id) ON UPDATE CASCADE ON DELETE CASCADE',
    ),
  );
  @override
  List<i0.GeneratedColumn> get $columns => [identity, follow];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'follows_identities_table';
  @override
  i0.VerificationContext validateIntegrity(
    i0.Insertable<i2.FollowIdentity> instance, {
    bool isInserting = false,
  }) {
    final context = i0.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('identity')) {
      context.handle(
        _identityMeta,
        identity.isAcceptableOrUnknown(data['identity']!, _identityMeta),
      );
    } else if (isInserting) {
      context.missing(_identityMeta);
    }
    if (data.containsKey('follow')) {
      context.handle(
        _followMeta,
        follow.isAcceptableOrUnknown(data['follow']!, _followMeta),
      );
    } else if (isInserting) {
      context.missing(_followMeta);
    }
    return context;
  }

  @override
  Set<i0.GeneratedColumn> get $primaryKey => {identity, follow};
  @override
  i2.FollowIdentity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i2.FollowIdentity(
      identity: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.int,
        data['${effectivePrefix}identity'],
      )!,
      follow: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.int,
        data['${effectivePrefix}follow'],
      )!,
    );
  }

  @override
  $FollowsIdentitiesTableTable createAlias(String alias) {
    return $FollowsIdentitiesTableTable(attachedDatabase, alias);
  }
}

class FollowIdentity extends i0.DataClass
    implements i0.Insertable<i2.FollowIdentity> {
  final int identity;
  final int follow;
  const FollowIdentity({required this.identity, required this.follow});
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    map['identity'] = i0.Variable<int>(identity);
    map['follow'] = i0.Variable<int>(follow);
    return map;
  }

  i2.FollowIdentityCompanion toCompanion(bool nullToAbsent) {
    return i2.FollowIdentityCompanion(
      identity: i0.Value(identity),
      follow: i0.Value(follow),
    );
  }

  factory FollowIdentity.fromJson(
    Map<String, dynamic> json, {
    i0.ValueSerializer? serializer,
  }) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return FollowIdentity(
      identity: serializer.fromJson<int>(json['identity']),
      follow: serializer.fromJson<int>(json['follow']),
    );
  }
  @override
  Map<String, dynamic> toJson({i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'identity': serializer.toJson<int>(identity),
      'follow': serializer.toJson<int>(follow),
    };
  }

  i2.FollowIdentity copyWith({int? identity, int? follow}) => i2.FollowIdentity(
    identity: identity ?? this.identity,
    follow: follow ?? this.follow,
  );
  FollowIdentity copyWithCompanion(i2.FollowIdentityCompanion data) {
    return FollowIdentity(
      identity: data.identity.present ? data.identity.value : this.identity,
      follow: data.follow.present ? data.follow.value : this.follow,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FollowIdentity(')
          ..write('identity: $identity, ')
          ..write('follow: $follow')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(identity, follow);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is i2.FollowIdentity &&
          other.identity == this.identity &&
          other.follow == this.follow);
}

class FollowIdentityCompanion extends i0.UpdateCompanion<i2.FollowIdentity> {
  final i0.Value<int> identity;
  final i0.Value<int> follow;
  final i0.Value<int> rowid;
  const FollowIdentityCompanion({
    this.identity = const i0.Value.absent(),
    this.follow = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  });
  FollowIdentityCompanion.insert({
    required int identity,
    required int follow,
    this.rowid = const i0.Value.absent(),
  }) : identity = i0.Value(identity),
       follow = i0.Value(follow);
  static i0.Insertable<i2.FollowIdentity> custom({
    i0.Expression<int>? identity,
    i0.Expression<int>? follow,
    i0.Expression<int>? rowid,
  }) {
    return i0.RawValuesInsertable({
      if (identity != null) 'identity': identity,
      if (follow != null) 'follow': follow,
      if (rowid != null) 'rowid': rowid,
    });
  }

  i2.FollowIdentityCompanion copyWith({
    i0.Value<int>? identity,
    i0.Value<int>? follow,
    i0.Value<int>? rowid,
  }) {
    return i2.FollowIdentityCompanion(
      identity: identity ?? this.identity,
      follow: follow ?? this.follow,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (identity.present) {
      map['identity'] = i0.Variable<int>(identity.value);
    }
    if (follow.present) {
      map['follow'] = i0.Variable<int>(follow.value);
    }
    if (rowid.present) {
      map['rowid'] = i0.Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FollowIdentityCompanion(')
          ..write('identity: $identity, ')
          ..write('follow: $follow, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}
