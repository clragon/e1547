import 'package:e1547/app/app.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
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
  var home = (context) {
    Widget home = const HomePage();
    // print('settings.initPage ${settings.initPage.value}');
    if (settings.initPage != SettingsInitPage.home) {
      List<NavigationDrawerDestination> destinations = rootDestintations
          .whereType<NavigationDrawerDestination>()
          .toList()
          .cast<NavigationDrawerDestination>();

      var destination = destinations
          .where((d) => d.name.toLowerCase() == settings.initPage.value.name)
          .first;
      // print('jump init page');
      // print(destination);
      home = destination.builder(context);
    }

    return home;
  };

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
                home: home(context),
                builder: (context, child) => StartupActions(
                  actions: [
                    initializeUserAvatar,
                    (_) => denylistController.update(),
                    (_) => followController.update(),
                    (_) => initializeDateFormatting(),
                  ],
                  child: LockScreen(
                    child: AppLinkHandler(
                      child: VideoHandlerData(
                        handler: VideoHandler(
                          muteVideos: settings.muteVideos.value,
                        ),
                        child: child!,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
