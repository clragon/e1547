import 'package:async_builder/async_builder.dart';
import 'package:async_builder/init_builder.dart';
import 'package:collection/collection.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/history/widgets/appbar.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage();

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  DateTime? search;
  Set<HistoryFilter> filters = HistoryFilter.values.toSet();

  String _buildFilter() =>
      r'^' '${filters.map((e) => '(${e.regex})').join('|')}' r'$';

  @override
  Widget build(BuildContext context) {
    return LimitedWidthLayout(
      child: Consumer<HistoriesService>(
        builder: (context, service, child) =>
            SubValueBuilder<Stream<List<History>>>(
          create: (context) =>
              service.watchAll(linkRegex: _buildFilter(), day: search),
          selector: (context) => [service, _buildFilter(), search],
          builder: (context, stream) => AsyncBuilder<List<History>>(
            stream: stream,
            builder: (context, histories) => SelectionLayout<History>(
              items: histories,
              child: Scaffold(
                appBar: HistorySelectionAppBar(
                  child: DefaultAppBar(
                    leading: const BackButton(),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('History'),
                        CrossFade.builder(
                          showChild: search != null,
                          builder: (context) => Text(
                            dateOrName(search!),
                            style:
                                Theme.of(context).textTheme.bodyText2!.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .caption!
                                          .color,
                                    ),
                          ),
                        ),
                      ],
                    ),
                    actions: const [ContextDrawerButton()],
                  ),
                ),
                body: AsyncBuilder<List<History>>(
                  stream: stream,
                  waiting: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  builder: (context, histories) => histories!.isNotEmpty
                      ? GroupedListView<History, DateTime>(
                          padding: defaultActionListPadding
                              .add(LimitedWidthLayout.of(context).padding),
                          elements: histories,
                          order: GroupedListOrder.DESC,
                          controller: PrimaryScrollController.of(context),
                          groupBy: (element) =>
                              DateUtils.dateOnly(element.visitedAt),
                          groupHeaderBuilder: (element) => SettingsHeader(
                              title: dateOrName(element.visitedAt)),
                          itemComparator: (a, b) =>
                              a.visitedAt.compareTo(b.visitedAt),
                          itemBuilder: (context, element) =>
                              HistoryTile(entry: element),
                        )
                      : const IconMessage(
                          icon: Icon(Icons.history),
                          title: Text('Your history is empty'),
                        ),
                ),
                floatingActionButton: FloatingActionButton(
                  child: const Icon(Icons.search),
                  onPressed: () async {
                    List<DateTime> dates = await service.dates();

                    DateTime? result = await showDatePicker(
                      context: context,
                      initialDate: search ?? DateTime.now(),
                      firstDate: dates.first,
                      lastDate: dates.last,
                      locale: Localizations.localeOf(context),
                      initialEntryMode: DatePickerEntryMode.calendarOnly,
                      selectableDayPredicate: (value) =>
                          dates.any((e) => DateUtils.isSameDay(value, e)),
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
                      subtitle: TweenAnimationBuilder(
                        tween: IntTween(begin: 0, end: histories?.length ?? 0),
                        duration: const Duration(milliseconds: 200),
                        builder: (context, value, child) =>
                            Text('$value entries shown'),
                      ),
                    ),
                    const Divider(),
                    for (final filter in HistoryFilter.values)
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: CheckboxListTile(
                          title: Text(filter.title),
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
                    if (histories != null)
                      InitBuilder<Stream<int>>(
                        getter: service.watchLength,
                        builder: (context, stream) => AsyncBuilder<int>(
                          stream: stream,
                          builder: (context, value) => CrossFade(
                            showChild: value != null,
                            child: Center(
                              child: Text(
                                'of ${value ?? 0} entries',
                                style: TextStyle(
                                  color: dimTextColor(context),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum HistoryFilter {
  posts,
  pools,
  other;

  String get title {
    switch (this) {
      case posts:
        return 'Posts';
      case pools:
        return 'Pools';
      case other:
        return 'Other';
    }
  }

  String? get regex {
    switch (this) {
      case posts:
        return r'/posts/\d+';
      case pools:
        return r'/pools/\d+';
      case other:
        return r'^(?:(?!'
            '(${values.whereNot((e) => e == other).map((e) => e.regex).join('|')})'
            r').)+$';
    }
  }
}
