import 'package:e1547/app/app.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:relative_time/relative_time.dart';

class App extends StatefulWidget {
  const App();

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final HistoriesService historesService = HistoriesService();

  @override
  Widget build(BuildContext context) {
    return NavigationData(
      controller: navigationController,
      child: HistoriesData(
        service: historesService,
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
                localizationsDelegates: const [
                  GlobalWidgetsLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  RelativeTimeLocalizations.delegate,
                ],
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
      ),
    );
  }
}
