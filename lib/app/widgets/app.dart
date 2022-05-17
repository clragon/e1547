import 'package:e1547/app/app.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/user/user.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:intl/date_symbol_data_local.dart';

class App extends StatefulWidget {
  const App();

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(context) => NavigationData(
        controller: navigationController,
        child: ValueListenableBuilder<AppTheme>(
          valueListenable: settings.theme,
          builder: (context, value, child) => ExcludeSemantics(
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: appThemeMap[value]!.appBarTheme.systemOverlayStyle!,
              child: MaterialApp(
                title: appInfo.appName,
                theme: appThemeMap[value],
                routes: NavigationData.of(context).routes,
                navigatorObservers: [NavigationData.of(context).routeObserver],
                navigatorKey: NavigationData.of(context).navigatorKey,
                scrollBehavior: DesktopScrollBehaviour(),
                builder: (context, child) => StartupActions(
                  actions: [
                    initializeUserAvatar,
                    (_) => denylistController.update(),
                    (_) => followController.update(),
                    (_) => initializeDateFormatting(),
                  ],
                  child: AppLinkHandler(child: child!),
                ),
              ),
            ),
          ),
        ),
      );
}
