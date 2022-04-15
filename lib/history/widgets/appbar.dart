import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/data/actions.dart';
import 'package:flutter/material.dart';

class HistorySelectionAppBar extends StatelessWidget with PreferredSizeWidget {
  final PreferredSizeWidget appbar;

  @override
  Size get preferredSize => appbar.preferredSize;

  const HistorySelectionAppBar({
    required this.appbar,
  });

  @override
  Widget build(BuildContext context) {
    String itemIdentifier(HistoryEntry entry) {
      if (entry is PostHistoryEntry) {
        return 'Post #${entry.id}';
      } else if (entry is TagHistoryEntry) {
        return '${tagToTitle(entry.tags)}';
      } else {
        throw UnimplementedError(
            'No item identifier implementation for this HistoryEntry: $entry');
      }
    }

    return SelectionAppBar<HistoryEntry>(
      appbar: appbar,
      titleBuilder: (context, data) => data.selections.length == 1
          ? Text(itemIdentifier(data.selections.first))
          : Text('${data.selections.length} entries'),
      actionBuilder: (context, data) => [
        IconButton(
          icon: Icon(Icons.delete_outline),
          onPressed: () {
            historyController.removeEntries(data.selections.toList());
            data.onChanged({});
          },
        ),
      ],
    );
  }
}
