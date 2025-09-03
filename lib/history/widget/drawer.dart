import 'package:e1547/domain/domain.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';
import 'package:intl/intl.dart';

class HistoryEnableTile extends StatelessWidget {
  const HistoryEnableTile({super.key});

  @override
  Widget build(BuildContext context) {
    final domain = context.watch<Domain>();
    return QueryBuilder(
      query: domain.histories.useCount(),
      builder: (context, countState) => SubStream(
        initialData: domain.histories.enabled,
        create: () => domain.histories.enabledStream,
        builder: (context, enabledSnapshot) => SwitchListTile(
          title: const Text('Enabled'),
          subtitle: Text('${countState.data ?? 0} pages visited'),
          secondary: const Icon(Icons.history),
          value: enabledSnapshot.data!,
          onChanged: (value) => domain.histories.enabled = value,
        ),
      ),
    );
  }
}

class HistoryLimitTile extends StatelessWidget {
  const HistoryLimitTile({super.key});

  @override
  Widget build(BuildContext context) {
    final domain = context.watch<Domain>();
    return SubStream(
      create: () => domain.histories.trimmingStream,
      initialData: domain.histories.trimming,
      builder: (context, snapshot) => SwitchListTile(
        value: snapshot.data!,
        onChanged: (value) {
          if (value) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('History limit'),
                content: Text(
                  'Enabling history limit means all history entries beyond ${NumberFormat.compact().format(domain.histories.trimAmount)} '
                  'and all entries older than ${domain.histories.trimAge.inDays ~/ 30} months are automatically deleted.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: const Text('CANCEL'),
                  ),
                  TextButton(
                    onPressed: () {
                      domain.histories.trimming = value;
                      Navigator.of(context).maybePop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          } else {
            domain.histories.trimming = value;
          }
        },
        secondary: Icon(
          snapshot.data! ? Icons.hourglass_bottom : Icons.hourglass_empty,
        ),
        title: const Text('Limit history'),
        subtitle: snapshot.data!
            ? Text(
                'Limited to newer than ${domain.histories.trimAge.inDays ~/ 30} months or '
                'less than ${NumberFormat.compact().format(domain.histories.trimAmount)} entries.',
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
    return Consumer<HistoryParams>(
      builder: (context, params, _) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 12),
            child: ListTileHeader(title: 'Entries'),
          ),
          for (final filter in HistoryCategory.values)
            AnimatedBuilder(
              animation: params,
              builder: (context, child) {
                return Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: CheckboxListTile(
                    secondary: filter.icon,
                    title: Text(filter.title),
                    value: params.categories?.contains(filter) ?? true,
                    onChanged: (value) {
                      if (value == null) return;
                      Set<HistoryCategory> filters =
                          params.categories ?? HistoryCategory.values.toSet();
                      if (value) {
                        filters.add(filter);
                      } else {
                        filters.remove(filter);
                      }
                      params.categories = filters;
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
    return Consumer<HistoryParams>(
      builder: (context, params, _) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 12),
            child: ListTileHeader(title: 'Type'),
          ),
          for (final filter in HistoryType.values)
            AnimatedBuilder(
              animation: params,
              builder: (context, child) {
                return Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: CheckboxListTile(
                    secondary: filter.icon,
                    title: Text(filter.title),
                    value: params.types?.contains(filter) ?? true,
                    onChanged: (value) {
                      if (value == null) return;
                      Set<HistoryType> filters =
                          params.types ?? HistoryType.values.toSet();
                      if (value) {
                        filters.add(filter);
                      } else {
                        filters.remove(filter);
                      }
                      params.types = filters;
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
