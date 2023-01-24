import 'package:async_builder/async_builder.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/history/widgets/appbar.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';

import 'list.dart';

class HistoriesPage extends StatefulWidget {
  const HistoriesPage();

  @override
  State<HistoriesPage> createState() => _HistoriesPageState();
}

class _HistoriesPageState extends State<HistoriesPage> {
  @override
  Widget build(BuildContext context) {
    return HistoriesProvider(
      child: Consumer<HistoriesController>(
        builder: (context, controller, child) => SelectionLayout<History>(
          items: controller.itemList,
          child: RefreshableControllerPage.builder(
            appBar: HistorySelectionAppBar(
              child: DefaultAppBar(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('History'),
                    CrossFade.builder(
                      showChild: controller.search.value.date != null,
                      builder: (context) => Text(
                        dateOrName(controller.search.value.date!),
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
                ScrollController scrollController =
                    PrimaryScrollController.of(context);
                List<DateTime> dates = await controller.service.dates();
                if (dates.isEmpty) {
                  dates.add(DateTime.now());
                }
                if (!mounted) return;
                DateTime? result = await showDatePicker(
                  context: context,
                  initialDate: controller.search.value.date ?? DateTime.now(),
                  firstDate: dates.first,
                  lastDate: dates.last,
                  locale: locale,
                  initialEntryMode: DatePickerEntryMode.calendarOnly,
                  selectableDayPredicate: (value) =>
                      dates.any((e) => DateUtils.isSameDay(value, e)),
                );

                if (result != controller.search.value.date &&
                    scrollController.hasClients) {
                  scrollController.animateTo(0,
                      duration: defaultAnimationDuration,
                      curve: Curves.easeInOut);
                }

                controller.search.value =
                    controller.search.value.copyWith(date: result);
              },
            ),
            drawer: const RouterDrawer(),
            endDrawer: ContextDrawer(
              title: const Text('History'),
              children: [
                Consumer2<HistoriesService, Client>(
                  builder: (context, service, client, child) {
                    return SubValueBuilder<Stream<int>>(
                      create: (context) =>
                          service.watchLength(host: client.host),
                      selector: (context) => [service, client.host],
                      builder: (context, stream) => AsyncBuilder<int>(
                        stream: stream,
                        builder: (context, value) => SwitchListTile(
                          title: const Text('Enabled'),
                          subtitle: Text('${value ?? 0} pages visited'),
                          secondary: const Icon(Icons.history),
                          value: service.enabled,
                          onChanged: (value) => service.enabled = value,
                        ),
                      ),
                    );
                  },
                ),
                AnimatedSelector(
                  selector: () => [controller.service.trimming],
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
                                'and all entries older than ${controller.service.trimAge.inDays ~/ 30} months are automatically deleted.'),
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
                  child: SettingsHeader(title: 'Entries'),
                ),
                for (final filter in HistorySearchFilter.values)
                  ValueListenableBuilder<HistoriesSearch>(
                    valueListenable: controller.search,
                    builder: (context, search, child) => Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: CheckboxListTile(
                        secondary: filter.icon,
                        title: Text(filter.title),
                        value: search.searchFilters.contains(filter),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          Set<HistorySearchFilter> filters =
                              Set.of(search.searchFilters);
                          if (value) {
                            filters.add(filter);
                          } else {
                            filters.remove(filter);
                          }
                          controller.search.value = search.copyWith(
                            searchFilters: filters,
                          );
                        },
                      ),
                    ),
                  ),
                const Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: SettingsHeader(title: 'Type'),
                ),
                for (final filter in HistoryTypeFilter.values)
                  ValueListenableBuilder<HistoriesSearch>(
                    valueListenable: controller.search,
                    builder: (context, search, child) => Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: CheckboxListTile(
                        secondary: filter.icon,
                        title: Text(filter.title),
                        value: search.typeFilters.contains(filter),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          Set<HistoryTypeFilter> filters =
                              Set.of(search.typeFilters);
                          if (value) {
                            filters.add(filter);
                          } else {
                            filters.remove(filter);
                          }
                          controller.search.value = search.copyWith(
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
              pagingController: controller,
              order: GroupedListOrder.DESC,
              controller: PrimaryScrollController.of(context),
              groupBy: (element) => DateUtils.dateOnly(element.visitedAt),
              groupHeaderBuilder: (element) =>
                  SettingsHeader(title: dateOrName(element.visitedAt)),
              itemComparator: (a, b) => a.visitedAt.compareTo(b.visitedAt),
              builderDelegate: defaultPagedChildBuilderDelegate<History>(
                pagingController: controller,
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
