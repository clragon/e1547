import 'package:e1547/client/client.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/stream/stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';
import 'package:intl/intl.dart';

class HistoryEnableTile extends StatelessWidget {
  const HistoryEnableTile({super.key});

  @override
  Widget build(BuildContext context) {
    Client client = context.watch<Client>();
    return SubStream<int>(
      create: () => client.histories.count().streamed,
      keys: [client],
      builder: (context, countSnapshot) => SubStream(
        initialData: client.histories.enabled,
        create: () => client.histories.enabledStream,
        builder: (context, enabledSnapshot) => SwitchListTile(
          title: const Text('Enabled'),
          subtitle: Text('${countSnapshot.data ?? 0} pages visited'),
          secondary: const Icon(Icons.history),
          value: enabledSnapshot.data!,
          onChanged: (value) => client.histories.enabled = value,
        ),
      ),
    );
  }
}

class HistoryLimitTile extends StatelessWidget {
  const HistoryLimitTile({super.key});

  @override
  Widget build(BuildContext context) {
    Client client = context.watch<Client>();
    return SubStream(
      create: () => client.histories.trimmingStream,
      initialData: client.histories.trimming,
      builder: (context, snapshot) => SwitchListTile(
        value: snapshot.data!,
        onChanged: (value) {
          if (value) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('History limit'),
                content: Text(
                  'Enabling history limit means all history entries beyond ${NumberFormat.compact().format(client.histories.trimAmount)} '
                  'and all entries older than ${client.histories.trimAge.inDays ~/ 30} months are automatically deleted.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: const Text('CANCEL'),
                  ),
                  TextButton(
                    onPressed: () {
                      client.histories.trimming = value;
                      Navigator.of(context).maybePop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          } else {
            client.histories.trimming = value;
          }
        },
        secondary: Icon(
          snapshot.data! ? Icons.hourglass_bottom : Icons.hourglass_empty,
        ),
        title: const Text('Limit history'),
        subtitle: snapshot.data!
            ? Text(
                'Limited to newer than ${client.histories.trimAge.inDays ~/ 30} months or '
                'less than ${NumberFormat.compact().format(client.histories.trimAmount)} entries.',
              )
            : const Text('history is infinite'),
      ),
    );
  }
}

class HistoryCategoryFilterTile extends StatelessWidget {
  const HistoryCategoryFilterTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryController>(
      builder: (context, controller, child) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 12),
            child: ListTileHeader(title: 'Entries'),
          ),
          for (final filter in HistoryCategory.values)
            AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                HistoryQuery query = HistoryQuery.from(controller.search);
                return Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: CheckboxListTile(
                    secondary: filter.icon,
                    title: Text(filter.title),
                    value: query.categories?.contains(filter) ?? true,
                    onChanged: (value) {
                      if (value == null) return;
                      Set<HistoryCategory> filters =
                          query.categories ?? HistoryCategory.values.toSet();
                      if (value) {
                        filters.add(filter);
                      } else {
                        filters.remove(filter);
                      }
                      controller.search = query.copy()..categories = filters;
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class HistoryTypeFilterTile extends StatelessWidget {
  const HistoryTypeFilterTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryController>(
      builder: (context, controller, child) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 12),
            child: ListTileHeader(title: 'Type'),
          ),
          for (final filter in HistoryType.values)
            AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                HistoryQuery query = HistoryQuery.from(controller.search);
                return Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: CheckboxListTile(
                    secondary: filter.icon,
                    title: Text(filter.title),
                    value: query.types?.contains(filter) ?? true,
                    onChanged: (value) {
                      if (value == null) return;
                      Set<HistoryType> filters =
                          query.types ?? HistoryType.values.toSet();
                      if (value) {
                        filters.add(filter);
                      } else {
                        filters.remove(filter);
                      }
                      controller.search = query.copy()..types = filters;
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
