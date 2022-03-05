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
      builder: (context, child) => SelectionLayout<HistoryEntry>(
        items: historyController.collection.entries,
        child: Scaffold(
          appBar: HistorySelectionAppBar(
            appbar: DefaultAppBar(title: Text('History')),
          ),
          body: historyController.collection.entries.isNotEmpty
              ? GroupedListView<HistoryEntry, DateTime>(
                  elements: historyController.collection.entries,
                  order: GroupedListOrder.DESC,
                  physics: BouncingScrollPhysics(),
                  controller: PrimaryScrollController.of(context),
                  groupBy: (element) => element.visitedAt.stripTime(),
                  groupHeaderBuilder: (element) =>
                      SettingsHeader(title: dateOrName(element.visitedAt)),
                  itemComparator: (a, b) => a.visitedAt.compareTo(b.visitedAt),
                  itemBuilder: (context, element) =>
                      HistoryTile(entry: element),
                )
              : IconMessage(
                  icon: Icon(Icons.history),
                  title: Text('Your history is empty'),
                ),
        ),
      ),
    );
  }
}
