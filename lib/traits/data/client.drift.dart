// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:drift/src/runtime/api/runtime_api.dart' as i1;
import 'package:e1547/identity/data/client.drift.dart' as i2;
import 'package:drift/internal/modular.dart' as i3;
import 'package:e1547/traits/data/client.drift.dart' as i4;
import 'package:e1547/traits/data/traits.dart' as i5;
import 'package:e1547/traits/data/client.dart' as i6;
import 'package:e1547/shared/data/sql.dart' as i7;

typedef $$TraitsTableTableCreateCompanionBuilder =
    i4.TraitsCompanion Function({
      i0.Value<int> id,
      i0.Value<int?> userId,
      required List<String> denylist,
      required String homeTags,
      i0.Value<String?> avatar,
      i0.Value<int?> perPage,
    });
typedef $$TraitsTableTableUpdateCompanionBuilder =
    i4.TraitsCompanion Function({
      i0.Value<int> id,
      i0.Value<int?> userId,
      i0.Value<List<String>> denylist,
      i0.Value<String> homeTags,
      i0.Value<String?> avatar,
      i0.Value<int?> perPage,
    });

final class $$TraitsTableTableReferences
    extends
        i0.BaseReferences<
          i0.GeneratedDatabase,
          i4.$TraitsTableTable,
          i5.Traits
        > {
  $$TraitsTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static i2.$IdentitiesTableTable _idTable(i0.GeneratedDatabase db) =>
      i3.ReadDatabaseContainer(db)
          .resultSet<i2.$IdentitiesTableTable>('identities_table')
          .createAlias(
            i0.$_aliasNameGenerator(
              i3.ReadDatabaseContainer(
                db,
              ).resultSet<i4.$TraitsTableTable>('traits_table').id,
              i3.ReadDatabaseContainer(
                db,
              ).resultSet<i2.$IdentitiesTableTable>('identities_table').id,
            ),
          );

  i2.$$IdentitiesTableTableProcessedTableManager get id {
    final $_column = $_itemColumn<int>('id')!;

    final manager = i2
        .$$IdentitiesTableTableTableManager(
          $_db,
          i3.ReadDatabaseContainer(
            $_db,
          ).resultSet<i2.$IdentitiesTableTable>('identities_table'),
        )
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_idTable($_db));
    if (item == null) return manager;
    return i0.ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TraitsTableTableFilterComposer
    extends i0.Composer<i0.GeneratedDatabase, i4.$TraitsTableTable> {
  $$TraitsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get denylist => $composableBuilder(
    column: $table.denylist,
    builder: (column) => i0.ColumnWithTypeConverterFilters(column),
  );

  i0.ColumnFilters<String> get homeTags => $composableBuilder(
    column: $table.homeTags,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<int> get perPage => $composableBuilder(
    column: $table.perPage,
    builder: (column) => i0.ColumnFilters(column),
  );

  i2.$$IdentitiesTableTableFilterComposer get id {
    final i2.$$IdentitiesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: i3.ReadDatabaseContainer(
        $db,
      ).resultSet<i2.$IdentitiesTableTable>('identities_table'),
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i2.$$IdentitiesTableTableFilterComposer(
            $db: $db,
            $table: i3.ReadDatabaseContainer(
              $db,
            ).resultSet<i2.$IdentitiesTableTable>('identities_table'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TraitsTableTableOrderingComposer
    extends i0.Composer<i0.GeneratedDatabase, i4.$TraitsTableTable> {
  $$TraitsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get denylist => $composableBuilder(
    column: $table.denylist,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get homeTags => $composableBuilder(
    column: $table.homeTags,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<int> get perPage => $composableBuilder(
    column: $table.perPage,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i2.$$IdentitiesTableTableOrderingComposer get id {
    final i2.$$IdentitiesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: i3.ReadDatabaseContainer(
        $db,
      ).resultSet<i2.$IdentitiesTableTable>('identities_table'),
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i2.$$IdentitiesTableTableOrderingComposer(
            $db: $db,
            $table: i3.ReadDatabaseContainer(
              $db,
            ).resultSet<i2.$IdentitiesTableTable>('identities_table'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TraitsTableTableAnnotationComposer
    extends i0.Composer<i0.GeneratedDatabase, i4.$TraitsTableTable> {
  $$TraitsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  i0.GeneratedColumnWithTypeConverter<List<String>, String> get denylist =>
      $composableBuilder(column: $table.denylist, builder: (column) => column);

  i0.GeneratedColumn<String> get homeTags =>
      $composableBuilder(column: $table.homeTags, builder: (column) => column);

  i0.GeneratedColumn<String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => column);

  i0.GeneratedColumn<int> get perPage =>
      $composableBuilder(column: $table.perPage, builder: (column) => column);

  i2.$$IdentitiesTableTableAnnotationComposer get id {
    final i2.$$IdentitiesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: i3.ReadDatabaseContainer(
            $db,
          ).resultSet<i2.$IdentitiesTableTable>('identities_table'),
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => i2.$$IdentitiesTableTableAnnotationComposer(
                $db: $db,
                $table: i3.ReadDatabaseContainer(
                  $db,
                ).resultSet<i2.$IdentitiesTableTable>('identities_table'),
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$TraitsTableTableTableManager
    extends
        i0.RootTableManager<
          i0.GeneratedDatabase,
          i4.$TraitsTableTable,
          i5.Traits,
          i4.$$TraitsTableTableFilterComposer,
          i4.$$TraitsTableTableOrderingComposer,
          i4.$$TraitsTableTableAnnotationComposer,
          $$TraitsTableTableCreateCompanionBuilder,
          $$TraitsTableTableUpdateCompanionBuilder,
          (i5.Traits, i4.$$TraitsTableTableReferences),
          i5.Traits,
          i0.PrefetchHooks Function({bool id})
        > {
  $$TraitsTableTableTableManager(
    i0.GeneratedDatabase db,
    i4.$TraitsTableTable table,
  ) : super(
        i0.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              i4.$$TraitsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              i4.$$TraitsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              i4.$$TraitsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                i0.Value<int> id = const i0.Value.absent(),
                i0.Value<int?> userId = const i0.Value.absent(),
                i0.Value<List<String>> denylist = const i0.Value.absent(),
                i0.Value<String> homeTags = const i0.Value.absent(),
                i0.Value<String?> avatar = const i0.Value.absent(),
                i0.Value<int?> perPage = const i0.Value.absent(),
              }) => i4.TraitsCompanion(
                id: id,
                userId: userId,
                denylist: denylist,
                homeTags: homeTags,
                avatar: avatar,
                perPage: perPage,
              ),
          createCompanionCallback:
              ({
                i0.Value<int> id = const i0.Value.absent(),
                i0.Value<int?> userId = const i0.Value.absent(),
                required List<String> denylist,
                required String homeTags,
                i0.Value<String?> avatar = const i0.Value.absent(),
                i0.Value<int?> perPage = const i0.Value.absent(),
              }) => i4.TraitsCompanion.insert(
                id: id,
                userId: userId,
                denylist: denylist,
                homeTags: homeTags,
                avatar: avatar,
                perPage: perPage,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  i4.$$TraitsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({id = false}) {
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
                    if (id) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.id,
                                referencedTable: i4.$$TraitsTableTableReferences
                                    ._idTable(db),
                                referencedColumn: i4
                                    .$$TraitsTableTableReferences
                                    ._idTable(db)
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

typedef $$TraitsTableTableProcessedTableManager =
    i0.ProcessedTableManager<
      i0.GeneratedDatabase,
      i4.$TraitsTableTable,
      i5.Traits,
      i4.$$TraitsTableTableFilterComposer,
      i4.$$TraitsTableTableOrderingComposer,
      i4.$$TraitsTableTableAnnotationComposer,
      $$TraitsTableTableCreateCompanionBuilder,
      $$TraitsTableTableUpdateCompanionBuilder,
      (i5.Traits, i4.$$TraitsTableTableReferences),
      i5.Traits,
      i0.PrefetchHooks Function({bool id})
    >;
mixin $TraitsClientMixin on i0.DatabaseAccessor<i1.GeneratedDatabase> {
  i2.$IdentitiesTableTable get identitiesTable => i3.ReadDatabaseContainer(
    attachedDatabase,
  ).resultSet<i2.$IdentitiesTableTable>('identities_table');
  i4.$TraitsTableTable get traitsTable => i3.ReadDatabaseContainer(
    attachedDatabase,
  ).resultSet<i4.$TraitsTableTable>('traits_table');
}

class $TraitsTableTable extends i6.TraitsTable
    with i0.TableInfo<$TraitsTableTable, i5.Traits> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TraitsTableTable(this.attachedDatabase, [this._alias]);
  static const i0.VerificationMeta _idMeta = const i0.VerificationMeta('id');
  @override
  late final i0.GeneratedColumn<int> id = i0.GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: i0.DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: i0.GeneratedColumn.constraintIsAlways(
      'REFERENCES identities_table (id) ON UPDATE CASCADE ON DELETE CASCADE',
    ),
  );
  static const i0.VerificationMeta _userIdMeta = const i0.VerificationMeta(
    'userId',
  );
  @override
  late final i0.GeneratedColumn<int> userId = i0.GeneratedColumn<int>(
    'user_id',
    aliasedName,
    true,
    type: i0.DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final i0.GeneratedColumnWithTypeConverter<List<String>, String>
  denylist = i0.GeneratedColumn<String>(
    'denylist',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<List<String>>(i4.$TraitsTableTable.$converterdenylist);
  static const i0.VerificationMeta _homeTagsMeta = const i0.VerificationMeta(
    'homeTags',
  );
  @override
  late final i0.GeneratedColumn<String> homeTags = i0.GeneratedColumn<String>(
    'home_tags',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const i0.VerificationMeta _avatarMeta = const i0.VerificationMeta(
    'avatar',
  );
  @override
  late final i0.GeneratedColumn<String> avatar = i0.GeneratedColumn<String>(
    'avatar',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const i0.VerificationMeta _perPageMeta = const i0.VerificationMeta(
    'perPage',
  );
  @override
  late final i0.GeneratedColumn<int> perPage = i0.GeneratedColumn<int>(
    'per_page',
    aliasedName,
    true,
    type: i0.DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<i0.GeneratedColumn> get $columns => [
    id,
    userId,
    denylist,
    homeTags,
    avatar,
    perPage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'traits_table';
  @override
  i0.VerificationContext validateIntegrity(
    i0.Insertable<i5.Traits> instance, {
    bool isInserting = false,
  }) {
    final context = i0.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('home_tags')) {
      context.handle(
        _homeTagsMeta,
        homeTags.isAcceptableOrUnknown(data['home_tags']!, _homeTagsMeta),
      );
    } else if (isInserting) {
      context.missing(_homeTagsMeta);
    }
    if (data.containsKey('avatar')) {
      context.handle(
        _avatarMeta,
        avatar.isAcceptableOrUnknown(data['avatar']!, _avatarMeta),
      );
    }
    if (data.containsKey('per_page')) {
      context.handle(
        _perPageMeta,
        perPage.isAcceptableOrUnknown(data['per_page']!, _perPageMeta),
      );
    }
    return context;
  }

  @override
  Set<i0.GeneratedColumn> get $primaryKey => {id};
  @override
  i5.Traits map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i5.Traits(
      id: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      ),
      denylist: i4.$TraitsTableTable.$converterdenylist.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.string,
          data['${effectivePrefix}denylist'],
        )!,
      ),
      homeTags: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}home_tags'],
      )!,
      avatar: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}avatar'],
      ),
      perPage: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.int,
        data['${effectivePrefix}per_page'],
      ),
    );
  }

  @override
  $TraitsTableTable createAlias(String alias) {
    return $TraitsTableTable(attachedDatabase, alias);
  }

  static i0.TypeConverter<List<String>, String> $converterdenylist =
      i7.JsonSqlConverter.list<String>();
}

class TraitsCompanion extends i0.UpdateCompanion<i5.Traits> {
  final i0.Value<int> id;
  final i0.Value<int?> userId;
  final i0.Value<List<String>> denylist;
  final i0.Value<String> homeTags;
  final i0.Value<String?> avatar;
  final i0.Value<int?> perPage;
  const TraitsCompanion({
    this.id = const i0.Value.absent(),
    this.userId = const i0.Value.absent(),
    this.denylist = const i0.Value.absent(),
    this.homeTags = const i0.Value.absent(),
    this.avatar = const i0.Value.absent(),
    this.perPage = const i0.Value.absent(),
  });
  TraitsCompanion.insert({
    this.id = const i0.Value.absent(),
    this.userId = const i0.Value.absent(),
    required List<String> denylist,
    required String homeTags,
    this.avatar = const i0.Value.absent(),
    this.perPage = const i0.Value.absent(),
  }) : denylist = i0.Value(denylist),
       homeTags = i0.Value(homeTags);
  static i0.Insertable<i5.Traits> custom({
    i0.Expression<int>? id,
    i0.Expression<int>? userId,
    i0.Expression<String>? denylist,
    i0.Expression<String>? homeTags,
    i0.Expression<String>? avatar,
    i0.Expression<int>? perPage,
  }) {
    return i0.RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (denylist != null) 'denylist': denylist,
      if (homeTags != null) 'home_tags': homeTags,
      if (avatar != null) 'avatar': avatar,
      if (perPage != null) 'per_page': perPage,
    });
  }

  i4.TraitsCompanion copyWith({
    i0.Value<int>? id,
    i0.Value<int?>? userId,
    i0.Value<List<String>>? denylist,
    i0.Value<String>? homeTags,
    i0.Value<String?>? avatar,
    i0.Value<int?>? perPage,
  }) {
    return i4.TraitsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      denylist: denylist ?? this.denylist,
      homeTags: homeTags ?? this.homeTags,
      avatar: avatar ?? this.avatar,
      perPage: perPage ?? this.perPage,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (id.present) {
      map['id'] = i0.Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = i0.Variable<int>(userId.value);
    }
    if (denylist.present) {
      map['denylist'] = i0.Variable<String>(
        i4.$TraitsTableTable.$converterdenylist.toSql(denylist.value),
      );
    }
    if (homeTags.present) {
      map['home_tags'] = i0.Variable<String>(homeTags.value);
    }
    if (avatar.present) {
      map['avatar'] = i0.Variable<String>(avatar.value);
    }
    if (perPage.present) {
      map['per_page'] = i0.Variable<int>(perPage.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TraitsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('denylist: $denylist, ')
          ..write('homeTags: $homeTags, ')
          ..write('avatar: $avatar, ')
          ..write('perPage: $perPage')
          ..write(')'))
        .toString();
  }
}

class _$TraitsInsertable implements i0.Insertable<i5.Traits> {
  i5.Traits _object;
  _$TraitsInsertable(this._object);
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    return i4.TraitsCompanion(
      id: i0.Value(_object.id),
      userId: i0.Value(_object.userId),
      denylist: i0.Value(_object.denylist),
      homeTags: i0.Value(_object.homeTags),
      avatar: i0.Value(_object.avatar),
      perPage: i0.Value(_object.perPage),
    ).toColumns(false);
  }
}

extension TraitsToInsertable on i5.Traits {
  _$TraitsInsertable toInsertable() {
    return _$TraitsInsertable(this);
  }
}
