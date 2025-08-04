import 'package:drift/drift.dart';
import 'package:e1547/identity/data/client.dart';
import 'package:e1547/traits/traits.dart';
import 'package:http_cache_drift_store/http_cache_drift_store.dart';
import 'package:notified_preferences/notified_preferences.dart';

// ignore: always_use_package_imports
import 'storage.drift.dart';

@DriftDatabase(tables: [IdentitiesTable, TraitsTable])
class AppDatabase extends $AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
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
  final DriftCacheStore? httpCache;
  final AppDatabase sqlite;

  Future<void> close() async {
    await httpCache?.close();
    await sqlite.close();
  }
}
