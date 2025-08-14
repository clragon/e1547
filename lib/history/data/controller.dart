import 'package:e1547/domain/domain.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/foundation.dart';

class HistoryController extends PageClientDataController<History> {
  HistoryController({required this.domain, QueryMap? query})
    : _query = query ?? {};

  @override
  final Domain domain;

  QueryMap _query;
  QueryMap get search => _query;
  set search(QueryMap value) {
    if (mapEquals(_query, value)) return;
    _query = value;
    refresh();
  }

  @override
  Future<List<History>> fetch(int page, bool force) {
    return domain.histories.page(
      page: page,
      query: _query,
      force: force,
      cancelToken: cancelToken,
    );
  }
}

class HistoryProvider
    extends SubChangeNotifierProvider<Domain, HistoryController> {
  HistoryProvider({QueryMap? search, super.child, super.builder})
    : super(
        create: (context, client) =>
            HistoryController(domain: client, query: search),
        update: (context, domain, controller) {
          if (search != null) {
            controller.search = search;
          }
          return controller;
        },
      );
}
