import 'dart:async';
import 'package:e1547/app/app.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
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
  Settings settings = await initializeSettings();
  EnvironmentPaths paths = await initializeEnvironmentPaths();
  await migrateFollows(settings);
  runApp(
    MultiProvider(
      providers: [
        if (windowManager != null) Provider.value(value: windowManager),
        Provider.value(value: talker),
        Provider.value(value: appInfo),
        Provider.value(value: settings),
        Provider.value(value: paths),
      ],
      child: const App(),
    ),
  );
}

Future<void> migrateFollows(Settings settings) async {
  // ignore:deprecated_member_use_from_same_package
  List<PrefsFollow>? follows = settings.follows.value;
  if (follows != null) {
    FollowsService service = FollowsService.connect(
      connectDatabase('follows.sqlite'),
    );
    await service.transaction(() async {
      String defaultHost = settings.host.value;
      if (defaultHost == settings.customHost.value) {
        defaultHost = 'e926.net';
      }
      await service.addAll(
        defaultHost,
        follows
            .map(
              (e) => FollowRequest(
                tags: e.tags,
                title: e.alias,
                type: e.type,
              ),
            )
            .toList(),
      );
      String? customHost = settings.customHost.value;
      if (customHost != null) {
        await service.addAll(
          customHost,
          follows
              .map(
                (e) => FollowRequest(
                  tags: e.tags,
                  title: e.alias,
                  type: e.type,
                ),
              )
              .toList(),
        );
      }
    });
    await service.close();
    // ignore:deprecated_member_use_from_same_package
    settings.follows.value = null;
  }
}
