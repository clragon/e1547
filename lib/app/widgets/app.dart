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
import 'package:relative_time/relative_time.dart';

class App extends StatelessWidget {
  const App();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        AdaptiveScaffoldScope(),
        ClientProvider(),
        NavigationProvider(
          destinations: rootDestintations,
          drawerHeader: (context) => UserDrawerHeader(),
        ),
        DenylistProvider(),
        FollowsProvider(),
        HistoriesServiceProvider(),
        CurrentUserAvatarProvider(),
      ],
      child: Consumer3<AppInfo, Settings, NavigationController>(
        builder: (context, appInfo, settings, navigation, child) =>
            ValueListenableBuilder<AppTheme>(
          valueListenable: settings.theme,
          builder: (context, value, child) => ExcludeSemantics(
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: appThemeMap[value]!.appBarTheme.systemOverlayStyle!,
              child: MaterialApp(
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
                builder: (context, child) => WindowFrame(
                  child: WindowShortcuts(
                    child: StartupActions(
                      actions: [
                        (_) => initializeDateFormatting(),
                        (_) => context.read<DenylistService>().update(),
                        (_) => context.read<FollowsService>().update(),
                        initializeUserAvatar,
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
        ),
      ),
    );
  }
}
