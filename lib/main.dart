import 'dart:async';
import 'package:e1547/app/app.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';
import 'package:talker/talker.dart';

Future<void> main() async {
  Talker logger = Talker();
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      FlutterError.onError =
          (details) => logger.handle(details.exception, details.stack);

      await initializeApp();
      runApp(
        Logger(
          talker: logger,
          child: const App(),
        ),
      );
    },
    (error, stack) => logger.handle(error, stack),
  );
}
