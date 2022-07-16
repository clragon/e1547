import 'dart:async';
import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talker/talker.dart';

Future<void> main() async {
  Talker talker = Talker();
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      FlutterError.onError =
          (details) => talker.handle(details.exception, details.stack);
      await initializeSql();
      runApp(
        MultiProvider(
          providers: [
            Provider.value(value: await initializeAppInfo()),
            Provider.value(value: await initializeSettings()),
            Provider.value(value: talker),
          ],
          child: const App(),
        ),
      );
    },
    (error, stack) => talker.handle(error, stack),
  );
}
