import 'dart:async';
import 'package:e1547/app/app.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  await DateFormatting.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  VideoService.ensureInitialized();
  await initializeAppInfo();
  Logs logs = await initializeLogger(path: await getTemporaryAppDirectory());
  await prepareForegroundIsolate();
  AppStorage storage = await initializeAppStorage();
  WindowManager? windowManager = await initializeWindowManager();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: logs),
        Provider.value(value: storage),
        Provider.value(value: windowManager),
      ],
      child: const App(),
    ),
  );
}
