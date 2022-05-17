import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/topic/topic.dart';

import 'package:e1547/interface/interface.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/material.dart';

final NavigationController navigationController = NavigationController(
    destinations: rootDestintations, drawerHeader: UserDrawerHeader());

const String _drawerSearchGroup = 'search';
const String _drawerCollectionsGroup = 'collections';
const String _drawerSettingsGroup = 'settings';

final List<NavigationRouteDestination> rootDestintations = [
  NavigationDrawerDestination(
    path: '/',
    name: 'Home',
    icon: const Icon(Icons.home),
    builder: (context) => const HomePage(),
    unique: true,
    group: _drawerSearchGroup,
  ),
  NavigationDrawerDestination(
    path: '/hot',
    name: 'Hot',
    icon: const Icon(Icons.whatshot),
    builder: (context) => const HotPage(),
    unique: true,
    group: _drawerSearchGroup,
  ),
  NavigationDrawerDestination(
    path: '/search',
    name: 'Search',
    icon: const Icon(Icons.search),
    builder: (context) => const SearchPage(),
    group: _drawerSearchGroup,
  ),
  NavigationDrawerDestination(
    path: '/favorites',
    name: 'Favorites',
    icon: const Icon(Icons.favorite),
    builder: (context) => const FavPage(),
    unique: true,
    group: _drawerCollectionsGroup,
  ),
  NavigationDrawerDestination(
    path: '/follows',
    name: 'Follows',
    icon: const Icon(Icons.turned_in),
    builder: (context) => FollowsPage(),
    unique: true,
    group: _drawerCollectionsGroup,
  ),
  NavigationDrawerDestination(
    path: '/pools',
    name: 'Pools',
    icon: const Icon(Icons.collections),
    builder: (context) => const PoolsPage(),
    unique: true,
    group: _drawerCollectionsGroup,
  ),
  NavigationDrawerDestination(
    path: '/forum',
    name: 'Forum',
    icon: const Icon(Icons.forum),
    builder: (context) => const TopicsPage(),
    visible: (context) => settings.showBeta.value,
    unique: true,
    group: _drawerCollectionsGroup,
  ),
  NavigationDrawerDestination(
    path: '/history',
    name: 'History',
    icon: const Icon(Icons.history),
    builder: (context) => const HistoryPage(),
    visible: (context) => settings.writeHistory.value,
    group: _drawerSettingsGroup,
  ),
  NavigationDrawerDestination(
    path: '/settings',
    name: 'Settings',
    icon: const Icon(Icons.settings),
    builder: (context) => SettingsPage(),
    group: _drawerSettingsGroup,
  ),
  NavigationDrawerDestination(
    path: '/about',
    name: 'About',
    icon: DrawerUpdateIcon(),
    builder: (context) => AboutPage(),
    group: _drawerSettingsGroup,
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
