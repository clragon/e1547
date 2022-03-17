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
  DateTime? search;

  @override
  Widget build(BuildContext context) {
    return LimitedWidthLayout(
      child: AnimatedBuilder(
        animation: historyController,
        builder: (context, child) {
          List<HistoryEntry> entries = historyController.collection.entries;
          if (search != null) {
            entries.retainWhere((element) =>
                DateUtils.dateOnly(element.visitedAt)
                    .isAtSameMomentAs(search!));
          }
          bool isNotEmpty = entries.isNotEmpty;
          return SelectionLayout<HistoryEntry>(
            items: entries,
            child: Scaffold(
              appBar: HistorySelectionAppBar(
                appbar: DefaultAppBar(
                  title: Text('History' +
                      (search != null ? ' - ${dateOrName(search!)}' : '')),
                ),
              ),
              body: isNotEmpty
                  ? GroupedListView<HistoryEntry, DateTime>(
                      padding: defaultActionListPadding
                          .add(LimitedWidthLayout.of(context)!.padding),
                      elements: entries,
                      order: GroupedListOrder.DESC,
                      physics: BouncingScrollPhysics(),
                      controller: PrimaryScrollController.of(context),
                      groupBy: (element) =>
                          DateUtils.dateOnly(element.visitedAt),
                      groupHeaderBuilder: (element) =>
                          SettingsHeader(title: dateOrName(element.visitedAt)),
                      itemComparator: (a, b) =>
                          a.visitedAt.compareTo(b.visitedAt),
                      itemBuilder: (context, element) =>
                          HistoryTile(entry: element),
                    )
                  : IconMessage(
                      icon: Icon(Icons.history),
                      title: Text('Your history is empty'),
                    ),
              floatingActionButton: FloatingActionButton(
                child: Icon(Icons.search),
                onPressed: () async {
                  DateTime firstDate =
                      historyController.collection.entries.first.visitedAt;
                  DateTime lastDate =
                      historyController.collection.entries.last.visitedAt;

                  DateTime? result = await showDatePicker(
                    context: context,
                    initialDate: search ?? DateTime.now(),
                    firstDate: firstDate,
                    lastDate: lastDate,
                    locale: Localizations.localeOf(context),
                    cancelText: 'CLEAR',
                    initialEntryMode: DatePickerEntryMode.calendarOnly,
                    selectableDayPredicate: (date) =>
                        historyController.collection.entries.any(
                      (element) => DateUtils.dateOnly(element.visitedAt)
                          .isAtSameMomentAs(date),
                    ),
                  );

                  ScrollController? scrollController =
                      PrimaryScrollController.of(context);
                  if (result != search &&
                      (scrollController?.hasClients ?? false)) {
                    scrollController!.animateTo(0,
                        duration: defaultAnimationDuration,
                        curve: Curves.easeInOut);
                  }

                  setState(() {
                    search = result;
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
