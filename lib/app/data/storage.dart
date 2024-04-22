import 'package:drift/drift.dart';
import 'package:e1547/follow/data/database.dart';
import 'package:e1547/history/data/database.drift.dart';
import 'package:e1547/history/data/legacy.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/identity/data/database.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/traits/traits.dart';
import 'package:notified_preferences/notified_preferences.dart';

// ignore: always_use_package_imports
import 'storage.drift.dart';

@DriftDatabase(tables: [
  IdentitiesTable,
  TraitsTable,
  HistoriesTable,
  HistoriesIdentitiesTable,
  FollowsTable,
  FollowsIdentitiesTable,
])
class AppDatabase extends $AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) {
          return m.createAll().then((_) async {
            await customStatement('''
              CREATE TRIGGER delete_identity_follows
              AFTER DELETE ON identities_table
              BEGIN
                  DELETE FROM follows_table
                  WHERE id IN (SELECT follow FROM follows_identities_table WHERE identity = OLD.id);
              END;
              CREATE TRIGGER delete_identity_histories
              AFTER DELETE ON identities_table
              BEGIN
                  DELETE FROM histories_table
                  WHERE id IN (SELECT history FROM histories_identities_table WHERE identity = OLD.id);
              END;
            ''');
          });
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(traitsTable, traitsTable.avatar);
            await m.addColumn(traitsTable, traitsTable.favicon);
          }
          if (from < 3) {
            await m.alterTable(TableMigration(historiesTable, newColumns: [
              historiesTable.category,
              historiesTable.type,
            ], columnTransformer: {
              historiesTable.category: Variable(HistoryCategory.items.name),
              historiesTable.type: Variable(HistoryType.posts.name),
            }));

            await transaction(() async {
              List<(int, String)> items = await (historiesTable.selectOnly()
                    ..addColumns([historiesTable.id, historiesTable.link]))
                  .map((row) => (
                        row.read(historiesTable.id)!,
                        row.read(historiesTable.link)!
                      ))
                  .get();
              await batch((batch) async {
                for (final (id, link) in items) {
                  batch.update(
                    historiesTable,
                    HistoryCompanion(
                      category: Value(getHistoryCategory(link)!),
                      type: Value(getHistoryType(link)!),
                    ),
                    where: (tbl) => tbl.id.equals(id),
                  );
                }
              });
            });
          }
        },
        beforeOpen: (details) => customStatement('PRAGMA foreign_keys = ON'),
      );
}

/// Holds various databases for the app.
class AppStorage {
  const AppStorage({
    required this.preferences,
    required this.temporaryFiles,
    required this.httpCache,
    required this.sqlite,
  });

  final SharedPreferences preferences;
  final String temporaryFiles;
  final CacheStore? httpCache;
  final AppDatabase sqlite;
}
