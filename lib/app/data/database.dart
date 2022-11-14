import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:drift/drift.dart';
import 'package:notified_preferences/notified_preferences.dart';

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
}
