import 'package:e1547/history/history.dart';
import 'package:e1547/history/widgets/appbar.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: historyController,
      builder: (context, child) {
        List<HistoryEntry> history = historyController.collection.entries;
        return SelectionScope<HistoryEntry>(
          builder: (context, selections, onSelectionChanged) => Scaffold(
            appBar: selections.isEmpty
                ? DefaultAppBar(
                    title: Text('History'),
                  )
                : HistorySelectionAppBar(
                    selections: selections,
                    onChanged: onSelectionChanged,
                    onSelectAll: () => history.toSet(),
                  ),
            body: history.isNotEmpty
                ? GroupedListView<HistoryEntry, DateTime>(
                    elements: history,
                    order: GroupedListOrder.DESC,
                    physics: BouncingScrollPhysics(),
                    controller: PrimaryScrollController.of(context),
                    groupBy: (element) => element.visitedAt.stripTime(),
                    groupHeaderBuilder: (element) =>
                        SettingsHeader(title: dateOrName(element.visitedAt)),
                    itemComparator: (a, b) =>
                        a.visitedAt.compareTo(b.visitedAt),
                    itemBuilder: (context, element) => HistoryTile(
                      entry: element,
                      selections: selections,
                      onSelectionChanged: onSelectionChanged,
                    ),
                  )
                : IconMessage(
                    icon: Icon(Icons.history),
                    title: Text('Your history is empty'),
                  ),
          ),
        );
      },
    );
  }
}
