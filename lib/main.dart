import 'dart:async';
import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/logs/logs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppInfo appInfo = await initializeAppInfo();
  AppDatabases databases = await initializeAppdatabases(info: appInfo);
  Logs logs = await initializeLogger(databases: databases);
  CookiesService cookies = await initializeCookiesService(appInfo.allowedHosts);
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
        Provider.value(value: cookies),
      ],
      child: const App(),
    ),
  );
}
