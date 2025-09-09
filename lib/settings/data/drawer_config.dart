import 'package:flutter/foundation.dart';

/// Represents a configurable drawer item
@immutable
class DrawerItemConfig {
  const DrawerItemConfig({
    required this.id,
    required this.name,
    required this.icon,
    required this.path,
    required this.group,
    this.enabled = true,
    this.order = 0,
  });

  final String id;
  final String name;
  final String icon; // Icon name as string for serialization
  final String path;
  final String group;
  final bool enabled;
  final int order;

  DrawerItemConfig copyWith({
    String? id,
    String? name,
    String? icon,
    String? path,
    String? group,
    bool? enabled,
    int? order,
  }) {
    return DrawerItemConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      path: path ?? this.path,
      group: group ?? this.group,
      enabled: enabled ?? this.enabled,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'path': path,
      'group': group,
      'enabled': enabled,
      'order': order,
    };
  }

  DrawerItemConfig.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        name = json['name'] as String,
        icon = json['icon'] as String,
        path = json['path'] as String,
        group = json['group'] as String,
        enabled = json['enabled'] as bool? ?? true,
        order = json['order'] as int? ?? 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DrawerItemConfig &&
        other.id == id &&
        other.name == name &&
        other.icon == icon &&
        other.path == path &&
        other.group == group &&
        other.enabled == enabled &&
        other.order == order;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, icon, path, group, enabled, order);
  }
}

/// Configuration for the entire drawer
@immutable
class DrawerConfiguration {
  const DrawerConfiguration({
    required this.items,
    required this.startupScreen,
  });

  final List<DrawerItemConfig> items;
  final String startupScreen; // path of the startup screen

  DrawerConfiguration copyWith({
    List<DrawerItemConfig>? items,
    String? startupScreen,
  }) {
    return DrawerConfiguration(
      items: items ?? this.items,
      startupScreen: startupScreen ?? this.startupScreen,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'startupScreen': startupScreen,
    };
  }

  DrawerConfiguration.fromJson(Map<String, dynamic> json)
      : items = (json['items'] as List<dynamic>)
            .map((item) => DrawerItemConfig.fromJson(item as Map<String, dynamic>))
            .toList(),
        startupScreen = json['startupScreen'] as String? ?? '/';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DrawerConfiguration &&
        listEquals(other.items, items) &&
        other.startupScreen == startupScreen;
  }

  @override
  int get hashCode {
    return Object.hash(Object.hashAll(items), startupScreen);
  }
}

/// Default drawer configuration
const List<DrawerItemConfig> defaultDrawerItems = [
  DrawerItemConfig(
    id: 'home',
    name: 'Home',
    icon: 'home',
    path: '/',
    group: 'search',
    enabled: true, // Always enabled - essential screen
  ),
  DrawerItemConfig(
    id: 'hot',
    name: 'Hot',
    icon: 'whatshot',
    path: '/hot',
    group: 'search',
    order: 1,
  ),
  DrawerItemConfig(
    id: 'popular',
    name: 'Popular',
    icon: 'trending_up',
    path: '/popular',
    group: 'search',
    order: 2,
  ),
  DrawerItemConfig(
    id: 'search',
    name: 'Search',
    icon: 'search',
    path: '/search',
    group: 'search',
    order: 3,
  ),
  DrawerItemConfig(
    id: 'favorites',
    name: 'Favorites',
    icon: 'favorite',
    path: '/favorites',
    group: 'follows',
    order: 4,
  ),
  DrawerItemConfig(
    id: 'timeline',
    name: 'Timeline',
    icon: 'feed',
    path: '/timeline',
    group: 'follows',
    order: 5,
  ),
  DrawerItemConfig(
    id: 'subscriptions',
    name: 'Subscriptions',
    icon: 'person_add',
    path: '/subscriptions',
    group: 'follows',
    order: 6,
  ),
  DrawerItemConfig(
    id: 'bookmarks',
    name: 'Bookmarks',
    icon: 'bookmark',
    path: '/bookmarks',
    group: 'follows',
    order: 7,
  ),
  DrawerItemConfig(
    id: 'pools',
    name: 'Pools',
    icon: 'collections',
    path: '/pools',
    group: 'collections',
    order: 8,
  ),
  DrawerItemConfig(
    id: 'forum',
    name: 'Forum',
    icon: 'forum',
    path: '/forum',
    group: 'collections',
    order: 9,
  ),
  DrawerItemConfig(
    id: 'history',
    name: 'History',
    icon: 'history',
    path: '/history',
    group: 'settings',
    order: 10,
  ),
  DrawerItemConfig(
    id: 'settings',
    name: 'Settings',
    icon: 'settings',
    path: '/settings',
    group: 'settings',
    enabled: true, // Always enabled - essential screen
    order: 11,
  ),
  DrawerItemConfig(
    id: 'about',
    name: 'About',
    icon: 'info',
    path: '/about',
    group: 'settings',
    order: 12,
  ),
];

const DrawerConfiguration defaultDrawerConfiguration = DrawerConfiguration(
  items: defaultDrawerItems,
  startupScreen: '/',
);
