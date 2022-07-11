import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
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
import 'package:provider/provider.dart';
import 'package:relative_time/relative_time.dart';

class App extends StatelessWidget {
  const App();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: appInfo),
        Provider.value(value: settings),
        ChangeNotifierProvider.value(value: client),
        HistoriesProvider(),
        Provider.value(value: navigationController),
      ],
      child: ValueListenableBuilder<AppTheme>(
        valueListenable: settings.theme,
        builder: (context, value, child) => ExcludeSemantics(
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: appThemeMap[value]!.appBarTheme.systemOverlayStyle!,
            child: Consumer<NavigationController>(
              builder: (context, navigation, child) => MaterialApp(
                title: appInfo.appName,
                theme: appThemeMap[value],
                routes: navigation.routes,
                navigatorObservers: [navigation.routeObserver],
                navigatorKey: navigation.navigatorKey,
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
