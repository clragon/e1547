import 'dart:async';
import 'package:dio_cache_interceptor_db_store/dio_cache_interceptor_db_store.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';
import 'package:notified_preferences/notified_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:talker/talker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Talker talker = Talker();
  registerFlutterErrorHandler(talker.handle);
  initializeSql();
  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: await initializeAppInfo()),
        Provider.value(value: await initializeWindowManager()),
        Provider.value(value: talker),
        Provider.value(
          value: AppDatabases(
            preferences: await SharedPreferences.getInstance(),
            followDb: DatabaseCarrier.connect(
              connectDatabase('follows.sqlite'),
            ),
            historyDb: DatabaseCarrier.connect(
              connectDatabase('history.sqlite'),
            ),
            httpCache: DbCacheStore(
              databasePath: (await getTemporaryDirectory()).path,
            ),
          ),
        ),
      ],
      child: const App(),
    ),
  );
}
