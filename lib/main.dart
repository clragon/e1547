import 'dart:async';
import 'package:dio_cache_interceptor_db_store/dio_cache_interceptor_db_store.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:notified_preferences/notified_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:talker/talker.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  Talker talker = Talker();
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
    talker.handle(error, stack);
    return false;
  };
  FlutterError.onError =
      (details) => talker.handle(details.exception, details.stack);
  await initializeSql();
  WindowManager? windowManager = await initializeWindowManager();
  AppInfo appInfo = await initializeAppInfo();
  AppDatabases databases = AppDatabases(
    preferences: await SharedPreferences.getInstance(),
    followDb: DatabaseCarrier.connect(connectDatabase('follows.sqlite')),
    historyDb: DatabaseCarrier.connect(connectDatabase('history.sqlite')),
    httpCache: DbCacheStore(databasePath: (await getTemporaryDirectory()).path),
  );
  runApp(
    MultiProvider(
      providers: [
        if (windowManager != null) Provider.value(value: windowManager),
        Provider.value(value: talker),
        Provider.value(value: appInfo),
        Provider.value(value: databases),
      ],
      child: const App(),
    ),
  );
}
