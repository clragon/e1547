import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
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
    return SelectionAppBar<HistoryEntry>(
      selections: selections,
      onChanged: onChanged,
      onSelectAll: onSelectAll,
      titleBuilder: (context) => selections.length == 1
          ? Text('entry #${selections.first.postId}')
          : Text('${selections.length} entries'),
      actions: [
        IconButton(
          icon: Icon(Icons.delete_outline),
          onPressed: () {
            for (HistoryEntry entry in selections) {
              removeFromHistory(entry);
            }
            onChanged({});
          },
        ),
      ],
    );
  }
}
