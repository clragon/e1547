import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class DrawerCustomizationTile extends StatelessWidget {
  const DrawerCustomizationTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Settings>(
      builder: (context, settings, child) => ListTile(
        title: const Text('Customize drawer'),
        subtitle: const Text('Manage screens and startup page'),
        leading: const Icon(Icons.tune),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const DrawerCustomizationPage(),
          ),
        ),
      ),
    );
  }
}

class DrawerCustomizationPage extends StatefulWidget {
  const DrawerCustomizationPage({super.key});

  @override
  State<DrawerCustomizationPage> createState() => _DrawerCustomizationPageState();
}

class _DrawerCustomizationPageState extends State<DrawerCustomizationPage> {
  late DrawerConfiguration _config;
  late List<DrawerItemConfig> _items;

  @override
  void initState() {
    super.initState();
    final Settings settings = context.read<Settings>();
    _config = settings.drawerConfig;
    _items = List<DrawerItemConfig>.from(_config.items);
    
    // Ensure essential items are enabled
    _items = _items.map((item) {
      if (item.id == 'settings' || item.id == 'home') {
        return item.copyWith(enabled: true);
      }
      return item;
    }).toList();
    
    _items.sort((a, b) => a.order.compareTo(b.order));
  }

  void _saveConfiguration() {
    final Settings settings = context.read<Settings>();
    final newConfig = _config.copyWith(items: _items);
    settings.drawerConfig = newConfig;
    Navigator.of(context).pop();
  }

  void _resetToDefault() {
    setState(() {
      _config = defaultDrawerConfiguration;
      _items = List<DrawerItemConfig>.from(_config.items);
      
      // Ensure essential items are enabled
      _items = _items.map((item) {
        if (item.id == 'settings' || item.id == 'home') {
          return item.copyWith(enabled: true);
        }
        return item;
      }).toList();
      
      _items.sort((a, b) => a.order.compareTo(b.order));
    });
  }

  void _toggleItem(DrawerItemConfig item) {
    // Prevent disabling essential screens
    if (item.id == 'settings' || item.id == 'home') {
      return;
    }
    
    setState(() {
      final index = _items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _items[index] = item.copyWith(enabled: !item.enabled);
      }
    });
  }

  void _changeStartupScreen(String path) {
    setState(() {
      _config = _config.copyWith(startupScreen: path);
    });
  }

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
    Map<String, List<DrawerItemConfig>> groupedItems = {};
    for (final item in _items) {
      groupedItems.putIfAbsent(item.group, () => []).add(item);
    }

    final enabledItems = _items.where((item) => item.enabled).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize Drawer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetToDefault,
            tooltip: 'Reset to Default',
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveConfiguration,
            tooltip: 'Save',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Startup Screen Selection
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Startup Screen',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _config.startupScreen,
                    decoration: const InputDecoration(
                      labelText: 'Default startup screen',
                      border: OutlineInputBorder(),
                    ),
                    items: enabledItems
                        .map((item) => DropdownMenuItem(
                              value: item.path,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _getIconFromString(item.icon),
                                  const SizedBox(width: 8),
                                  Text(item.name),
                                ],
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _changeStartupScreen(value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Screen Configuration
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Screens',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toggle screens to show or hide them in the drawer. Drag the handle to reorder items.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  
                  // Reorderable list with improved UI
                  ReorderableListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        final item = _items.removeAt(oldIndex);
                        _items.insert(newIndex, item);
                        
                        // Update order values based on new positions
                        for (int i = 0; i < _items.length; i++) {
                          _items[i] = _items[i].copyWith(order: i);
                        }
                      });
                    },
                    children: _items.map((item) {
                      final isEssential = item.id == 'settings' || item.id == 'home';
                      
                      return Container(
                        key: ValueKey(item.id),
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                            width: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: Theme.of(context).cardColor,
                        ),
                        child: ListTile(
                          title: Text(item.name),
                          subtitle: Text(
                            isEssential 
                                ? '${item.group} • ${item.path} • Required'
                                : '${item.group} • ${item.path}'
                          ),
                          leading: _getIconFromString(item.icon),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: item.enabled,
                                onChanged: isEssential ? null : (_) => _toggleItem(item),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isEssential ? Icons.lock : Icons.drag_handle,
                                color: isEssential ? Colors.grey : Theme.of(context).iconTheme.color,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Preview Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Drawer Preview',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enabled screens in order:',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView(
                      padding: const EdgeInsets.all(8),
                      children: enabledItems.map((item) {
                        return ListTile(
                          dense: true,
                          title: Text(item.name),
                          leading: _getIconFromString(item.icon),
                          trailing: item.path == _config.startupScreen
                              ? const Icon(Icons.home, color: Colors.green)
                              : null,
                          visualDensity: VisualDensity.compact,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Instructions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline),
                      const SizedBox(width: 8),
                      Text(
                        'How to Customize',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Toggle switches to show/hide screens in the drawer\n'
                    '• Drag the handle (⋮⋮) to reorder items - drag up or down to change position\n'
                    '• Choose your preferred startup screen from enabled items\n'
                    '• Use the reset button to restore defaults\n'
                    '• Home and Settings cannot be disabled (required for app functionality)',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
