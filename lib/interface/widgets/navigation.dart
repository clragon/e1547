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
    required super.path,
    required super.builder,
    super.unique,
  });
}

class NavigationController {
  final List<NavigationRouteDestination> destinations;
  late final Map<String, WidgetBuilder> routes;

  final Widget? drawerHeader;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

  late String drawerSelection;

  NavigationController({required this.destinations, this.drawerHeader}) {
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

  const NavigationData({required super.child, required this.controller});

  static NavigationController of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<NavigationData>()!
        .controller;
  }

  @override
  bool updateShouldNotify(covariant NavigationData oldWidget) =>
      oldWidget.controller != controller;
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
    if (controller.drawerHeader != null) {
      children.add(controller.drawerHeader!);
    }

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
          children: children,
        ),
      ),
    );
  }
}
