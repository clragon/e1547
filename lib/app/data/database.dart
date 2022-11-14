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

  final DatabaseCarrier historyDb;
  final DatabaseCarrier followDb;
  final CacheStore httpCache;
  final SharedPreferences preferences;
}

/// Holds a database that can be connected to.
class DatabaseCarrier {
  DatabaseCarrier(QueryExecutor this.executor) : connection = null;

  DatabaseCarrier.connect(DatabaseConnection this.connection) : executor = null;

  final QueryExecutor? executor;
  final DatabaseConnection? connection;

  bool get isolated => connection != null;
}
