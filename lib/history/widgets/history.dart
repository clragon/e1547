import 'package:e1547/client/client.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/history/widgets/appbar.dart';
import 'package:e1547/history/widgets/list.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';

class HistoriesPage extends StatelessWidget {
  const HistoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    Client client = context.watch<Client>();
    return SubChangeNotifierProvider<Client, HistoryController>(
      create: (context, client) => HistoryController(client: client),
      child: Consumer<HistoryController>(
        builder: (context, controller, child) => SelectionLayout<History>(
          items: controller.items,
          child: RefreshableDataPage.builder(
            appBar: HistorySelectionAppBar(
              child: DefaultAppBar(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('History'),
                    CrossFade.builder(
                      showChild:
                          HistoryQuery.from(controller.search).date != null,
                      builder: (context) => Text(
                        DateFormatting.named(
                            HistoryQuery.from(controller.search).date!),
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color:
                                  Theme.of(context).textTheme.bodySmall!.color,
                            ),
                      ),
                    ),
                  ],
                ),
                actions: const [ContextDrawerButton()],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              child: const Icon(Icons.search),
              onPressed: () async {
                Locale locale = Localizations.localeOf(context);

                // awaiting this here means the UI might not react immediately
                List<DateTime> days = await client.histories.days();
                if (days.isEmpty) {
                  days.add(DateTime.now());
                }

                if (!context.mounted) return;

                HistoryQuery search = HistoryQuery.from(controller.search);

                DateTime? result = await showDatePicker(
                  context: context,
                  initialDate: search.date ?? DateTime.now(),
                  firstDate: days.first,
                  lastDate: days.last,
                  locale: locale,
                  initialEntryMode: DatePickerEntryMode.calendarOnly,
                  selectableDayPredicate: (value) => days.any(
                    (e) => DateUtils.isSameDay(value, e),
                  ),
                );

                if (!context.mounted) return;
                ScrollController scrollController =
                    PrimaryScrollController.of(context);

                if (result != search.date) {
                  if (scrollController.hasClients) {
                    scrollController.animateTo(
                      0,
                      duration: defaultAnimationDuration,
                      curve: Curves.easeInOut,
                    );
                  }

                  controller.search = search.copy()..date = result;
                }
              },
            ),
            drawer: const RouterDrawer(),
            endDrawer: const ContextDrawer(
              title: Text('History'),
              children: [
                HistoryEnableTile(),
                HistoryLimitTile(),
                Divider(),
                HistoryCategoryFilterTile(),
                HistoryTypeFilterTile(),
              ],
            ),
            controller: controller,
            builder: (context, child) => LimitedWidthLayout(child: child),
            child: (context) => PagedGroupedListView<int, History, DateTime>(
              padding: defaultActionListPadding
                  .add(LimitedWidthLayout.of(context).padding),
              pagingController: controller.paging,
              order: GroupedListOrder.DESC,
              controller: PrimaryScrollController.of(context),
              groupBy: (element) => DateUtils.dateOnly(element.visitedAt),
              groupHeaderBuilder: (element) => ListTileHeader(
                  title: DateFormatting.named(element.visitedAt)),
              itemComparator: (a, b) => a.visitedAt.compareTo(b.visitedAt),
              builderDelegate: defaultPagedChildBuilderDelegate<History>(
                pagingController: controller.paging,
                onEmpty: const Text('Your history is empty'),
                onError: const Text('Failed to load history'),
                itemBuilder: (context, item, index) => HistoryTile(entry: item),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
