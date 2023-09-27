import 'package:drift/drift.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:notified_preferences/notified_preferences.dart';

/// Holds various databases for the app.
class AppStorage {
  const AppStorage({
    required this.preferences,
    required this.temporaryFiles,
    required this.httpCache,
    required this.httpMemoryCache,
    required this.cookies,
    required this.followDb,
    required this.historyDb,
  });

  final SharedPreferences preferences;
  final String temporaryFiles;
  final CacheStore httpCache;
  final CacheStore httpMemoryCache;
  final CookiesService cookies;
  final DatabaseConnection followDb;
  final DatabaseConnection historyDb;

  void dispose() {
    httpCache.close();
    httpMemoryCache.close();
    followDb.executor.close();
    historyDb.executor.close();
  }
}
