import 'dart:async';

import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  await initialize();
  runApp(App());
}

Future<void> initialize() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await initializeSettings();
  await initializeAppInfo();
  initializeHttpCache();
}

final List<StartupCallback> startupActions = [
  initializeUserAvatar,
  (_) => followController.update(),
  (_) => initializeDateFormatting(),
];

class App extends StatelessWidget {
  @override
  Widget build(context) => StartupActions(
        actions: startupActions,
        child: NavigationData(
          controller: topLevelNavigationController,
          child: ValueListenableBuilder<AppTheme>(
            valueListenable: settings.theme,
            builder: (context, value, child) => ExcludeSemantics(
              child: AnnotatedRegion<SystemUiOverlayStyle>(
                value: appThemeMap[value]!.appBarTheme.systemOverlayStyle!,
                child: MaterialApp(
                  title: appInfo.appName,
                  theme: appThemeMap[value],
                  routes: NavigationData.of(context).routes,
                  navigatorObservers: [
                    NavigationData.of(context).routeObserver,
                  ],
                  scrollBehavior: DesktopScrollBehaviour(),
                ),
              ),
            ),
          ),
        ),
      );
}
