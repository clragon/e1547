// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:e1547/identity/data/client.drift.dart' as i1;
import 'package:e1547/traits/data/client.drift.dart' as i2;

abstract class $AppDatabase extends i0.GeneratedDatabase {
  $AppDatabase(i0.QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final i1.$IdentitiesTableTable identitiesTable = i1
      .$IdentitiesTableTable(this);
  late final i2.$TraitsTableTable traitsTable = i2.$TraitsTableTable(this);
  @override
  Iterable<i0.TableInfo<i0.Table, Object?>> get allTables =>
      allSchemaEntities.whereType<i0.TableInfo<i0.Table, Object?>>();
  @override
  List<i0.DatabaseSchemaEntity> get allSchemaEntities => [
    identitiesTable,
    traitsTable,
  ];
  @override
  i0.StreamQueryUpdateRules get streamUpdateRules =>
      const i0.StreamQueryUpdateRules([
        i0.WritePropagation(
          on: i0.TableUpdateQuery.onTableName(
            'identities_table',
            limitUpdateKind: i0.UpdateKind.delete,
          ),
          result: [i0.TableUpdate('traits_table', kind: i0.UpdateKind.delete)],
        ),
        i0.WritePropagation(
          on: i0.TableUpdateQuery.onTableName(
            'identities_table',
            limitUpdateKind: i0.UpdateKind.update,
          ),
          result: [i0.TableUpdate('traits_table', kind: i0.UpdateKind.update)],
        ),
      ]);
}

class $AppDatabaseManager {
  final $AppDatabase _db;
  $AppDatabaseManager(this._db);
  i1.$$IdentitiesTableTableTableManager get identitiesTable =>
      i1.$$IdentitiesTableTableTableManager(_db, _db.identitiesTable);
  i2.$$TraitsTableTableTableManager get traitsTable =>
      i2.$$TraitsTableTableTableManager(_db, _db.traitsTable);
}
