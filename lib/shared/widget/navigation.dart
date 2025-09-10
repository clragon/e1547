import 'package:collection/collection.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RouterDrawerDestination {
  const RouterDrawerDestination({
    required this.path,
    required this.builder,
    this.unique = false,
  });

  final String path;
  final WidgetBuilder builder;
  final bool unique;
}

typedef RouterDrawerSettingCallback = bool Function(BuildContext context);

class NamedRouterDrawerDestination<T extends Widget>
    extends RouterDrawerDestination {
  const NamedRouterDrawerDestination({
    required this.name,
    this.icon,
    this.group,
    this.visible,
    this.enabled,
    required super.path,
    required T Function(BuildContext context) builder,
    super.unique,
  }) : super(builder: builder);

  final String name;
  final RouterDrawerSettingCallback? visible;
  final RouterDrawerSettingCallback? enabled;
  final Widget? icon;
  final String? group;
}

class RouterDrawerController extends ChangeNotifier {
  RouterDrawerController({required this.destinations, this.drawerHeader}) {
    routes = {for (final e in destinations) e.path: e.builder};
  }

  final List<RouterDrawerDestination> destinations;
  late final Map<String, WidgetBuilder> routes;

  final WidgetBuilder? drawerHeader;

  String? _drawerSelection;

  String? get drawerSelection => _drawerSelection;

  void setDrawerSelection<T extends Widget>() {
    NamedRouterDrawerDestination? target = destinations
        .whereType<NamedRouterDrawerDestination<T>>()
        .firstWhereOrNull((e) => e.unique);
    if (target != null && _drawerSelection != target.path) {
      _drawerSelection = target.path;
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    }
  }
}

class NavigationProvider
    extends ChangeNotifierProvider<RouterDrawerController> {
  NavigationProvider({
    super.key,
    required List<RouterDrawerDestination> destinations,
    WidgetBuilder? drawerHeader,
    super.child,
    super.builder,
  }) : super(
         create: (context) => RouterDrawerController(
           destinations: destinations,
           drawerHeader: drawerHeader,
         ),
       );
}

class RouterDrawer extends StatelessWidget {
  const RouterDrawer({super.key});

  List<NamedRouterDrawerDestination> getDrawerDestinations(
    List<RouterDrawerDestination> destinations,
  ) {
    return destinations
        .whereType<NamedRouterDrawerDestination>()
        .toList()
        .cast<NamedRouterDrawerDestination>();
  }

  @override
  Widget build(BuildContext context) {
    // Try to use customizable drawer if settings are available
    try {
      final Settings? settings = context.read<Settings?>();
      if (settings != null) {
        return const CustomizableRouterDrawer();
      }
    } catch (e) {
      // Fall back to original drawer if settings not available
    }
    
    // Original drawer implementation as fallback
    final RouterDrawerController controller = context.watch<RouterDrawerController>();

    List<Widget> children = [];
    if (controller.drawerHeader != null) {
      children.add(controller.drawerHeader!(context));
    }

    List<NamedRouterDrawerDestination> destinations = getDrawerDestinations(
      controller.destinations,
    );

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
          enabled: destination.enabled?.call(context) ?? true,
          selected:
              destination.unique &&
              destination.path == controller.drawerSelection,
          title: Text(destination.name),
          leading: destination.icon,
          onTap: destination.unique
              ? () => Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(destination.path, (_) => false)
              : () {
                  Scaffold.maybeOf(context)?.closeDrawer();
                  Navigator.of(context).pushNamed(destination.path);
                },
        ),
      );
    }

    return Drawer(
      child: PrimaryScrollController(
        controller: ScrollController(),
        child: ListView(children: children),
      ),
    );
  }
}

/// Custom drawer implementation (moved from settings)
class CustomizableRouterDrawer extends StatelessWidget {
  const CustomizableRouterDrawer({super.key});

  Widget _getIconFromString(String iconName) {
    switch (iconName) {
      case 'home':
        return const Icon(Icons.home);
      case 'whatshot':
        return const Icon(Icons.whatshot);
      case 'trending_up':
        return const Icon(Icons.trending_up);
      case 'search':
        return const Icon(Icons.search);
      case 'favorite':
        return const Icon(Icons.favorite);
      case 'feed':
        return const Icon(Icons.feed);
      case 'person_add':
        return const Icon(Icons.person_add);
      case 'bookmark':
        return const Icon(Icons.bookmark);
      case 'collections':
        return const Icon(Icons.collections);
      case 'forum':
        return const Icon(Icons.forum);
      case 'history':
        return const Icon(Icons.history);
      case 'settings':
        return const Icon(Icons.settings);
      case 'info':
        return const Icon(Icons.info);
      default:
        return const Icon(Icons.apps);
    }
  }

  @override
  Widget build(BuildContext context) {
    final RouterDrawerController controller = context.watch<RouterDrawerController>();
    final Settings settings = context.watch<Settings>();
    final DrawerConfiguration config = settings.drawerConfig;

    List<Widget> children = [];
    
    // Add drawer header if available
    if (controller.drawerHeader != null) {
      children.add(controller.drawerHeader!(context));
    }

    // Get enabled items sorted by order and group
    final enabledItems = config.items.where((item) => item.enabled).toList();
    enabledItems.sort((a, b) => a.order.compareTo(b.order));

    String? currentGroup;
    
    for (final item in enabledItems) {
      // Add divider between groups
      if (currentGroup != null && item.group != currentGroup) {
        children.add(const Divider());
      }
      currentGroup = item.group;

      // Find the corresponding destination
      final destination = controller.destinations
          .whereType<NamedRouterDrawerDestination>()
          .cast<NamedRouterDrawerDestination>()
          .where((dest) => dest.path == item.path)
          .firstOrNull;

      if (destination != null) {
        // Check visibility and enabled conditions
        if (!(destination.visible?.call(context) ?? true)) {
          continue;
        }
        
        children.add(
          ListTile(
            enabled: destination.enabled?.call(context) ?? true,
            selected: destination.unique &&
                destination.path == controller.drawerSelection,
            title: Text(item.name),
            leading: _getIconFromString(item.icon),
            onTap: destination.unique
                ? () => Navigator.of(context).pushNamedAndRemoveUntil(
                    destination.path, (_) => false)
                : () {
                    Scaffold.maybeOf(context)?.closeDrawer();
                    Navigator.of(context).pushNamed(destination.path);
                  },
          ),
        );
      }
    }

    return Drawer(
      child: PrimaryScrollController(
        controller: ScrollController(),
        child: ListView(children: children),
      ),
    );
  }
}

mixin RouterDrawerEntryWidget<T extends StatefulWidget> on State<T> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context)!.isFirst) {
      context.watch<RouterDrawerController?>()?.setDrawerSelection<T>();
    }
  }
}

class RouterDrawerEntry<T extends Widget> extends StatefulWidget {
  const RouterDrawerEntry({super.key, required this.child});

  final Widget child;

  @override
  State<RouterDrawerEntry<T>> createState() => _RouterDrawerEntryState<T>();
}

class _RouterDrawerEntryState<T extends Widget>
    extends State<RouterDrawerEntry<T>> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context)!.isFirst) {
      context.watch<RouterDrawerController?>()?.setDrawerSelection<T>();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class AnyRouteObserver extends RouteObserver<Route<Object?>> {}

class DefaultRouteObserver extends Provider<AnyRouteObserver> {
  DefaultRouteObserver({super.key, super.child})
    : super(create: (context) => AnyRouteObserver());
}

mixin DefaultRouteAware<T extends StatefulWidget> on State<T>
    implements RouteAware {
  AnyRouteObserver? _routeObserver;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routeObserver?.unsubscribe(this);
    _routeObserver = context.watch<AnyRouteObserver>();
    _routeObserver!.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void reassemble() {
    super.reassemble();
    _routeObserver?.unsubscribe(this);
    _routeObserver = context.read<AnyRouteObserver>();
    _routeObserver!.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    _routeObserver?.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {}

  @override
  void didPush() {}

  @override
  void didPop() {}

  @override
  void didPushNext() {}
}
