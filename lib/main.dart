import 'dart:async';
import 'package:e1547/app/app.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talker/talker.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  Talker talker = Talker();
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      FlutterError.onError =
          (details) => talker.handle(details.exception, details.stack);
      await initializeSql();
      AppInfo appInfo = await initializeAppInfo();
      Settings settings = await initializeSettings();
      WindowManager? windowManager = await initializeWindowManager();
      runApp(
        MultiProvider(
          providers: [
            if (windowManager != null) Provider.value(value: windowManager),
            Provider.value(value: appInfo),
            Provider.value(value: settings),
            Provider.value(value: talker),
          ],
          child: const App(),
        ),
      );
    },
    (error, stack) => talker.handle(error, stack),
  );
}
