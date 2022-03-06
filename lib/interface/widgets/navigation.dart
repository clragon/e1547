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

final NavigationController topLevelNavigationController =
    NavigationController(destinations: topLevelDestinations);

double defaultDrawerEdge(double screenWidth) => screenWidth * 0.1;

class NavigationDestination {
  final String path;
  final WidgetBuilder builder;
  final bool unique;

  const NavigationDestination({
    required this.path,
    required this.builder,
    this.unique = false,
  });
}

class NavigationDrawerDestination extends NavigationDestination {
  final String name;
  final bool Function(BuildContext context)? visible;
  final Widget? icon;
  final String? group;

  const NavigationDrawerDestination({
    required this.name,
    this.icon,
    this.group,
    this.visible,
    required String path,
    required WidgetBuilder builder,
    bool unique = false,
  }) : super(
          path: path,
          builder: builder,
          unique: unique,
        );
}

class NavigationController {
  final List<NavigationDestination> destinations;
  late final Map<String, WidgetBuilder> routes;

  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

  late String drawerSelection;

  NavigationController({required this.destinations}) {
    drawerSelection =
        destinations.singleWhere((element) => element.path == '/').path;
    routes = _generateRoutes(destinations);
  }

  WidgetBuilder _getDestinationBuilder(NavigationDestination destintation) {
    if (destintation.unique) {
      return (context) {
        drawerSelection = destintation.path;
        return destintation.builder(context);
      };
    } else {
      return destintation.builder;
    }
  }

  Map<String, WidgetBuilder> _generateRoutes(
      List<NavigationDestination> destinations) {
    return Map.fromEntries(
      destinations.map(
        (element) => MapEntry(
          element.path,
          _getDestinationBuilder(element),
        ),
      ),
    );
  }
}

class NavigationData extends InheritedWidget {
  final NavigationController controller;

  NavigationData({required Widget child, required this.controller})
      : super(child: child);

  static NavigationController of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<NavigationData>()!
        .controller;
  }

  @override
  bool updateShouldNotify(covariant NavigationData oldWidget) =>
      oldWidget.controller != controller;
}

enum DrawerGroup {
  search,
  collection,
  settings,
}

final List<NavigationDestination> topLevelDestinations = [
  NavigationDrawerDestination(
    path: '/',
    name: 'Home',
    icon: Icon(Icons.home),
    builder: (context) => HomePage(),
    unique: true,
    group: DrawerGroup.search.name,
  ),
  NavigationDrawerDestination(
    path: '/hot',
    name: 'Hot',
    icon: Icon(Icons.whatshot),
    builder: (context) => HotPage(),
    unique: true,
    group: DrawerGroup.search.name,
  ),
  NavigationDrawerDestination(
    path: '/search',
    name: 'Search',
    icon: Icon(Icons.search),
    builder: (context) => SearchPage(),
    group: DrawerGroup.search.name,
  ),
  NavigationDrawerDestination(
    path: '/fav',
    name: 'Favorites',
    icon: Icon(Icons.favorite),
    builder: (context) => FavPage(),
    unique: true,
    group: DrawerGroup.collection.name,
  ),
  NavigationDrawerDestination(
    path: '/follows',
    name: 'Following',
    icon: Icon(Icons.turned_in),
    builder: (context) => FollowsPage(),
    unique: true,
    group: DrawerGroup.collection.name,
  ),
  NavigationDrawerDestination(
    path: '/pools',
    name: 'Pools',
    icon: Icon(Icons.collections),
    builder: (context) => PoolsPage(),
    unique: true,
    group: DrawerGroup.collection.name,
  ),
  NavigationDrawerDestination(
    path: '/topics',
    name: 'Forum',
    icon: Icon(Icons.forum),
    builder: (context) => TopicsPage(),
    visible: (context) => settings.showBeta.value,
    unique: true,
    group: DrawerGroup.collection.name,
  ),
  NavigationDrawerDestination(
    path: '/settings',
    name: 'Settings',
    icon: Icon(Icons.settings),
    builder: (context) => SettingsPage(),
    group: DrawerGroup.settings.name,
  ),
  NavigationDrawerDestination(
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

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer();

  List<NavigationDrawerDestination> getDrawerDestinations(
      List<NavigationDestination> destinations) {
    return destinations
        .where((e) => e is NavigationDrawerDestination)
        .toList()
        .cast<NavigationDrawerDestination>();
  }

  @override
  Widget build(BuildContext context) {
    final NavigationController controller = NavigationData.of(context);

    List<Widget> children = [];
    children.add(ProfileHeader());

    List<NavigationDrawerDestination> destinations =
        getDrawerDestinations(controller.destinations);

    String? currentGroup = destinations.first.group;

    for (final destination in destinations) {
      if (!(destination.visible?.call(context) ?? true)) {
        continue;
      }
      if (destination.group != currentGroup) {
        currentGroup = destination.group;
        children.add(const Divider());
      }
      children.add(
        ListTile(
          selected: destination.unique &&
              destination.path == controller.drawerSelection,
          title: Text(destination.name),
          leading: destination.icon != null ? destination.icon : null,
          onTap: destination.unique
              ? () => Navigator.of(context)
                  .pushNamedAndRemoveUntil(destination.path, (_) => false)
              : () => Navigator.of(context).popAndPushNamed(destination.path),
        ),
      );
    }

    return Drawer(
      child: PrimaryScrollController(
        controller: ScrollController(),
        child: ListView(
          physics: BouncingScrollPhysics(),
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
        client: () {
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

    return AnimatedBuilder(
      animation: client,
      builder: (context, child) => DrawerHeader(
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
                  child: userNameWidget(client.credentials?.username),
                ),
              ),
            ],
          ),
          onTap: client.credentials != null
              ? () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          UserLoadingPage(client.credentials!.username),
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
