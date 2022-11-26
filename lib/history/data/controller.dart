import 'package:drift/drift.dart';
import 'package:drift/isolate.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

class HistoriesController extends DataController<int, History>
    with RefreshableController {
  HistoriesController({
    required this.service,
    required this.host,
    HistoriesSearch? search,
  })  : search = ValueNotifier(
          search ??
              HistoriesSearch(
                searchFilters: HistorySearchFilter.values.toSet(),
                typeFilters: HistoryTypeFilter.values.toSet(),
              ),
        ),
        super(firstPageKey: 1);

  final HistoriesService service;
  final String host;

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
  Future<PageResponse<int, History>> requestPage(int page) async {
    try {
      List<History> items = await service.page(
        host: host,
        page: page,
        day: search.value.date,
        linkRegex: search.value.buildLinkFilter(),
      );
      if (items.isEmpty) {
        return PageResponse.last(itemList: items);
      } else {
        return PageResponse(itemList: items, nextPageKey: page + 1);
      }
    } on DriftWrappedException catch (e) {
      return PageResponse.error(error: e);
    } on DriftRemoteException catch (e) {
      return PageResponse.error(error: e);
    }
  }

  Future<void> remove(History item) async {
    assertOwnsItem(item);
    await service.remove(item);
    value = PagingState(
      itemList: List.of(itemList!)..remove(item),
      nextPageKey: value.nextPageKey,
      error: value.error,
    );
  }

  Future<void> removeAll(List<History> items) async {
    for (final item in items) {
      assertOwnsItem(item);
    }
    await service.removeAll(items);
    value = PagingState(
      itemList: List.of(itemList!)..removeWhere((e) => items.contains(e)),
      nextPageKey: value.nextPageKey,
      error: value.error,
    );
  }
}

class HistoriesProvider extends SubChangeNotifierProvider2<HistoriesService,
    Client, HistoriesController> {
  HistoriesProvider({HistoriesSearch? search, super.child, super.builder})
      : super(
    create: (context, service, client) => HistoriesController(
      service: service,
            host: client.host,
            search: search,
          ),
    update: (context, service, client, controller) {
      if (search != null) {
        controller.search.value = search;
      }
      return controller;
    },
  );
}
