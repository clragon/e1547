import 'package:e1547/client/client.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

class HistorySelectionAppBar extends StatelessWidget with AppBarBuilderWidget {
  const HistorySelectionAppBar({super.key, required this.child});

  @override
  final PreferredSizeWidget child;

  @override
  Widget build(BuildContext context) {
    return SelectionAppBar<History>(
      child: child,
      titleBuilder:
          (context, data) =>
              data.selections.length == 1
                  ? Text(data.selections.first.getName(context))
                  : Text('${data.selections.length} entries'),
      actionBuilder:
          (context, data) => [
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                data.onChanged({});
                await context.read<Client>().histories.removeAll(
                  data.selections.map((e) => e.id).toList(),
                );
              },
            ),
          ],
    );
  }
}
