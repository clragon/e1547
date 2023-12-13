import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/logs/logs.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/traits/traits.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:relative_time/relative_time.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        AppUpdateProvider(),
        ClientFactoryProvider(),
        SettingsProvider(),
        VideoServiceProvider(),
        AdaptiveScaffoldScope(
          isEndDrawerOpen: false,
        ),
        NavigationProvider(
          destinations: rootDestintations,
          drawerHeader: (context) => const UserDrawerHeader(),
        ),
      ],
      child: Consumer2<Settings, RouterDrawerController>(
        builder: (context, settings, navigation, child) =>
            ValueListenableBuilder<AppTheme>(
          valueListenable: settings.theme,
          builder: (context, value, child) => ExcludeSemantics(
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: value.data.appBarTheme.systemOverlayStyle ??
                  const SystemUiOverlayStyle(),
              child: MaterialApp(
                title: AppInfo.instance.appName,
                theme: value.data,
                routes: navigation.routes,
                navigatorObservers: [
                  navigation.routeObserver,
                  RouteLoggerObserver(),
                ],
                navigatorKey: navigation.navigatorKey,
                scrollBehavior: AndroidStretchScrollBehaviour(),
                localizationsDelegates: const [
                  GlobalWidgetsLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  RelativeTimeLocalizations.delegate,
                ],
                builder: (context, child) => WindowFrame(
                  child: WindowShortcuts(
                    child: AppLoadingScreen(
                      child: MultiProvider(
                        providers: [
                          const DatabaseMigrationProvider(),
                          IdentitiesServiceProvider(),
                          TraitsServiceProvider(),
                          ClientProvider(),
                          CacheManagerProvider(),
                          FollowsProvider(),
                          HistoriesServiceProvider(),
                          AccountAvatarProvider(),
                        ],
                        child: TraitsSync(
                          child: AppLoadingScreenEnd(
                            child: ErrorNotifier(
                              child: LockScreen(
                                child: ClientAvailabilityCheck(
                                  child: AppLinkHandler(
                                    child: NotificationHandler(
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
