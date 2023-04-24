import 'package:e1547/interface/interface.dart';
import 'package:e1547/logs/data/log.dart';
import 'package:e1547/logs/data/printer.dart';
import 'package:flutter/material.dart';

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
    const List<LogLevel> filters = [
      LogLevel.debug,
      LogLevel.info,
      LogLevel.warning,
      LogLevel.error,
      logLevelCritical,
    ];

    Map<LogLevel, Widget> icons = {
      LogLevel.debug: const Icon(Icons.build),
      LogLevel.info: const Icon(Icons.info_outline),
      LogLevel.warning: const Icon(Icons.warning_amber),
      LogLevel.error: const Icon(Icons.error_outline),
      logLevelCritical: const Icon(Icons.error),
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
              title: Text(filter.name),
              value: levels.contains(filter.priority),
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                List<int> levels = List.of(this.levels);
                if (value) {
                  levels.add(filter.priority);
                } else {
                  levels.remove(filter.priority);
                }
                onChanged(levels);
              },
            ),
          ),
      ],
    );
  }
}
