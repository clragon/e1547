// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:drift/src/runtime/api/runtime_api.dart' as i1;
import 'package:e1547/identity/data/database.drift.dart' as i2;
import 'package:drift/internal/modular.dart' as i3;
import 'package:e1547/identity/data/identity.dart' as i4;
import 'package:e1547/identity/data/database.dart' as i5;
import 'package:e1547/interface/data/sql.dart' as i6;

typedef $$IdentitiesTableTableCreateCompanionBuilder =
    i2.IdentityCompanion Function({
      i0.Value<int> id,
      required String host,
      required String? username,
      i0.Value<Map<String, String>?> headers,
    });
typedef $$IdentitiesTableTableUpdateCompanionBuilder =
    i2.IdentityCompanion Function({
      i0.Value<int> id,
      i0.Value<String> host,
      i0.Value<String?> username,
      i0.Value<Map<String, String>?> headers,
    });

class $$IdentitiesTableTableFilterComposer
    extends i0.Composer<i0.GeneratedDatabase, i2.$IdentitiesTableTable> {
  $$IdentitiesTableTableFilterComposer({
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

  i0.ColumnFilters<String> get host => $composableBuilder(
    column: $table.host,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnWithTypeConverterFilters<String?, String, String> get username =>
      $composableBuilder(
        column: $table.username,
        builder: (column) => i0.ColumnWithTypeConverterFilters(column),
      );

  i0.ColumnWithTypeConverterFilters<
    Map<String, String>?,
    Map<String, String>,
    String
  >
  get headers => $composableBuilder(
    column: $table.headers,
    builder: (column) => i0.ColumnWithTypeConverterFilters(column),
  );
}

class $$IdentitiesTableTableOrderingComposer
    extends i0.Composer<i0.GeneratedDatabase, i2.$IdentitiesTableTable> {
  $$IdentitiesTableTableOrderingComposer({
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

  i0.ColumnOrderings<String> get host => $composableBuilder(
    column: $table.host,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get headers => $composableBuilder(
    column: $table.headers,
    builder: (column) => i0.ColumnOrderings(column),
  );
}

class $$IdentitiesTableTableAnnotationComposer
    extends i0.Composer<i0.GeneratedDatabase, i2.$IdentitiesTableTable> {
  $$IdentitiesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  i0.GeneratedColumn<String> get host =>
      $composableBuilder(column: $table.host, builder: (column) => column);

  i0.GeneratedColumnWithTypeConverter<String?, String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  i0.GeneratedColumnWithTypeConverter<Map<String, String>?, String>
  get headers =>
      $composableBuilder(column: $table.headers, builder: (column) => column);
}

class $$IdentitiesTableTableTableManager
    extends
        i0.RootTableManager<
          i0.GeneratedDatabase,
          i2.$IdentitiesTableTable,
          i4.Identity,
          i2.$$IdentitiesTableTableFilterComposer,
          i2.$$IdentitiesTableTableOrderingComposer,
          i2.$$IdentitiesTableTableAnnotationComposer,
          $$IdentitiesTableTableCreateCompanionBuilder,
          $$IdentitiesTableTableUpdateCompanionBuilder,
          (
            i4.Identity,
            i0.BaseReferences<
              i0.GeneratedDatabase,
              i2.$IdentitiesTableTable,
              i4.Identity
            >,
          ),
          i4.Identity,
          i0.PrefetchHooks Function()
        > {
  $$IdentitiesTableTableTableManager(
    i0.GeneratedDatabase db,
    i2.$IdentitiesTableTable table,
  ) : super(
        i0.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              i2.$$IdentitiesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              i2.$$IdentitiesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => i2
              .$$IdentitiesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                i0.Value<int> id = const i0.Value.absent(),
                i0.Value<String> host = const i0.Value.absent(),
                i0.Value<String?> username = const i0.Value.absent(),
                i0.Value<Map<String, String>?> headers =
                    const i0.Value.absent(),
              }) => i2.IdentityCompanion(
                id: id,
                host: host,
                username: username,
                headers: headers,
              ),
          createCompanionCallback:
              ({
                i0.Value<int> id = const i0.Value.absent(),
                required String host,
                required String? username,
                i0.Value<Map<String, String>?> headers =
                    const i0.Value.absent(),
              }) => i2.IdentityCompanion.insert(
                id: id,
                host: host,
                username: username,
                headers: headers,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), i0.BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IdentitiesTableTableProcessedTableManager =
    i0.ProcessedTableManager<
      i0.GeneratedDatabase,
      i2.$IdentitiesTableTable,
      i4.Identity,
      i2.$$IdentitiesTableTableFilterComposer,
      i2.$$IdentitiesTableTableOrderingComposer,
      i2.$$IdentitiesTableTableAnnotationComposer,
      $$IdentitiesTableTableCreateCompanionBuilder,
      $$IdentitiesTableTableUpdateCompanionBuilder,
      (
        i4.Identity,
        i0.BaseReferences<
          i0.GeneratedDatabase,
          i2.$IdentitiesTableTable,
          i4.Identity
        >,
      ),
      i4.Identity,
      i0.PrefetchHooks Function()
    >;
mixin $IdentityRepositoryMixin on i0.DatabaseAccessor<i1.GeneratedDatabase> {
  i2.$IdentitiesTableTable get identitiesTable => i3.ReadDatabaseContainer(
    attachedDatabase,
  ).resultSet<i2.$IdentitiesTableTable>('identities_table');
}

class $IdentitiesTableTable extends i5.IdentitiesTable
    with i0.TableInfo<$IdentitiesTableTable, i4.Identity> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IdentitiesTableTable(this.attachedDatabase, [this._alias]);
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
  static const i0.VerificationMeta _hostMeta = const i0.VerificationMeta(
    'host',
  );
  @override
  late final i0.GeneratedColumn<String> host = i0.GeneratedColumn<String>(
    'host',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final i0.GeneratedColumnWithTypeConverter<String?, String> username =
      i0.GeneratedColumn<String>(
        'username',
        aliasedName,
        false,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<String?>(i2.$IdentitiesTableTable.$converterusername);
  @override
  late final i0.GeneratedColumnWithTypeConverter<Map<String, String>?, String>
  headers =
      i0.GeneratedColumn<String>(
        'headers',
        aliasedName,
        true,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Map<String, String>?>(
        i2.$IdentitiesTableTable.$converterheadersn,
      );
  @override
  List<i0.GeneratedColumn> get $columns => [id, host, username, headers];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'identities_table';
  @override
  i0.VerificationContext validateIntegrity(
    i0.Insertable<i4.Identity> instance, {
    bool isInserting = false,
  }) {
    final context = i0.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('host')) {
      context.handle(
        _hostMeta,
        host.isAcceptableOrUnknown(data['host']!, _hostMeta),
      );
    } else if (isInserting) {
      context.missing(_hostMeta);
    }
    return context;
  }

  @override
  Set<i0.GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<i0.GeneratedColumn>> get uniqueKeys => [
    {host, username},
  ];
  @override
  i4.Identity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i4.Identity(
      id: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      host: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}host'],
      )!,
      username: i2.$IdentitiesTableTable.$converterusername.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.string,
          data['${effectivePrefix}username'],
        )!,
      ),
      headers: i2.$IdentitiesTableTable.$converterheadersn.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.string,
          data['${effectivePrefix}headers'],
        ),
      ),
    );
  }

  @override
  $IdentitiesTableTable createAlias(String alias) {
    return $IdentitiesTableTable(attachedDatabase, alias);
  }

  static i0.TypeConverter<String?, String> $converterusername =
      const i5.NullToEmptyStringSqlConverter();
  static i0.TypeConverter<Map<String, String>, String> $converterheaders =
      i6.JsonSqlConverter.map<String>();
  static i0.TypeConverter<Map<String, String>?, String?> $converterheadersn =
      i0.NullAwareTypeConverter.wrap($converterheaders);
}

class IdentityCompanion extends i0.UpdateCompanion<i4.Identity> {
  final i0.Value<int> id;
  final i0.Value<String> host;
  final i0.Value<String?> username;
  final i0.Value<Map<String, String>?> headers;
  const IdentityCompanion({
    this.id = const i0.Value.absent(),
    this.host = const i0.Value.absent(),
    this.username = const i0.Value.absent(),
    this.headers = const i0.Value.absent(),
  });
  IdentityCompanion.insert({
    this.id = const i0.Value.absent(),
    required String host,
    required String? username,
    this.headers = const i0.Value.absent(),
  }) : host = i0.Value(host),
       username = i0.Value(username);
  static i0.Insertable<i4.Identity> custom({
    i0.Expression<int>? id,
    i0.Expression<String>? host,
    i0.Expression<String>? username,
    i0.Expression<String>? headers,
  }) {
    return i0.RawValuesInsertable({
      if (id != null) 'id': id,
      if (host != null) 'host': host,
      if (username != null) 'username': username,
      if (headers != null) 'headers': headers,
    });
  }

  i2.IdentityCompanion copyWith({
    i0.Value<int>? id,
    i0.Value<String>? host,
    i0.Value<String?>? username,
    i0.Value<Map<String, String>?>? headers,
  }) {
    return i2.IdentityCompanion(
      id: id ?? this.id,
      host: host ?? this.host,
      username: username ?? this.username,
      headers: headers ?? this.headers,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (id.present) {
      map['id'] = i0.Variable<int>(id.value);
    }
    if (host.present) {
      map['host'] = i0.Variable<String>(host.value);
    }
    if (username.present) {
      map['username'] = i0.Variable<String>(
        i2.$IdentitiesTableTable.$converterusername.toSql(username.value),
      );
    }
    if (headers.present) {
      map['headers'] = i0.Variable<String>(
        i2.$IdentitiesTableTable.$converterheadersn.toSql(headers.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IdentityCompanion(')
          ..write('id: $id, ')
          ..write('host: $host, ')
          ..write('username: $username, ')
          ..write('headers: $headers')
          ..write(')'))
        .toString();
  }
}

class _$IdentityInsertable implements i0.Insertable<i4.Identity> {
  i4.Identity _object;
  _$IdentityInsertable(this._object);
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    return i2.IdentityCompanion(
      id: i0.Value(_object.id),
      host: i0.Value(_object.host),
      username: i0.Value(_object.username),
      headers: i0.Value(_object.headers),
    ).toColumns(false);
  }
}

extension IdentityToInsertable on i4.Identity {
  _$IdentityInsertable toInsertable() {
    return _$IdentityInsertable(this);
  }
}
