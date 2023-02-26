import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_db_store/dio_cache_interceptor_db_store.dart';
import 'package:drift/drift.dart';
import 'package:e1547/interface/interface.dart';
import 'package:notified_preferences/notified_preferences.dart';
import 'package:path_provider/path_provider.dart';

Future<AppDatabases> initializeAppdatabases() async => AppDatabases(
      preferences: await SharedPreferences.getInstance(),
      followDb: connectDatabase('follows.sqlite'),
      historyDb: connectDatabase('history.sqlite'),
      httpCache: DbCacheStore(
        databasePath: (await getTemporaryDirectory()).path,
      ),
    );

/// Holds various databases for the app.
class AppDatabases {
  const AppDatabases({
    required this.preferences,
    required this.followDb,
    required this.historyDb,
    required this.httpCache,
  });

  final DatabaseConnection historyDb;
  final DatabaseConnection followDb;
  final CacheStore httpCache;
  final SharedPreferences preferences;

  void dispose() {
    historyDb.executor.close();
    followDb.executor.close();
    httpCache.close();
  }
}
