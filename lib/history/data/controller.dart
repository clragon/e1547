import 'package:drift/drift.dart';
import 'package:drift/isolate.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';

class HistoriesController extends DataController<int, History> {
  HistoriesController({
    required this.service,
    HistoriesSearch? search,
  })  : _search = search ??
            HistoriesSearch(
              searchFilters: HistorySearchFilter.values.toSet(),
              typeFilters: HistoryTypeFilter.values.toSet(),
            ),
        super(firstPageKey: 1);

  final HistoriesService service;

  HistoriesSearch _search;
  HistoriesSearch get search => _search;
  set search(HistoriesSearch value) {
    if (_search == value) return;
    _search = value;
    notifyListeners();
    refresh();
  }

  @override
  Future<PageResponse<int, History>> performRequest(
      int page, bool force) async {
    try {
      List<History> items = await service
          .page(
            page: page,
            day: search.date,
            linkRegex: search.buildLinkFilter(),
          )
          .first;
      if (items.isEmpty) {
        return PageResponse.last(items: items);
      } else {
        return PageResponse(items: items, nextPageKey: page + 1);
      }
    } on DriftWrappedException catch (e) {
      return PageResponse.error(error: e);
    } on DriftRemoteException catch (e) {
      return PageResponse.error(error: e);
    }
  }

  Future<void> remove(History item) async {
    assertOwnsItem(item);
    await service.remove(item.id);
    rawItems = rawItems!.toList()..remove(item);
  }

  Future<void> removeAll(List<History> items) async {
    for (final item in items) {
      assertOwnsItem(item);
    }
    await service.removeAll(items.map((e) => e.id).toList());
    rawItems = rawItems!.toList()..removeWhere(items.contains);
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
              controller.search = search;
            }
            return controller;
          },
        );
}
