import 'package:drift/drift.dart';
import 'package:e1547/follow/data/database.dart';
import 'package:e1547/history/data/database.dart';
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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) => customStatement('PRAGMA foreign_keys = ON'),
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
        },
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

  void dispose() {
    httpCache?.close();
    sqlite.executor.close();
  }
}
