// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:drift/src/runtime/api/runtime_api.dart' as i1;
import 'package:e1547/history/data/database.drift.dart' as i2;
import 'package:drift/internal/modular.dart' as i3;
import 'package:e1547/identity/data/database.drift.dart' as i4;
import 'package:e1547/history/data/history.dart' as i5;
import 'package:e1547/history/data/database.dart' as i6;
import 'package:e1547/shared/data/sql.dart' as i7;

typedef $$HistoriesTableTableCreateCompanionBuilder =
    i2.HistoryCompanion Function({
      i0.Value<int> id,
      required DateTime visitedAt,
      required String link,
      required i5.HistoryCategory category,
      required i5.HistoryType type,
      i0.Value<String?> title,
      i0.Value<String?> subtitle,
      required List<String> thumbnails,
    });
typedef $$HistoriesTableTableUpdateCompanionBuilder =
    i2.HistoryCompanion Function({
      i0.Value<int> id,
      i0.Value<DateTime> visitedAt,
      i0.Value<String> link,
      i0.Value<i5.HistoryCategory> category,
      i0.Value<i5.HistoryType> type,
      i0.Value<String?> title,
      i0.Value<String?> subtitle,
      i0.Value<List<String>> thumbnails,
    });

final class $$HistoriesTableTableReferences
    extends
        i0.BaseReferences<
          i0.GeneratedDatabase,
          i2.$HistoriesTableTable,
          i5.History
        > {
  $$HistoriesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static i0.MultiTypedResultKey<
    i2.$HistoriesIdentitiesTableTable,
    List<i2.HistoryIdentity>
  >
  _historiesIdentitiesTableRefsTable(i0.GeneratedDatabase db) =>
      i0.MultiTypedResultKey.fromTable(
        i3.ReadDatabaseContainer(
          db,
        ).resultSet<i2.$HistoriesIdentitiesTableTable>(
          'histories_identities_table',
        ),
        aliasName: i0.$_aliasNameGenerator(
          i3.ReadDatabaseContainer(
            db,
          ).resultSet<i2.$HistoriesTableTable>('histories_table').id,
          i3.ReadDatabaseContainer(db)
              .resultSet<i2.$HistoriesIdentitiesTableTable>(
                'histories_identities_table',
              )
              .history,
        ),
      );

  i2.$$HistoriesIdentitiesTableTableProcessedTableManager
  get historiesIdentitiesTableRefs {
    final manager = i2
        .$$HistoriesIdentitiesTableTableTableManager(
          $_db,
          i3.ReadDatabaseContainer(
            $_db,
          ).resultSet<i2.$HistoriesIdentitiesTableTable>(
            'histories_identities_table',
          ),
        )
        .filter((f) => f.history.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _historiesIdentitiesTableRefsTable($_db),
    );
    return i0.ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$HistoriesTableTableFilterComposer
    extends i0.Composer<i0.GeneratedDatabase, i2.$HistoriesTableTable> {
  $$HistoriesTableTableFilterComposer({
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

  i0.ColumnFilters<DateTime> get visitedAt => $composableBuilder(
    column: $table.visitedAt,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get link => $composableBuilder(
    column: $table.link,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnWithTypeConverterFilters<
    i5.HistoryCategory,
    i5.HistoryCategory,
    String
  >
  get category => $composableBuilder(
    column: $table.category,
    builder: (column) => i0.ColumnWithTypeConverterFilters(column),
  );

  i0.ColumnWithTypeConverterFilters<i5.HistoryType, i5.HistoryType, String>
  get type => $composableBuilder(
    column: $table.type,
    builder: (column) => i0.ColumnWithTypeConverterFilters(column),
  );

  i0.ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get thumbnails => $composableBuilder(
    column: $table.thumbnails,
    builder: (column) => i0.ColumnWithTypeConverterFilters(column),
  );

  i0.Expression<bool> historiesIdentitiesTableRefs(
    i0.Expression<bool> Function(
      i2.$$HistoriesIdentitiesTableTableFilterComposer f,
    )
    f,
  ) {
    final i2.$$HistoriesIdentitiesTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: i3.ReadDatabaseContainer($db)
              .resultSet<i2.$HistoriesIdentitiesTableTable>(
                'histories_identities_table',
              ),
          getReferencedColumn: (t) => t.history,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => i2.$$HistoriesIdentitiesTableTableFilterComposer(
                $db: $db,
                $table: i3.ReadDatabaseContainer($db)
                    .resultSet<i2.$HistoriesIdentitiesTableTable>(
                      'histories_identities_table',
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

class $$HistoriesTableTableOrderingComposer
    extends i0.Composer<i0.GeneratedDatabase, i2.$HistoriesTableTable> {
  $$HistoriesTableTableOrderingComposer({
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

  i0.ColumnOrderings<DateTime> get visitedAt => $composableBuilder(
    column: $table.visitedAt,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get link => $composableBuilder(
    column: $table.link,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get thumbnails => $composableBuilder(
    column: $table.thumbnails,
    builder: (column) => i0.ColumnOrderings(column),
  );
}

class $$HistoriesTableTableAnnotationComposer
    extends i0.Composer<i0.GeneratedDatabase, i2.$HistoriesTableTable> {
  $$HistoriesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  i0.GeneratedColumn<DateTime> get visitedAt =>
      $composableBuilder(column: $table.visitedAt, builder: (column) => column);

  i0.GeneratedColumn<String> get link =>
      $composableBuilder(column: $table.link, builder: (column) => column);

  i0.GeneratedColumnWithTypeConverter<i5.HistoryCategory, String>
  get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  i0.GeneratedColumnWithTypeConverter<i5.HistoryType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  i0.GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  i0.GeneratedColumn<String> get subtitle =>
      $composableBuilder(column: $table.subtitle, builder: (column) => column);

  i0.GeneratedColumnWithTypeConverter<List<String>, String> get thumbnails =>
      $composableBuilder(
        column: $table.thumbnails,
        builder: (column) => column,
      );

  i0.Expression<T> historiesIdentitiesTableRefs<T extends Object>(
    i0.Expression<T> Function(
      i2.$$HistoriesIdentitiesTableTableAnnotationComposer a,
    )
    f,
  ) {
    final i2.$$HistoriesIdentitiesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: i3.ReadDatabaseContainer($db)
              .resultSet<i2.$HistoriesIdentitiesTableTable>(
                'histories_identities_table',
              ),
          getReferencedColumn: (t) => t.history,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => i2.$$HistoriesIdentitiesTableTableAnnotationComposer(
                $db: $db,
                $table: i3.ReadDatabaseContainer($db)
                    .resultSet<i2.$HistoriesIdentitiesTableTable>(
                      'histories_identities_table',
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

class $$HistoriesTableTableTableManager
    extends
        i0.RootTableManager<
          i0.GeneratedDatabase,
          i2.$HistoriesTableTable,
          i5.History,
          i2.$$HistoriesTableTableFilterComposer,
          i2.$$HistoriesTableTableOrderingComposer,
          i2.$$HistoriesTableTableAnnotationComposer,
          $$HistoriesTableTableCreateCompanionBuilder,
          $$HistoriesTableTableUpdateCompanionBuilder,
          (i5.History, i2.$$HistoriesTableTableReferences),
          i5.History,
          i0.PrefetchHooks Function({bool historiesIdentitiesTableRefs})
        > {
  $$HistoriesTableTableTableManager(
    i0.GeneratedDatabase db,
    i2.$HistoriesTableTable table,
  ) : super(
        i0.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              i2.$$HistoriesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              i2.$$HistoriesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => i2
              .$$HistoriesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                i0.Value<int> id = const i0.Value.absent(),
                i0.Value<DateTime> visitedAt = const i0.Value.absent(),
                i0.Value<String> link = const i0.Value.absent(),
                i0.Value<i5.HistoryCategory> category = const i0.Value.absent(),
                i0.Value<i5.HistoryType> type = const i0.Value.absent(),
                i0.Value<String?> title = const i0.Value.absent(),
                i0.Value<String?> subtitle = const i0.Value.absent(),
                i0.Value<List<String>> thumbnails = const i0.Value.absent(),
              }) => i2.HistoryCompanion(
                id: id,
                visitedAt: visitedAt,
                link: link,
                category: category,
                type: type,
                title: title,
                subtitle: subtitle,
                thumbnails: thumbnails,
              ),
          createCompanionCallback:
              ({
                i0.Value<int> id = const i0.Value.absent(),
                required DateTime visitedAt,
                required String link,
                required i5.HistoryCategory category,
                required i5.HistoryType type,
                i0.Value<String?> title = const i0.Value.absent(),
                i0.Value<String?> subtitle = const i0.Value.absent(),
                required List<String> thumbnails,
              }) => i2.HistoryCompanion.insert(
                id: id,
                visitedAt: visitedAt,
                link: link,
                category: category,
                type: type,
                title: title,
                subtitle: subtitle,
                thumbnails: thumbnails,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  i2.$$HistoriesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({historiesIdentitiesTableRefs = false}) {
            return i0.PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (historiesIdentitiesTableRefs)
                  i3.ReadDatabaseContainer(
                    db,
                  ).resultSet<i2.$HistoriesIdentitiesTableTable>(
                    'histories_identities_table',
                  ),
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (historiesIdentitiesTableRefs)
                    await i0.$_getPrefetchedData<
                      i5.History,
                      i2.$HistoriesTableTable,
                      i2.HistoryIdentity
                    >(
                      currentTable: table,
                      referencedTable: i2.$$HistoriesTableTableReferences
                          ._historiesIdentitiesTableRefsTable(db),
                      managerFromTypedResult: (p0) => i2
                          .$$HistoriesTableTableReferences(db, table, p0)
                          .historiesIdentitiesTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.history == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$HistoriesTableTableProcessedTableManager =
    i0.ProcessedTableManager<
      i0.GeneratedDatabase,
      i2.$HistoriesTableTable,
      i5.History,
      i2.$$HistoriesTableTableFilterComposer,
      i2.$$HistoriesTableTableOrderingComposer,
      i2.$$HistoriesTableTableAnnotationComposer,
      $$HistoriesTableTableCreateCompanionBuilder,
      $$HistoriesTableTableUpdateCompanionBuilder,
      (i5.History, i2.$$HistoriesTableTableReferences),
      i5.History,
      i0.PrefetchHooks Function({bool historiesIdentitiesTableRefs})
    >;
typedef $$HistoriesIdentitiesTableTableCreateCompanionBuilder =
    i2.HistoryIdentityCompanion Function({
      required int identity,
      required int history,
      i0.Value<int> rowid,
    });
typedef $$HistoriesIdentitiesTableTableUpdateCompanionBuilder =
    i2.HistoryIdentityCompanion Function({
      i0.Value<int> identity,
      i0.Value<int> history,
      i0.Value<int> rowid,
    });

final class $$HistoriesIdentitiesTableTableReferences
    extends
        i0.BaseReferences<
          i0.GeneratedDatabase,
          i2.$HistoriesIdentitiesTableTable,
          i2.HistoryIdentity
        > {
  $$HistoriesIdentitiesTableTableReferences(
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
                  .resultSet<i2.$HistoriesIdentitiesTableTable>(
                    'histories_identities_table',
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

  static i2.$HistoriesTableTable _historyTable(i0.GeneratedDatabase db) =>
      i3.ReadDatabaseContainer(db)
          .resultSet<i2.$HistoriesTableTable>('histories_table')
          .createAlias(
            i0.$_aliasNameGenerator(
              i3.ReadDatabaseContainer(db)
                  .resultSet<i2.$HistoriesIdentitiesTableTable>(
                    'histories_identities_table',
                  )
                  .history,
              i3.ReadDatabaseContainer(
                db,
              ).resultSet<i2.$HistoriesTableTable>('histories_table').id,
            ),
          );

  i2.$$HistoriesTableTableProcessedTableManager get history {
    final $_column = $_itemColumn<int>('history')!;

    final manager = i2
        .$$HistoriesTableTableTableManager(
          $_db,
          i3.ReadDatabaseContainer(
            $_db,
          ).resultSet<i2.$HistoriesTableTable>('histories_table'),
        )
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_historyTable($_db));
    if (item == null) return manager;
    return i0.ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HistoriesIdentitiesTableTableFilterComposer
    extends
        i0.Composer<i0.GeneratedDatabase, i2.$HistoriesIdentitiesTableTable> {
  $$HistoriesIdentitiesTableTableFilterComposer({
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

  i2.$$HistoriesTableTableFilterComposer get history {
    final i2.$$HistoriesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.history,
      referencedTable: i3.ReadDatabaseContainer(
        $db,
      ).resultSet<i2.$HistoriesTableTable>('histories_table'),
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i2.$$HistoriesTableTableFilterComposer(
            $db: $db,
            $table: i3.ReadDatabaseContainer(
              $db,
            ).resultSet<i2.$HistoriesTableTable>('histories_table'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HistoriesIdentitiesTableTableOrderingComposer
    extends
        i0.Composer<i0.GeneratedDatabase, i2.$HistoriesIdentitiesTableTable> {
  $$HistoriesIdentitiesTableTableOrderingComposer({
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

  i2.$$HistoriesTableTableOrderingComposer get history {
    final i2.$$HistoriesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.history,
      referencedTable: i3.ReadDatabaseContainer(
        $db,
      ).resultSet<i2.$HistoriesTableTable>('histories_table'),
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i2.$$HistoriesTableTableOrderingComposer(
            $db: $db,
            $table: i3.ReadDatabaseContainer(
              $db,
            ).resultSet<i2.$HistoriesTableTable>('histories_table'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HistoriesIdentitiesTableTableAnnotationComposer
    extends
        i0.Composer<i0.GeneratedDatabase, i2.$HistoriesIdentitiesTableTable> {
  $$HistoriesIdentitiesTableTableAnnotationComposer({
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

  i2.$$HistoriesTableTableAnnotationComposer get history {
    final i2.$$HistoriesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.history,
          referencedTable: i3.ReadDatabaseContainer(
            $db,
          ).resultSet<i2.$HistoriesTableTable>('histories_table'),
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => i2.$$HistoriesTableTableAnnotationComposer(
                $db: $db,
                $table: i3.ReadDatabaseContainer(
                  $db,
                ).resultSet<i2.$HistoriesTableTable>('histories_table'),
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$HistoriesIdentitiesTableTableTableManager
    extends
        i0.RootTableManager<
          i0.GeneratedDatabase,
          i2.$HistoriesIdentitiesTableTable,
          i2.HistoryIdentity,
          i2.$$HistoriesIdentitiesTableTableFilterComposer,
          i2.$$HistoriesIdentitiesTableTableOrderingComposer,
          i2.$$HistoriesIdentitiesTableTableAnnotationComposer,
          $$HistoriesIdentitiesTableTableCreateCompanionBuilder,
          $$HistoriesIdentitiesTableTableUpdateCompanionBuilder,
          (i2.HistoryIdentity, i2.$$HistoriesIdentitiesTableTableReferences),
          i2.HistoryIdentity,
          i0.PrefetchHooks Function({bool identity, bool history})
        > {
  $$HistoriesIdentitiesTableTableTableManager(
    i0.GeneratedDatabase db,
    i2.$HistoriesIdentitiesTableTable table,
  ) : super(
        i0.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              i2.$$HistoriesIdentitiesTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              i2.$$HistoriesIdentitiesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              i2.$$HistoriesIdentitiesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                i0.Value<int> identity = const i0.Value.absent(),
                i0.Value<int> history = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i2.HistoryIdentityCompanion(
                identity: identity,
                history: history,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int identity,
                required int history,
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i2.HistoryIdentityCompanion.insert(
                identity: identity,
                history: history,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  i2.$$HistoriesIdentitiesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({identity = false, history = false}) {
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
                                    .$$HistoriesIdentitiesTableTableReferences
                                    ._identityTable(db),
                                referencedColumn: i2
                                    .$$HistoriesIdentitiesTableTableReferences
                                    ._identityTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (history) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.history,
                                referencedTable: i2
                                    .$$HistoriesIdentitiesTableTableReferences
                                    ._historyTable(db),
                                referencedColumn: i2
                                    .$$HistoriesIdentitiesTableTableReferences
                                    ._historyTable(db)
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

typedef $$HistoriesIdentitiesTableTableProcessedTableManager =
    i0.ProcessedTableManager<
      i0.GeneratedDatabase,
      i2.$HistoriesIdentitiesTableTable,
      i2.HistoryIdentity,
      i2.$$HistoriesIdentitiesTableTableFilterComposer,
      i2.$$HistoriesIdentitiesTableTableOrderingComposer,
      i2.$$HistoriesIdentitiesTableTableAnnotationComposer,
      $$HistoriesIdentitiesTableTableCreateCompanionBuilder,
      $$HistoriesIdentitiesTableTableUpdateCompanionBuilder,
      (i2.HistoryIdentity, i2.$$HistoriesIdentitiesTableTableReferences),
      i2.HistoryIdentity,
      i0.PrefetchHooks Function({bool identity, bool history})
    >;
mixin $HistoryRepositoryMixin on i0.DatabaseAccessor<i1.GeneratedDatabase> {
  i2.$HistoriesTableTable get historiesTable => i3.ReadDatabaseContainer(
    attachedDatabase,
  ).resultSet<i2.$HistoriesTableTable>('histories_table');
  i4.$IdentitiesTableTable get identitiesTable => i3.ReadDatabaseContainer(
    attachedDatabase,
  ).resultSet<i4.$IdentitiesTableTable>('identities_table');
  i2.$HistoriesIdentitiesTableTable get historiesIdentitiesTable =>
      i3.ReadDatabaseContainer(
        attachedDatabase,
      ).resultSet<i2.$HistoriesIdentitiesTableTable>(
        'histories_identities_table',
      );
}

class $HistoriesTableTable extends i6.HistoriesTable
    with i0.TableInfo<$HistoriesTableTable, i5.History> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistoriesTableTable(this.attachedDatabase, [this._alias]);
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
  static const i0.VerificationMeta _visitedAtMeta = const i0.VerificationMeta(
    'visitedAt',
  );
  @override
  late final i0.GeneratedColumn<DateTime> visitedAt =
      i0.GeneratedColumn<DateTime>(
        'visited_at',
        aliasedName,
        false,
        type: i0.DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const i0.VerificationMeta _linkMeta = const i0.VerificationMeta(
    'link',
  );
  @override
  late final i0.GeneratedColumn<String> link = i0.GeneratedColumn<String>(
    'link',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final i0.GeneratedColumnWithTypeConverter<i5.HistoryCategory, String>
  category =
      i0.GeneratedColumn<String>(
        'category',
        aliasedName,
        false,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<i5.HistoryCategory>(
        i2.$HistoriesTableTable.$convertercategory,
      );
  @override
  late final i0.GeneratedColumnWithTypeConverter<i5.HistoryType, String> type =
      i0.GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<i5.HistoryType>(i2.$HistoriesTableTable.$convertertype);
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
  static const i0.VerificationMeta _subtitleMeta = const i0.VerificationMeta(
    'subtitle',
  );
  @override
  late final i0.GeneratedColumn<String> subtitle = i0.GeneratedColumn<String>(
    'subtitle',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final i0.GeneratedColumnWithTypeConverter<List<String>, String>
  thumbnails = i0.GeneratedColumn<String>(
    'thumbnails',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<List<String>>(i2.$HistoriesTableTable.$converterthumbnails);
  @override
  List<i0.GeneratedColumn> get $columns => [
    id,
    visitedAt,
    link,
    category,
    type,
    title,
    subtitle,
    thumbnails,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'histories_table';
  @override
  i0.VerificationContext validateIntegrity(
    i0.Insertable<i5.History> instance, {
    bool isInserting = false,
  }) {
    final context = i0.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('visited_at')) {
      context.handle(
        _visitedAtMeta,
        visitedAt.isAcceptableOrUnknown(data['visited_at']!, _visitedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_visitedAtMeta);
    }
    if (data.containsKey('link')) {
      context.handle(
        _linkMeta,
        link.isAcceptableOrUnknown(data['link']!, _linkMeta),
      );
    } else if (isInserting) {
      context.missing(_linkMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('subtitle')) {
      context.handle(
        _subtitleMeta,
        subtitle.isAcceptableOrUnknown(data['subtitle']!, _subtitleMeta),
      );
    }
    return context;
  }

  @override
  Set<i0.GeneratedColumn> get $primaryKey => {id};
  @override
  i5.History map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i5.History.new(
      id: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      visitedAt: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.dateTime,
        data['${effectivePrefix}visited_at'],
      )!,
      link: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}link'],
      )!,
      category: i2.$HistoriesTableTable.$convertercategory.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.string,
          data['${effectivePrefix}category'],
        )!,
      ),
      type: i2.$HistoriesTableTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      title: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      subtitle: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}subtitle'],
      ),
      thumbnails: i2.$HistoriesTableTable.$converterthumbnails.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.string,
          data['${effectivePrefix}thumbnails'],
        )!,
      ),
    );
  }

  @override
  $HistoriesTableTable createAlias(String alias) {
    return $HistoriesTableTable(attachedDatabase, alias);
  }

  static i0.JsonTypeConverter2<i5.HistoryCategory, String, String>
  $convertercategory = const i0.EnumNameConverter<i5.HistoryCategory>(
    i5.HistoryCategory.values,
  );
  static i0.JsonTypeConverter2<i5.HistoryType, String, String> $convertertype =
      const i0.EnumNameConverter<i5.HistoryType>(i5.HistoryType.values);
  static i0.TypeConverter<List<String>, String> $converterthumbnails =
      i7.JsonSqlConverter.list<String>();
}

class HistoryCompanion extends i0.UpdateCompanion<i5.History> {
  final i0.Value<int> id;
  final i0.Value<DateTime> visitedAt;
  final i0.Value<String> link;
  final i0.Value<i5.HistoryCategory> category;
  final i0.Value<i5.HistoryType> type;
  final i0.Value<String?> title;
  final i0.Value<String?> subtitle;
  final i0.Value<List<String>> thumbnails;
  const HistoryCompanion({
    this.id = const i0.Value.absent(),
    this.visitedAt = const i0.Value.absent(),
    this.link = const i0.Value.absent(),
    this.category = const i0.Value.absent(),
    this.type = const i0.Value.absent(),
    this.title = const i0.Value.absent(),
    this.subtitle = const i0.Value.absent(),
    this.thumbnails = const i0.Value.absent(),
  });
  HistoryCompanion.insert({
    this.id = const i0.Value.absent(),
    required DateTime visitedAt,
    required String link,
    required i5.HistoryCategory category,
    required i5.HistoryType type,
    this.title = const i0.Value.absent(),
    this.subtitle = const i0.Value.absent(),
    required List<String> thumbnails,
  }) : visitedAt = i0.Value(visitedAt),
       link = i0.Value(link),
       category = i0.Value(category),
       type = i0.Value(type),
       thumbnails = i0.Value(thumbnails);
  static i0.Insertable<i5.History> custom({
    i0.Expression<int>? id,
    i0.Expression<DateTime>? visitedAt,
    i0.Expression<String>? link,
    i0.Expression<String>? category,
    i0.Expression<String>? type,
    i0.Expression<String>? title,
    i0.Expression<String>? subtitle,
    i0.Expression<String>? thumbnails,
  }) {
    return i0.RawValuesInsertable({
      if (id != null) 'id': id,
      if (visitedAt != null) 'visited_at': visitedAt,
      if (link != null) 'link': link,
      if (category != null) 'category': category,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      if (thumbnails != null) 'thumbnails': thumbnails,
    });
  }

  i2.HistoryCompanion copyWith({
    i0.Value<int>? id,
    i0.Value<DateTime>? visitedAt,
    i0.Value<String>? link,
    i0.Value<i5.HistoryCategory>? category,
    i0.Value<i5.HistoryType>? type,
    i0.Value<String?>? title,
    i0.Value<String?>? subtitle,
    i0.Value<List<String>>? thumbnails,
  }) {
    return i2.HistoryCompanion(
      id: id ?? this.id,
      visitedAt: visitedAt ?? this.visitedAt,
      link: link ?? this.link,
      category: category ?? this.category,
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      thumbnails: thumbnails ?? this.thumbnails,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (id.present) {
      map['id'] = i0.Variable<int>(id.value);
    }
    if (visitedAt.present) {
      map['visited_at'] = i0.Variable<DateTime>(visitedAt.value);
    }
    if (link.present) {
      map['link'] = i0.Variable<String>(link.value);
    }
    if (category.present) {
      map['category'] = i0.Variable<String>(
        i2.$HistoriesTableTable.$convertercategory.toSql(category.value),
      );
    }
    if (type.present) {
      map['type'] = i0.Variable<String>(
        i2.$HistoriesTableTable.$convertertype.toSql(type.value),
      );
    }
    if (title.present) {
      map['title'] = i0.Variable<String>(title.value);
    }
    if (subtitle.present) {
      map['subtitle'] = i0.Variable<String>(subtitle.value);
    }
    if (thumbnails.present) {
      map['thumbnails'] = i0.Variable<String>(
        i2.$HistoriesTableTable.$converterthumbnails.toSql(thumbnails.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistoryCompanion(')
          ..write('id: $id, ')
          ..write('visitedAt: $visitedAt, ')
          ..write('link: $link, ')
          ..write('category: $category, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('thumbnails: $thumbnails')
          ..write(')'))
        .toString();
  }
}

class _$HistoryInsertable implements i0.Insertable<i5.History> {
  i5.History _object;
  _$HistoryInsertable(this._object);
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    return i2.HistoryCompanion(
      id: i0.Value(_object.id),
      visitedAt: i0.Value(_object.visitedAt),
      link: i0.Value(_object.link),
      category: i0.Value(_object.category),
      type: i0.Value(_object.type),
      title: i0.Value(_object.title),
      subtitle: i0.Value(_object.subtitle),
      thumbnails: i0.Value(_object.thumbnails),
    ).toColumns(false);
  }
}

extension HistoryToInsertable on i5.History {
  _$HistoryInsertable toInsertable() {
    return _$HistoryInsertable(this);
  }
}

class $HistoriesIdentitiesTableTable extends i6.HistoriesIdentitiesTable
    with i0.TableInfo<$HistoriesIdentitiesTableTable, i2.HistoryIdentity> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistoriesIdentitiesTableTable(this.attachedDatabase, [this._alias]);
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
  static const i0.VerificationMeta _historyMeta = const i0.VerificationMeta(
    'history',
  );
  @override
  late final i0.GeneratedColumn<int> history = i0.GeneratedColumn<int>(
    'history',
    aliasedName,
    false,
    type: i0.DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: i0.GeneratedColumn.constraintIsAlways(
      'REFERENCES histories_table (id) ON UPDATE CASCADE ON DELETE CASCADE',
    ),
  );
  @override
  List<i0.GeneratedColumn> get $columns => [identity, history];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'histories_identities_table';
  @override
  i0.VerificationContext validateIntegrity(
    i0.Insertable<i2.HistoryIdentity> instance, {
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
    if (data.containsKey('history')) {
      context.handle(
        _historyMeta,
        history.isAcceptableOrUnknown(data['history']!, _historyMeta),
      );
    } else if (isInserting) {
      context.missing(_historyMeta);
    }
    return context;
  }

  @override
  Set<i0.GeneratedColumn> get $primaryKey => {identity, history};
  @override
  i2.HistoryIdentity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i2.HistoryIdentity(
      identity: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.int,
        data['${effectivePrefix}identity'],
      )!,
      history: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.int,
        data['${effectivePrefix}history'],
      )!,
    );
  }

  @override
  $HistoriesIdentitiesTableTable createAlias(String alias) {
    return $HistoriesIdentitiesTableTable(attachedDatabase, alias);
  }
}

class HistoryIdentity extends i0.DataClass
    implements i0.Insertable<i2.HistoryIdentity> {
  final int identity;
  final int history;
  const HistoryIdentity({required this.identity, required this.history});
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    map['identity'] = i0.Variable<int>(identity);
    map['history'] = i0.Variable<int>(history);
    return map;
  }

  i2.HistoryIdentityCompanion toCompanion(bool nullToAbsent) {
    return i2.HistoryIdentityCompanion(
      identity: i0.Value(identity),
      history: i0.Value(history),
    );
  }

  factory HistoryIdentity.fromJson(
    Map<String, dynamic> json, {
    i0.ValueSerializer? serializer,
  }) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return HistoryIdentity(
      identity: serializer.fromJson<int>(json['identity']),
      history: serializer.fromJson<int>(json['history']),
    );
  }
  @override
  Map<String, dynamic> toJson({i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'identity': serializer.toJson<int>(identity),
      'history': serializer.toJson<int>(history),
    };
  }

  i2.HistoryIdentity copyWith({int? identity, int? history}) =>
      i2.HistoryIdentity(
        identity: identity ?? this.identity,
        history: history ?? this.history,
      );
  HistoryIdentity copyWithCompanion(i2.HistoryIdentityCompanion data) {
    return HistoryIdentity(
      identity: data.identity.present ? data.identity.value : this.identity,
      history: data.history.present ? data.history.value : this.history,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HistoryIdentity(')
          ..write('identity: $identity, ')
          ..write('history: $history')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(identity, history);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is i2.HistoryIdentity &&
          other.identity == this.identity &&
          other.history == this.history);
}

class HistoryIdentityCompanion extends i0.UpdateCompanion<i2.HistoryIdentity> {
  final i0.Value<int> identity;
  final i0.Value<int> history;
  final i0.Value<int> rowid;
  const HistoryIdentityCompanion({
    this.identity = const i0.Value.absent(),
    this.history = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  });
  HistoryIdentityCompanion.insert({
    required int identity,
    required int history,
    this.rowid = const i0.Value.absent(),
  }) : identity = i0.Value(identity),
       history = i0.Value(history);
  static i0.Insertable<i2.HistoryIdentity> custom({
    i0.Expression<int>? identity,
    i0.Expression<int>? history,
    i0.Expression<int>? rowid,
  }) {
    return i0.RawValuesInsertable({
      if (identity != null) 'identity': identity,
      if (history != null) 'history': history,
      if (rowid != null) 'rowid': rowid,
    });
  }

  i2.HistoryIdentityCompanion copyWith({
    i0.Value<int>? identity,
    i0.Value<int>? history,
    i0.Value<int>? rowid,
  }) {
    return i2.HistoryIdentityCompanion(
      identity: identity ?? this.identity,
      history: history ?? this.history,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (identity.present) {
      map['identity'] = i0.Variable<int>(identity.value);
    }
    if (history.present) {
      map['history'] = i0.Variable<int>(history.value);
    }
    if (rowid.present) {
      map['rowid'] = i0.Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistoryIdentityCompanion(')
          ..write('identity: $identity, ')
          ..write('history: $history, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}
