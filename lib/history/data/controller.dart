import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

class HistoriesController extends DataController<History>
    with RefreshableController {
  HistoriesController({
    required this.service,
    HistoriesSearch? search,
  }) : search = ValueNotifier(
          search ??
              HistoriesSearch(
                searchFilters: HistorySearchFilter.values.toSet(),
                typeFilters: HistoryTypeFilter.values.toSet(),
              ),
        );

  final HistoriesService service;

  final ValueNotifier<HistoriesSearch> search;

  @override
  @protected
  List<Listenable> getRefreshListeners() =>
      super.getRefreshListeners()..add(search);

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Future<List<History>> provide(int page, bool force) => service.page(
        page: page,
        day: search.value.date,
        linkRegex: search.value.buildLinkFilter(),
      );

  Future<void> remove(History item) async {
    assertOwnsItem(item);
    await service.remove(item);
    value = PagingState(
      itemList: List.of(itemList!)..remove(item),
      nextPageKey: value.nextPageKey,
      error: value.error,
    );
  }
}

class HistoriesProvider
    extends SubChangeNotifierProvider<HistoriesService, HistoriesController> {
  HistoriesProvider({HistoriesSearch? search, super.child, super.builder})
      : super(
          create: (context, service) => HistoriesController(
            service: service,
            search: search,
          ),
          update: (context, service, controller) {
            if (search != null) {
              controller.search.value = search;
            }
            return controller;
          },
        );
}
