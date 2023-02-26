import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/logs/logs.dart';
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
        SettingsProvider(),
        ClientServiceProvider(),
        DenylistProvider(),
        FollowsProvider(),
        HistoriesServiceProvider(),
        AdaptiveScaffoldScope(),
        NavigationProvider(
          destinations: rootDestintations,
          drawerHeader: (context) => UserDrawerHeader(),
        ),
        CurrentUserAvatarProvider(),
      ],
      child: Consumer3<AppInfo, Settings, RouterDrawerController>(
        builder: (context, appInfo, settings, navigation, child) =>
            ValueListenableBuilder<AppTheme>(
          valueListenable: settings.theme,
          builder: (context, value, child) => ExcludeSemantics(
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: value.data.appBarTheme.systemOverlayStyle ??
                  const SystemUiOverlayStyle(),
              child: MaterialApp(
                title: appInfo.appName,
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
                builder: (context, child) => MediaQuery(
                  // Temporary hack to fix https://github.com/AbdulRahmanAlHamali/flutter_typeahead/issues/463
                  data: MediaQuery.of(context).copyWith(
                    accessibleNavigation: false,
                  ),
                  child: WindowFrame(
                    child: WindowShortcuts(
                      child: StartupActions(
                        actions: [
                          (_) => initializeDateFormatting(),
                          (_) => context.read<DenylistService>().pull(),
                          (_) => context.read<FollowsUpdater>().update(
                                client: context.read<Client>(),
                                denylist: context.read<DenylistService>().items,
                              ),
                          initializeCurrentUserAvatar,
                        ],
                        onError: (context, error) {
                          // errors in startup actions are ignored.
                        },
                        child: ErrorNotifier(
                          child: LockScreen(
                            child: ClientAvailabilityCheck(
                              child: AppLinkHandler(
                                child: NotificationHandler(
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
            ),
          ),
        ),
      ),
    );
  }
}
