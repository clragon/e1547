import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/topic/topic.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/material.dart';

final NavigationController navigationController =
    NavigationController(destinations: destinations);

NavigationDrawer defaultNavigationDrawer() =>
    NavigationDrawer(controller: navigationController);

double defaultDrawerEdge(double screenWidth) => screenWidth * 0.1;

class NavigationDestination<UniqueRoute extends Enum> {
  final String path;
  final WidgetBuilder builder;
  final UniqueRoute? route;
  final String? name;
  final Widget? icon;
  final String? group;

  const NavigationDestination({
    this.name,
    this.icon,
    this.group,
    required this.path,
    required this.builder,
    this.route,
  });
}

class NavigationController<UniqueRoute extends Enum> {
  final List<NavigationDestination<UniqueRoute>> destinations;
  late final Map<String, WidgetBuilder> routes;

  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

  late UniqueRoute drawerSelection;

  NavigationController({required this.destinations}) {
    drawerSelection =
        destinations.singleWhere((element) => element.path == '/').route!;
    routes = Map.fromEntries(
      destinations.map(
        (e) => MapEntry(
          e.path,
          e.route != null
              ? (context) {
                  drawerSelection = e.route!;
                  return e.builder(context);
                }
              : e.builder,
        ),
      ),
    );
  }
}

enum DrawerSelection {
  home,
  hot,
  favorites,
  follows,
  pools,
  topics,
}

enum DrawerGroup {
  search,
  collection,
  settings,
}

List<NavigationDestination<DrawerSelection>> destinations = [
  NavigationDestination(
    path: '/',
    name: 'Home',
    icon: Icon(Icons.home),
    builder: (context) => HomePage(),
    route: DrawerSelection.home,
    group: DrawerGroup.search.name,
  ),
  NavigationDestination(
    path: '/hot',
    name: 'Hot',
    icon: Icon(Icons.whatshot),
    builder: (context) => HotPage(),
    route: DrawerSelection.hot,
    group: DrawerGroup.search.name,
  ),
  NavigationDestination(
    path: '/search',
    name: 'Search',
    icon: Icon(Icons.search),
    builder: (context) => SearchPage(),
    group: DrawerGroup.search.name,
  ),
  NavigationDestination(
    path: '/fav',
    name: 'Favorites',
    icon: Icon(Icons.favorite),
    builder: (context) => FavPage(),
    route: DrawerSelection.favorites,
    group: DrawerGroup.collection.name,
  ),
  NavigationDestination(
    path: '/follows',
    name: 'Following',
    icon: Icon(Icons.turned_in),
    builder: (context) => FollowsPage(),
    route: DrawerSelection.follows,
    group: DrawerGroup.collection.name,
  ),
  NavigationDestination(
    path: '/pools',
    name: 'Pools',
    icon: Icon(Icons.collections),
    builder: (context) => PoolsPage(),
    route: DrawerSelection.pools,
    group: DrawerGroup.collection.name,
  ),
  NavigationDestination(
    path: '/topics',
    name: 'Forum',
    icon: Icon(Icons.forum),
    builder: (context) => TopicsPage(),
    route: DrawerSelection.topics,
    group: DrawerGroup.collection.name,
  ),
  NavigationDestination(
    path: '/settings',
    name: 'Settings',
    icon: Icon(Icons.settings),
    builder: (context) => SettingsPage(),
    group: DrawerGroup.settings.name,
  ),
  NavigationDestination(
    path: '/about',
    name: 'About',
    icon: DrawerUpdateIcon(),
    builder: (context) => AboutPage(),
    group: DrawerGroup.settings.name,
  ),
  NavigationDestination(
    path: '/login',
    builder: (context) => LoginPage(),
  ),
  NavigationDestination(
    path: '/blacklist',
    builder: (context) => DenyListPage(),
  ),
  NavigationDestination(
    path: '/following',
    builder: (context) => FollowingPage(),
  ),
  NavigationDestination(
    path: '/history',
    builder: (context) => HistoryPage(),
  ),
];

class NavigationDrawer<UniqueRoute extends Enum> extends StatelessWidget {
  final NavigationController<UniqueRoute> controller;

  const NavigationDrawer({required this.controller});

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    children.add(ProfileHeader());

    String? currentGroup = controller.destinations.first.group;

    for (var destination in controller.destinations) {
      if (destination.name == null) {
        break;
      }
      if (destination.group != currentGroup) {
        currentGroup = destination.group;
        children.add(const Divider());
      }
      children.add(ListTile(
        selected: destination.route != null &&
            destination.route == controller.drawerSelection,
        title: Text(destination.name!),
        leading: destination.icon != null ? destination.icon : null,
        onTap: destination.route != null
            ? () => Navigator.of(context)
                .pushNamedAndRemoveUntil(destination.path, (_) => false)
            : () => Navigator.of(context).popAndPushNamed(destination.path),
      ));
    }

    return Drawer(
      child: PrimaryScrollController(
        controller: ScrollController(),
        child: ListView(
          children: children,
        ),
      ),
    );
  }
}

class ProfileHeader extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProfileHeaderState();
  }
}

class _ProfileHeaderState extends State<ProfileHeader>
    with ListenerCallbackMixin {
  @override
  Map<ChangeNotifier, VoidCallback> get initListeners => {
        settings.credentials: () {
          if (mounted) {
            initAvatar(context);
          }
        },
      };

  @override
  Widget build(BuildContext context) {
    Widget userNameWidget(String? name) {
      return CrossFade(
        showChild: name != null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                name ?? '...',
                style: Theme.of(context).textTheme.headline6,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        secondChild: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: OutlinedButton(
            child: Text('LOGIN'),
            onPressed: () => Navigator.popAndPushNamed(context, '/login'),
          ),
        ),
      );
    }

    return ValueListenableBuilder<Credentials?>(
      valueListenable: settings.credentials,
      builder: (context, value, child) => DrawerHeader(
        child: GestureDetector(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 72,
                width: 72,
                child: CurrentUserAvatar(),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: userNameWidget(value?.username),
                ),
              ),
            ],
          ),
          onTap: value?.username != null
              ? () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => UserLoadingPage(value!.username),
                    ),
                  )
              : null,
        ),
      ),
    );
  }
}

class DrawerUpdateIcon extends StatefulWidget {
  @override
  _DrawerUpdateIconState createState() => _DrawerUpdateIconState();
}

class _DrawerUpdateIconState extends State<DrawerUpdateIcon> {
  Future<List<AppVersion>?> newVersions = getNewVersions();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AppVersion>?>(
      future: newVersions,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return Stack(
            children: [
              Icon(Icons.update),
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          );
        } else {
          return Icon(Icons.info);
        }
      },
    );
  }
}
