import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/material.dart';

double defaultDrawerEdge(double screenWidth) => screenWidth * 0.1;

class NavigationRouteDestination {
  final String path;
  final WidgetBuilder builder;
  final bool unique;

  const NavigationRouteDestination({
    required this.path,
    required this.builder,
    this.unique = false,
  });
}

class NavigationDrawerDestination extends NavigationRouteDestination {
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
  final List<NavigationRouteDestination> destinations;
  late final Map<String, WidgetBuilder> routes;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

  late String drawerSelection;

  NavigationController({required this.destinations}) {
    drawerSelection =
        destinations.singleWhere((element) => element.path == '/').path;
    routes = _generateRoutes(destinations);
  }

  WidgetBuilder _getDestinationBuilder(
      NavigationRouteDestination destintation) {
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
      List<NavigationRouteDestination> destinations) {
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

  const NavigationData({required Widget child, required this.controller})
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

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer();

  List<NavigationDrawerDestination> getDrawerDestinations(
      List<NavigationRouteDestination> destinations) {
    return destinations
        .whereType<NavigationDrawerDestination>()
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
          leading: destination.icon,
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
          physics: const BouncingScrollPhysics(),
          children: children,
        ),
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: client,
      builder: (context, child) => DrawerHeader(
        child: GestureDetector(
          child: Row(
            children: [
              const SizedBox(
                height: 72,
                width: 72,
                child: CurrentUserAvatar(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CrossFade.builder(
                    showChild: client.credentials?.username != null,
                    builder: (context) => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            client.credentials!.username,
                            style: Theme.of(context).textTheme.headline6,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    secondChild: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: OutlinedButton(
                        child: const Text('LOGIN'),
                        onPressed: () =>
                            Navigator.popAndPushNamed(context, '/login'),
                      ),
                    ),
                  ),
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
              const Icon(Icons.update),
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  height: 10,
                  width: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          );
        } else {
          return const Icon(Icons.info);
        }
      },
    );
  }
}
