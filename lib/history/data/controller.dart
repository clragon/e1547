import 'package:e1547/client/client.dart';
import 'package:e1547/history/history.dart';
import 'package:flutter/foundation.dart';

class HistoryController extends PageClientDataController<History> {
  HistoryController({
    required this.client,
    QueryMap? query,
  }) : _query = query ?? {};

  @override
  final Client client;

  QueryMap _query;
  QueryMap get search => _query;
  set search(QueryMap value) {
    if (mapEquals(_query, value)) return;
    _query = value;
    refresh();
  }

  @override
  Future<List<History>> fetch(int page, bool force) {
    return client.histories.page(
      page: page,
      query: _query,
      force: force,
      cancelToken: cancelToken,
    );
  }
}

class HistoryProvider
    extends SubChangeNotifierProvider<Client, HistoryController> {
  HistoryProvider({QueryMap? search, super.child, super.builder})
      : super(
          create: (context, client) => HistoryController(
            client: client,
            query: search,
          ),
          update: (context, service, controller) {
            if (search != null) {
              controller.search = search;
            }
            return controller;
          },
        );
}
