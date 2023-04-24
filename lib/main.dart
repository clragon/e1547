import 'dart:async';
import 'package:e1547/app/app.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Logs logs = await initializeLogger();
  AppInfo appInfo = await initializeAppInfo();
  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: appInfo),
        Provider.value(value: logs),
        Provider.value(value: await initializeWindowManager()),
        Provider.value(value: await initializeAppdatabases()),
        Provider.value(
          value: await initializeCookiesService(appInfo.allowedHosts),
        ),
      ],
      child: const App(),
    ),
  );
}
