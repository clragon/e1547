import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

/// Utility to get icon widgets from string names
Widget getIconFromString(String iconName) {
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

/// Custom drawer that respects user configuration
class CustomizableRouterDrawer extends StatelessWidget {
  const CustomizableRouterDrawer({super.key});

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

    // Group items
    Map<String, List<DrawerItemConfig>> groupedItems = {};
    for (final item in enabledItems) {
      groupedItems.putIfAbsent(item.group, () => []).add(item);
    }

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
            leading: getIconFromString(item.icon),
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
