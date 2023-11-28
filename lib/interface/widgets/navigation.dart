import 'package:collection/collection.dart';
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

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final RouteObserver<Route<Object?>> routeObserver =
      RouteObserver<Route<Object?>>();

  NavigatorState? get navigator => navigatorKey.currentState;

  BuildContext? get context => navigatorKey.currentContext;

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
      List<RouterDrawerDestination> destinations) {
    return destinations
        .whereType<NamedRouterDrawerDestination>()
        .toList()
        .cast<NamedRouterDrawerDestination>();
  }

  @override
  Widget build(BuildContext context) {
    final RouterDrawerController controller =
        context.watch<RouterDrawerController>();

    List<Widget> children = [];
    if (controller.drawerHeader != null) {
      children.add(controller.drawerHeader!(context));
    }

    List<NamedRouterDrawerDestination> destinations =
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
          enabled: destination.enabled?.call(context) ?? true,
          selected: destination.unique &&
              destination.path == controller.drawerSelection,
          title: Text(destination.name),
          leading: destination.icon,
          onTap: destination.unique
              ? () => Navigator.of(context)
                  .pushNamedAndRemoveUntil(destination.path, (_) => false)
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
        child: ListView(
          children: children,
        ),
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
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class AppBarDismissalProxy extends StatefulWidget {
  /// Tricks the enclosed Route into thinking it can be popped.
  ///
  /// This is necessary to escape nested navigators.
  /// The enclosing navigator has to appropriately handle the pop.
  const AppBarDismissalProxy({
    super.key,
    this.enabled = true,
    required this.child,
  });

  /// Whether the enclosed Route can be popped.
  final bool enabled;

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  State<AppBarDismissalProxy> createState() => _AppBarDismissalProxyState();
}

class _AppBarDismissalProxyState extends State<AppBarDismissalProxy> {
  LocalHistoryEntry? _entry;

  late ModalRoute<dynamic> _modalRoute = ModalRoute.of<dynamic>(context)!;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.enabled) {
        _modalRoute.addLocalHistoryEntry(createEntry());
      }
    });
  }

  LocalHistoryEntry createEntry() {
    return _entry = LocalHistoryEntry(
      onRemove: () => _entry = null,
    );
  }

  @override
  void didUpdateWidget(covariant AppBarDismissalProxy oldWidget) {
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _modalRoute.addLocalHistoryEntry(createEntry());
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _modalRoute.removeLocalHistoryEntry(_entry!);
        });
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ModalRoute route = ModalRoute.of<dynamic>(context)!;
    if (route != _modalRoute) {
      _modalRoute.removeLocalHistoryEntry(_entry!);
      _modalRoute = route;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _modalRoute.addLocalHistoryEntry(createEntry());
      });
    }
  }

  @override
  void dispose() {
    if (_entry != null) {
      _modalRoute.removeLocalHistoryEntry(_entry!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
