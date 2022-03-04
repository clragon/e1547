import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/data/actions.dart';
import 'package:flutter/material.dart';

class HistorySelectionAppBar extends StatelessWidget with AppBarSize {
  final Set<HistoryEntry> Function()? onSelectAll;
  final void Function(Set<HistoryEntry> selections) onChanged;
  final Set<HistoryEntry> selections;

  const HistorySelectionAppBar({
    required this.selections,
    required this.onChanged,
    this.onSelectAll,
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
      selections: selections,
      onChanged: onChanged,
      onSelectAll: onSelectAll,
      titleBuilder: (context) => selections.length == 1
          ? Text(itemIdentifier(selections.first))
          : Text('${selections.length} entries'),
      actions: [
        IconButton(
          icon: Icon(Icons.delete_outline),
          onPressed: () {
            for (HistoryEntry entry in selections) {
              historyController.removeEntry(entry);
            }
            onChanged({});
          },
        ),
      ],
    );
  }
}
