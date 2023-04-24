import 'package:e1547/logs/logs.dart';
import 'package:flutter/widgets.dart';

class RouteLoggerObserver extends NavigatorObserver {
  final Loggy loggy = Loggy('Routes');

  void logRoute(Route<dynamic>? route, String action) {
    if (route == null) return;
    String? name = route.settings.name;
    if (name == null) {
      if (route is PageRoute) {
        name = 'A page';
      } else if (route is ModalRoute) {
        name = 'A modal';
      }
    }
    name ??= 'A route';
    loggy.debug('$name $action');
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    logRoute(route, 'was pushed');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    logRoute(route, 'was removed');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    logRoute(oldRoute, 'was replaced');
    logRoute(newRoute, 'has replaced');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    logRoute(route, 'was popped');
  }
}
