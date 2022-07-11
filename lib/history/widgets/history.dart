import 'package:e1547/history/history.dart';
import 'package:e1547/history/widgets/appbar.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';


class HistoryPage extends StatefulWidget {
  const HistoryPage();

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  DateTime? search;
  Set<HistoryFilter> filters = HistoryFilter.values.toSet();

  List<History> filter(List<History> entries) {
    if (search != null) {
      entries.retainWhere(
        (element) =>
            DateUtils.dateOnly(element.visitedAt).isAtSameMomentAs(search!),
      );
    }
    List<History> updated = [];
    for (final filter in filters) {
      switch (filter) {
        case HistoryFilter.posts:
          updated.addAll(
            entries.where((e) => e.isPost),
          );
          break;
        case HistoryFilter.searches:
          updated.addAll(
            entries.where((e) => e.isSearch),
          );
          break;
        case HistoryFilter.pools:
          updated.addAll(
            entries.where((e) => e.isPool),
          );
          break;
      }
    }
    return updated;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('eeee'),),
      body: Center(
        child: Text('balls'),
      ),
    );
    /*
    return LimitedWidthLayout(
      child: AnimatedBuilder(
        animation: historyController,
        builder: (context, child) {
          List<History> entries = filter(historyController.collection.entries);
          bool isNotEmpty = entries.isNotEmpty;
          return SelectionLayout<History>(
            items: entries,
            child: Scaffold(
              appBar: HistorySelectionAppBar(
                child: DefaultAppBar(
                  leading: const BackButton(),
                  title: Text(
                    'History${search != null ? ' - ${dateOrName(search!)}' : ''}',
                  ),
                  actions: const [
                    ContextDrawerButton(),
                  ],
                ),
              ),
              body: isNotEmpty
                  ? GroupedListView<History, DateTime>(
                      padding: defaultActionListPadding
                          .add(LimitedWidthLayout.of(context).padding),
                      elements: entries,
                      order: GroupedListOrder.DESC,
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
                  : const IconMessage(
                      icon: Icon(Icons.history),
                      title: Text('Your history is empty'),
                    ),
              floatingActionButton: FloatingActionButton(
                child: const Icon(Icons.search),
                onPressed: () async {
                  // TODO: add method to get first and last date?
                  DateTime firstDate = DateTime.now();
                  DateTime lastDate = DateTime.now();

                  DateTime? result = await showDatePicker(
                    context: context,
                    initialDate: search ?? DateTime.now(),
                    firstDate: firstDate,
                    lastDate: lastDate,
                    locale: Localizations.localeOf(context),
                    initialEntryMode: DatePickerEntryMode.calendarOnly,
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
                title: const Text('History'),
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.info_outline,
                      color: dimTextColor(context),
                    ),
                    // TODO: build setting for this
                    subtitle: Text(
                      'History entries are deleted when they are '
                      'older than 30 days or '
                      'there are more then ${NumberFormat.compact().format(3000)} entries.',
                      style: TextStyle(
                        color: dimTextColor(context),
                      ),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.filter_alt),
                    title: const Text('Filter'),
                    // TODO: impossible
                    // subtitle: Text('${entries.length} entries shown'),
                  ),
                  const Divider(),
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
                  const Divider(),
                  Center(
                    // TODO: fix this, somehow?
                    child: Text(
                      'of 0 entries',
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
     */
  }
}
