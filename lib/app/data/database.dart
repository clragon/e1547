import 'package:dio_cache_interceptor_db_store/dio_cache_interceptor_db_store.dart';
import 'package:drift/drift.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:notified_preferences/notified_preferences.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

Future<AppDatabases> initializeAppdatabases({required AppInfo info}) async {
  final String temporaryFiles = await getTemporaryDirectory()
      .then((value) => join(value.path, info.appName));
  return AppDatabases(
    preferences: await SharedPreferences.getInstance(),
    temporaryFiles: temporaryFiles,
    httpCache: DbCacheStore(databasePath: temporaryFiles),
    httpMemoryCache: MemCacheStore(),
    followDb: connectDatabase('follows.sqlite'),
    historyDb: connectDatabase('history.sqlite'),
  );
}

/// Holds various databases for the app.
class AppDatabases {
  const AppDatabases({
    required this.preferences,
    required this.temporaryFiles,
    required this.httpCache,
    required this.httpMemoryCache,
    required this.followDb,
    required this.historyDb,
  });

  final SharedPreferences preferences;
  final String temporaryFiles;
  final CacheStore httpCache;
  final CacheStore httpMemoryCache;
  final DatabaseConnection followDb;
  final DatabaseConnection historyDb;

  void dispose() {
    httpCache.close();
    httpMemoryCache.close();
    followDb.executor.close();
    historyDb.executor.close();
  }
}
