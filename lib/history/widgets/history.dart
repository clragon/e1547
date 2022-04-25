import 'package:e1547/history/history.dart';
import 'package:e1547/history/widgets/appbar.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/tag/tag.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum HistoryFilter {
  Posts,
  Tags,
  Pools,
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  DateTime? search;
  Set<HistoryFilter> filters = HistoryFilter.values.toSet();

  List<HistoryEntry> filter(List<HistoryEntry> entries) {
    if (search != null) {
      entries.retainWhere(
        (element) =>
            DateUtils.dateOnly(element.visitedAt).isAtSameMomentAs(search!),
      );
    }
    List<HistoryEntry> updated = [];
    for (final filter in filters) {
      switch (filter) {
        case HistoryFilter.Posts:
          updated.addAll(
            entries.where((element) => element is PostHistoryEntry),
          );
          break;
        case HistoryFilter.Tags:
          updated.addAll(
            entries.where(
              (element) =>
                  element is TagHistoryEntry &&
                  !poolRegex().hasMatch(element.tags),
            ),
          );
          break;
        case HistoryFilter.Pools:
          updated.addAll(
            entries.where(
              (element) =>
                  element is TagHistoryEntry &&
                  poolRegex().hasMatch(element.tags),
            ),
          );
          break;
      }
    }
    return updated;
  }

  @override
  Widget build(BuildContext context) {
    return LimitedWidthLayout(
      child: AnimatedBuilder(
        animation: historyController,
        builder: (context, child) {
          List<HistoryEntry> entries =
              filter(historyController.collection.entries);
          bool isNotEmpty = entries.isNotEmpty;
          return SelectionLayout<HistoryEntry>(
            items: entries,
            child: Scaffold(
              appBar: HistorySelectionAppBar(
                child: DefaultAppBar(
                  leading: BackButton(),
                  title: Text(
                    'History' +
                        (search != null ? ' - ${dateOrName(search!)}' : ''),
                  ),
                  actions: [
                    ContextDrawerButton(),
                  ],
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
              endDrawer: ContextDrawer(
                title: Text('History'),
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.info_outline,
                      color: dimTextColor(context),
                    ),
                    subtitle: Text(
                      'History entries are deleted when they are '
                      'older than ${HistoryController.maxAge.inDays} days or '
                      'there are more then ${NumberFormat.compact().format(HistoryController.maxCount)} entries.',
                      style: TextStyle(
                        color: dimTextColor(context),
                      ),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.filter_alt),
                    title: Text('Filter'),
                    subtitle: Text('${entries.length} entries shown'),
                  ),
                  Divider(),
                  for (final filter in HistoryFilter.values)
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: CheckboxListTile(
                        title: Text(filter.name),
                        value: filters.contains(filter),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            if (value) {
                              filters.add(filter);
                            } else {
                              filters.remove(filter);
                            }
                          });
                        },
                      ),
                    ),
                  Divider(),
                  Center(
                    child: Text(
                      'of ${historyController.collection.entries.length} entries',
                      style: TextStyle(
                        color: dimTextColor(context),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
