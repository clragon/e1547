import 'dart:async';
import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/logs/logs.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppInfo appInfo = await initializeAppInfo();
  AppDatabases databases = await initializeAppdatabases(info: appInfo);
  Logs logs = await initializeLogger(databases: databases);
  WindowManager? windowManager = await initializeWindowManager();
  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: appInfo),
        Provider.value(value: databases),
        Provider.value(value: logs),
        Provider.value(value: windowManager),
        Provider.value(
          value: await initializeCookiesService(appInfo.allowedHosts),
        ),
      ],
      child: const App(),
    ),
  );
}
