// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:e1547/identity/data/database.drift.dart' as i1;
import 'package:e1547/traits/data/database.drift.dart' as i2;
import 'package:e1547/history/data/database.drift.dart' as i3;
import 'package:e1547/follow/data/database.drift.dart' as i4;

abstract class $AppDatabase extends i0.GeneratedDatabase {
  $AppDatabase(i0.QueryExecutor e) : super(e);
  late final i1.$IdentitiesTableTable identitiesTable =
      i1.$IdentitiesTableTable(this);
  late final i2.$TraitsTableTable traitsTable = i2.$TraitsTableTable(this);
  late final i3.$HistoriesTableTable historiesTable =
      i3.$HistoriesTableTable(this);
  late final i3.$HistoriesIdentitiesTableTable historiesIdentitiesTable =
      i3.$HistoriesIdentitiesTableTable(this);
  late final i4.$FollowsTableTable followsTable = i4.$FollowsTableTable(this);
  late final i4.$FollowsIdentitiesTableTable followsIdentitiesTable =
      i4.$FollowsIdentitiesTableTable(this);
  @override
  Iterable<i0.TableInfo<i0.Table, Object?>> get allTables =>
      allSchemaEntities.whereType<i0.TableInfo<i0.Table, Object?>>();
  @override
  List<i0.DatabaseSchemaEntity> get allSchemaEntities => [
        identitiesTable,
        traitsTable,
        historiesTable,
        historiesIdentitiesTable,
        followsTable,
        followsIdentitiesTable
      ];
  @override
  i0.StreamQueryUpdateRules get streamUpdateRules =>
      const i0.StreamQueryUpdateRules(
        [
          i0.WritePropagation(
            on: i0.TableUpdateQuery.onTableName('identities_table',
                limitUpdateKind: i0.UpdateKind.delete),
            result: [
              i0.TableUpdate('traits_table', kind: i0.UpdateKind.delete),
            ],
          ),
          i0.WritePropagation(
            on: i0.TableUpdateQuery.onTableName('identities_table',
                limitUpdateKind: i0.UpdateKind.update),
            result: [
              i0.TableUpdate('traits_table', kind: i0.UpdateKind.update),
            ],
          ),
          i0.WritePropagation(
            on: i0.TableUpdateQuery.onTableName('histories_table',
                limitUpdateKind: i0.UpdateKind.delete),
            result: [
              i0.TableUpdate('histories_identities_table',
                  kind: i0.UpdateKind.delete),
            ],
          ),
          i0.WritePropagation(
            on: i0.TableUpdateQuery.onTableName('histories_table',
                limitUpdateKind: i0.UpdateKind.update),
            result: [
              i0.TableUpdate('histories_identities_table',
                  kind: i0.UpdateKind.update),
            ],
          ),
          i0.WritePropagation(
            on: i0.TableUpdateQuery.onTableName('follows_table',
                limitUpdateKind: i0.UpdateKind.delete),
            result: [
              i0.TableUpdate('follows_identities_table',
                  kind: i0.UpdateKind.delete),
            ],
          ),
          i0.WritePropagation(
            on: i0.TableUpdateQuery.onTableName('follows_table',
                limitUpdateKind: i0.UpdateKind.update),
            result: [
              i0.TableUpdate('follows_identities_table',
                  kind: i0.UpdateKind.update),
            ],
          ),
        ],
      );
}
