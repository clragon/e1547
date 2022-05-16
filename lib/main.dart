import 'dart:async';

import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/topic/topic.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  await initialize();
  runApp(const App());
}

Future<void> initialize() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await initializeSettings();
  await initializeAppInfo();
  initializeHttpCache();
}

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
                navigatorObservers: [
                  NavigationData.of(context).routeObserver,
                ],
                navigatorKey: NavigationData.of(context).navigatorKey,
                scrollBehavior: DesktopScrollBehaviour(),
                builder: (context, child) => StartupActions(
                  actions: [
                    initializeUserAvatar,
                    (_) => denylistController.update(),
                    (_) => followController.update(),
                    (_) => initializeDateFormatting(),
                  ],
                  child: LinkHandler(
                    initialHandler: (url) {
                      if (url != null) {
                        VoidCallback? action = getLinkAction(
                          NavigationData.of(context)
                              .navigatorKey
                              .currentContext!,
                          url.toString(),
                        );
                        if (action != null) {
                          NavigationData.of(context)
                              .navigatorKey
                              .currentState!
                              .popUntil((route) => false);
                          action();
                        } else {
                          launch(url.toString());
                        }
                      }
                    },
                    handler: (url) {
                      if (url != null) {
                        VoidCallback? action = getLinkAction(
                          NavigationData.of(context)
                              .navigatorKey
                              .currentContext!,
                          url.toString(),
                        );
                        if (action != null) {
                          action();
                        } else {
                          launch(url.toString());
                        }
                      }
                    },
                    child: child!,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  late final NavigationController navigationController = NavigationController(
      destinations: rootDestintations, drawerHeader: UserDrawerHeader());

  static const String drawerSearchGroup = 'search';
  static const String drawerCollectionsGroup = 'collections';
  static const String drawerSettingsGroup = 'settings';

  final List<NavigationRouteDestination> rootDestintations = [
    NavigationDrawerDestination(
      path: '/',
      name: 'Home',
      icon: const Icon(Icons.home),
      builder: (context) => const HomePage(),
      unique: true,
      group: drawerSearchGroup,
    ),
    NavigationDrawerDestination(
      path: '/hot',
      name: 'Hot',
      icon: const Icon(Icons.whatshot),
      builder: (context) => const HotPage(),
      unique: true,
      group: drawerSearchGroup,
    ),
    NavigationDrawerDestination(
      path: '/search',
      name: 'Search',
      icon: const Icon(Icons.search),
      builder: (context) => const SearchPage(),
      group: drawerSearchGroup,
    ),
    NavigationDrawerDestination(
      path: '/fav',
      name: 'Favorites',
      icon: const Icon(Icons.favorite),
      builder: (context) => const FavPage(),
      unique: true,
      group: drawerCollectionsGroup,
    ),
    NavigationDrawerDestination(
      path: '/follows',
      name: 'Following',
      icon: const Icon(Icons.turned_in),
      builder: (context) => FollowsPage(),
      unique: true,
      group: drawerCollectionsGroup,
    ),
    NavigationDrawerDestination(
      path: '/pools',
      name: 'Pools',
      icon: const Icon(Icons.collections),
      builder: (context) => PoolsPage(),
      unique: true,
      group: drawerCollectionsGroup,
    ),
    NavigationDrawerDestination(
      path: '/topics',
      name: 'Forum',
      icon: const Icon(Icons.forum),
      builder: (context) => const TopicsPage(),
      visible: (context) => settings.showBeta.value,
      unique: true,
      group: drawerCollectionsGroup,
    ),
    NavigationDrawerDestination(
      path: '/history',
      name: 'History',
      icon: const Icon(Icons.history),
      builder: (context) => const HistoryPage(),
      visible: (context) => settings.writeHistory.value,
      group: drawerSettingsGroup,
    ),
    NavigationDrawerDestination(
      path: '/settings',
      name: 'Settings',
      icon: const Icon(Icons.settings),
      builder: (context) => SettingsPage(),
      group: drawerSettingsGroup,
    ),
    NavigationDrawerDestination(
      path: '/about',
      name: 'About',
      icon: DrawerUpdateIcon(),
      builder: (context) => AboutPage(),
      group: drawerSettingsGroup,
    ),
    NavigationRouteDestination(
      path: '/login',
      builder: (context) => const LoginPage(),
    ),
    NavigationRouteDestination(
      path: '/blacklist',
      builder: (context) => DenyListPage(),
    ),
    NavigationRouteDestination(
      path: '/following',
      builder: (context) => FollowingPage(),
    ),
  ];
}
