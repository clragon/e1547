import 'dart:async';
import 'package:e1547/app/app.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';
import 'package:talker/talker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Talker talker = Talker();
  registerFlutterErrorHandler(talker.handle);
  AppInfo appInfo = await initializeAppInfo();
  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: appInfo),
        Provider.value(value: await initializeWindowManager()),
        Provider.value(value: talker),
        Provider.value(value: await initializeAppdatabases()),
        Provider.value(value: await initializeCookiesService(appInfo)),
      ],
      child: const App(),
    ),
  );
}
