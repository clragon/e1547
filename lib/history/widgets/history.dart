import 'package:e1547/history/history.dart';
import 'package:e1547/history/widgets/appbar.dart';
import 'package:e1547/history/widgets/list.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';

class HistoriesPage extends StatelessWidget {
  const HistoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HistoriesProvider(
      child: Consumer<HistoriesController>(
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
                      showChild: controller.search.date != null,
                      builder: (context) => Text(
                        dateOrName(controller.search.date!),
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
                List<DateTime> dates =
                    await controller.service.dates(host: controller.host);
                if (dates.isEmpty) {
                  dates.add(DateTime.now());
                }

                // the lint is broken
                // ignore: use_build_context_synchronously
                if (!context.mounted) return;

                DateTime? result = await showDatePicker(
                  context: context,
                  initialDate: controller.search.date ?? DateTime.now(),
                  firstDate: dates.first,
                  lastDate: dates.last,
                  locale: locale,
                  initialEntryMode: DatePickerEntryMode.calendarOnly,
                  selectableDayPredicate: (value) => dates.any(
                    (e) => DateUtils.isSameDay(value, e),
                  ),
                );

                if (context.mounted) {
                  ScrollController scrollController =
                      PrimaryScrollController.of(context);

                  if (result != controller.search.date &&
                      scrollController.hasClients) {
                    scrollController.animateTo(0,
                        duration: defaultAnimationDuration,
                        curve: Curves.easeInOut);
                  }
                }

                controller.search = controller.search.copyWith(date: result);
              },
            ),
            drawer: const RouterDrawer(),
            endDrawer: ContextDrawer(
              title: const Text('History'),
              children: [
                SubStream<int>(
                  create: () =>
                      controller.service.length(host: controller.host).stream,
                  keys: [controller.service, controller.host],
                  builder: (context, snapshot) => SwitchListTile(
                    title: const Text('Enabled'),
                    subtitle: Text('${snapshot.data ?? 0} pages visited'),
                    secondary: const Icon(Icons.history),
                    value: controller.service.enabled,
                    onChanged: (value) => controller.service.enabled = value,
                  ),
                ),
                AnimatedBuilder(
                  animation: controller.service,
                  builder: (context, child) => SwitchListTile(
                    value: controller.service.trimming,
                    onChanged: (value) {
                      if (value) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('History limit'),
                            content: Text(
                              'Enabling history limit means all history entries beyond ${NumberFormat.compact().format(controller.service.trimAmount)} '
                              'and all entries older than ${controller.service.trimAge.inDays ~/ 30} months are automatically deleted.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).maybePop(),
                                child: const Text('CANCEL'),
                              ),
                              TextButton(
                                onPressed: () {
                                  controller.service.trimming = value;
                                  Navigator.of(context).maybePop();
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        controller.service.trimming = value;
                      }
                    },
                    secondary: Icon(
                      controller.service.trimming
                          ? Icons.hourglass_bottom
                          : Icons.hourglass_empty,
                    ),
                    title: const Text('Limit history'),
                    subtitle: controller.service.trimming
                        ? Text(
                            'Limited to newer than ${controller.service.trimAge.inDays ~/ 30} months or '
                            'less than ${NumberFormat.compact().format(controller.service.trimAmount)} entries.',
                          )
                        : const Text('history is infinite'),
                  ),
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: ListTileHeader(title: 'Entries'),
                ),
                for (final filter in HistorySearchFilter.values)
                  AnimatedBuilder(
                    animation: controller,
                    builder: (context, child) => Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: CheckboxListTile(
                        secondary: filter.icon,
                        title: Text(filter.title),
                        value: controller.search.searchFilters.contains(filter),
                        onChanged: (value) {
                          if (value == null) return;
                          Set<HistorySearchFilter> filters =
                              Set.of(controller.search.searchFilters);
                          if (value) {
                            filters.add(filter);
                          } else {
                            filters.remove(filter);
                          }
                          controller.search = controller.search.copyWith(
                            searchFilters: filters,
                          );
                        },
                      ),
                    ),
                  ),
                const Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: ListTileHeader(title: 'Type'),
                ),
                for (final filter in HistoryTypeFilter.values)
                  AnimatedBuilder(
                    animation: controller,
                    builder: (context, child) => Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: CheckboxListTile(
                        secondary: filter.icon,
                        title: Text(filter.title),
                        value: controller.search.typeFilters.contains(filter),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          Set<HistoryTypeFilter> filters =
                              Set.of(controller.search.typeFilters);
                          if (value) {
                            filters.add(filter);
                          } else {
                            filters.remove(filter);
                          }
                          controller.search = controller.search.copyWith(
                            typeFilters: filters,
                          );
                        },
                      ),
                    ),
                  ),
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
              groupHeaderBuilder: (element) =>
                  ListTileHeader(title: dateOrName(element.visitedAt)),
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
