import 'dart:async';
import 'package:e1547/app/app.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  await initializeDateFormatting();
  WidgetsFlutterBinding.ensureInitialized();
  VideoService.ensureInitialized();
  AppInfo appInfo = await initializeAppInfo();
  AppDatabases databases = await initializeAppdatabases(info: appInfo);
  Logs logs = await initializeLogger(databases: databases);
  WindowManager? windowManager = await initializeWindowManager();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  initializeBackgroundTasks();
  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: appInfo),
        Provider.value(value: databases),
        Provider.value(value: logs),
        Provider.value(value: windowManager),
      ],
      child: const App(),
    ),
  );
}
