import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

class NavigationDrawerDestination<T extends Widget>
    extends NavigationRouteDestination {
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
    required T Function(BuildContext context) builder,
    super.unique,
  }) : super(builder: builder);
}

class NavigationController extends ChangeNotifier {
  final List<NavigationRouteDestination> destinations;
  late final Map<String, WidgetBuilder> routes;

  final Widget? drawerHeader;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

  String? _drawerSelection;
  String? get drawerSelection => _drawerSelection;

  void setDrawerSelection<T extends Widget>() {
    NavigationDrawerDestination? target = destinations
        .whereType<NavigationDrawerDestination<T>>()
        .firstWhereOrNull((e) => e.unique);
    if (target != null && _drawerSelection != target.path) {
      _drawerSelection = target.path;
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    }
  }

  NavigationController({required this.destinations, this.drawerHeader}) {
    routes = {for (final e in destinations) e.path: e.builder};
  }
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
    final NavigationController controller =
        context.watch<NavigationController>();

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

mixin DrawerEntry<T extends StatefulWidget> on State<T> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context)!.isFirst) {
      context.watch<NavigationController?>()?.setDrawerSelection<T>();
    }
  }
}
