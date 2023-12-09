import 'package:e1547/interface/interface.dart';
import 'package:e1547/logs/logs.dart';
import 'package:flutter/material.dart';
import 'package:recase/recase.dart';

class LogRecordDrawer extends StatelessWidget {
  const LogRecordDrawer({
    super.key,
    required this.levels,
    required this.onChanged,
  });

  final List<int> levels;
  final ValueSetter<List<int>> onChanged;

  @override
  Widget build(BuildContext context) {
    const List<Level> filters = [
      Level.FINE,
      Level.INFO,
      Level.WARNING,
      Level.SEVERE,
      Level.SHOUT,
    ];

    Map<Level, Widget> icons = {
      Level.FINE: const Icon(Icons.monitor_heart_outlined),
      Level.INFO: const Icon(Icons.info_outline),
      Level.WARNING: const Icon(Icons.warning_amber),
      Level.SEVERE: const Icon(Icons.report_outlined),
      Level.SHOUT: const Icon(Icons.crisis_alert),
    };

    return ContextDrawer(
      title: const Text('Logs'),
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 12),
          child: ListTileHeader(title: 'Levels'),
        ),
        for (final filter in filters)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: CheckboxListTile(
              secondary: icons[filter],
              title: Text(filter.name.pascalCase),
              value: levels.contains(filter.value),
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                List<int> levels = List.of(this.levels);
                if (value) {
                  levels.add(filter.value);
                } else {
                  levels.remove(filter.value);
                }
                onChanged(levels);
              },
            ),
          ),
      ],
    );
  }
}
