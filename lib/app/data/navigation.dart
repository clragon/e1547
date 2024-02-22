import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/topic/topic.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/material.dart';

const String _drawerSearchGroup = 'search';
const String _drawerFollowsGroup = 'follows';
const String _drawerCollectionsGroup = 'collections';
const String _drawerSettingsGroup = 'settings';

final List<RouterDrawerDestination> rootDestintations = [
  NamedRouterDrawerDestination(
    path: '/',
    name: 'Home',
    icon: const Icon(Icons.home),
    builder: (context) => const HomePage(),
    unique: true,
    group: _drawerSearchGroup,
  ),
  NamedRouterDrawerDestination(
    path: '/hot',
    name: 'Hot',
    icon: const Icon(Icons.whatshot),
    builder: (context) => const HotPage(),
    unique: true,
    group: _drawerSearchGroup,
  ),
  NamedRouterDrawerDestination(
    path: '/search',
    name: 'Search',
    icon: const Icon(Icons.search),
    builder: (context) => const PostsSearchPage(),
    group: _drawerSearchGroup,
  ),
  NamedRouterDrawerDestination(
    path: '/favorites',
    name: 'Favorites',
    icon: const Icon(Icons.favorite),
    builder: (context) => const FavPage(),
    unique: true,
    group: _drawerFollowsGroup,
    visible: (context) =>
        context.watch<Client>().hasFeature(PostFeature.favorite),
  ),
  NamedRouterDrawerDestination(
    path: '/timeline',
    name: 'Timeline',
    icon: const Icon(Icons.feed),
    builder: (context) => const FollowsTimelinePage(),
    unique: true,
    group: _drawerFollowsGroup,
  ),
  NamedRouterDrawerDestination(
    path: '/subscriptions',
    name: 'Subscriptions',
    icon: const Icon(Icons.person_add),
    builder: (context) => const FollowsSubscriptionsPage(),
    unique: true,
    group: _drawerFollowsGroup,
  ),
  NamedRouterDrawerDestination(
    path: '/bookmarks',
    name: 'Bookmarks',
    icon: const Icon(Icons.bookmark),
    builder: (context) => const FollowsBookmarkPage(),
    unique: true,
    group: _drawerFollowsGroup,
  ),
  NamedRouterDrawerDestination(
    path: '/pools',
    name: 'Pools',
    icon: const Icon(Icons.collections),
    builder: (context) => const PoolsPage(),
    unique: true,
    group: _drawerCollectionsGroup,
    visible: (context) =>
        context.watch<Client>().hasFeature(ClientFeature.pools),
  ),
  NamedRouterDrawerDestination(
    path: '/forum',
    name: 'Forum',
    icon: const Icon(Icons.forum),
    builder: (context) => const TopicsPage(),
    unique: true,
    group: _drawerCollectionsGroup,
    visible: (context) =>
        context.watch<Settings>().showBeta.value &&
        context.watch<Client>().hasFeature(ClientFeature.topics),
  ),
  NamedRouterDrawerDestination(
    path: '/history',
    name: 'History',
    icon: const Icon(Icons.history),
    builder: (context) => const HistoriesPage(),
    group: _drawerSettingsGroup,
  ),
  RouterDrawerDestination(
    path: '/blacklist',
    builder: (context) => const DenyListPage(),
  ),
  NamedRouterDrawerDestination(
    path: '/settings',
    name: 'Settings',
    icon: const Icon(Icons.settings),
    builder: (context) => const SettingsPage(),
    enabled: _nonRecursive<SettingsPage>,
    group: _drawerSettingsGroup,
  ),
  NamedRouterDrawerDestination(
    path: '/about',
    name: 'About',
    icon: const DrawerUpdateIcon(),
    builder: (context) => const AboutPage(),
    group: _drawerSettingsGroup,
  ),
];

bool _nonRecursive<T extends Widget>(BuildContext context) =>
    context.findAncestorWidgetOfExactType<T>() == null;
