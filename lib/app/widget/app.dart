import 'package:e1547/account/account.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/logs/logs.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_sub/flutter_sub.dart';
import 'package:relative_time/relative_time.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        const WindowProvider(),
        AppInfoClientProvider(),
        ClientFactoryProvider(),
        SettingsProvider(),
        VideoServiceProvider(),
        AdaptiveScaffoldScope(),
        DefaultRouteObserver(),
        NavigationProvider(
          destinations: rootDestintations,
          drawerHeader: (context) => const UserDrawerHeader(),
        ),
      ],
      builder: (context, child) => ValueListenableBuilder<AppTheme>(
        valueListenable: context.watch<Settings>().theme,
        builder: (context, value, child) => ExcludeSemantics(
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: value.data.appBarTheme.systemOverlayStyle ??
                const SystemUiOverlayStyle(),
            child: SubValue<GlobalKey<NavigatorState>>(
              create: () => GlobalKey<NavigatorState>(),
              builder: (context, navigatorKey) => MaterialApp(
                title: AppInfo.instance.appName,
                theme: value.data,
                scrollBehavior: AndroidStretchScrollBehaviour(),
                localizationsDelegates: const [
                  GlobalWidgetsLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  RelativeTimeLocalizations.delegate,
                ],
                navigatorKey: navigatorKey,
                navigatorObservers: [
                  context.watch<AnyRouteObserver>(),
                  RouteLoggerObserver(),
                  MaterialApp.createMaterialHeroController(),
                ],
                routes: context.watch<RouterDrawerController>().routes,
                builder: (context, child) => WindowFrame(
                  child: WindowShortcuts(
                    navigatorKey: navigatorKey,
                    child: SecureDisplay(
                      child: LockScreen(
                        child: LoadingShell(
                          child: MultiProvider(
                            providers: [
                              IdentityServiceProvider(),
                              TraitsServiceProvider(),
                              ClientProvider(),
                              CacheManagerProvider(),
                            ],
                            child: LoadingCore(
                              child: ErrorNotifier(
                                navigatorKey: navigatorKey,
                                child: AccountConnector(
                                  navigatorKey: navigatorKey,
                                  child: AppLinkHandler(
                                    navigatorKey: navigatorKey,
                                    child: NotificationHandler(
                                      navigatorKey: navigatorKey,
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
