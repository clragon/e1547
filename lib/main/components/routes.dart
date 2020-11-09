import 'package:e1547/about/about_page.dart';
import 'package:e1547/denylist/denylist_page.dart';
import 'package:e1547/follows/follow_page.dart';
import 'package:e1547/login/login_page.dart';
import 'package:e1547/main/drawer.dart';
import 'package:e1547/pools/pools_page.dart';
import 'package:e1547/posts/posts_page.dart';
import 'package:e1547/settings/settings_page.dart';
import 'package:e1547/threads/threads_page.dart';
import 'package:flutter/material.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

Map<String, Widget Function(BuildContext)> routes() {
  return <String, WidgetBuilder>{
    '/': (context) => () {
          drawerSelection = DrawerSelection.home;
          return HomePage();
        }(),
    '/hot': (context) => () {
          drawerSelection = DrawerSelection.hot;
          return HotPage();
        }(),
    '/search': (context) => SearchPage(),
    '/fav': (context) => () {
          drawerSelection = DrawerSelection.favorites;
          return FavPage();
        }(),
    '/follows': (context) => () {
          drawerSelection = DrawerSelection.follows;
          return FollowsPage();
        }(),
    '/pools': (context) => () {
          drawerSelection = DrawerSelection.pools;
          return PoolsPage();
        }(),
    '/forum': (context) => () {
          drawerSelection = DrawerSelection.forum;
          return ThreadsPage();
        }(),
    '/login': (context) => LoginPage(),
    '/settings': (context) => SettingsPage(),
    '/about': (context) => AboutPage(),
    '/blacklist': (context) => DenyListPage(),
    '/following': (context) => FollowingPage(),
  };
}
