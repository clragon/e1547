import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:flutter/material.dart';

class PoolsController extends DataController<Pool>
    with SearchableController, RefreshableController {
  PoolsController({required this.client, String? search})
      : search = ValueNotifier<String>(search ?? '');

  final Client client;

  @override
  late ValueNotifier<String> search;

  @override
  @protected
  List<Listenable> getRefreshListeners() =>
      super.getRefreshListeners()..add(search);

  @override
  @protected
  Future<List<Pool>> provide(int page, bool force) =>
      client.pools(page, search: search.value, force: force);
}

class PoolsProvider extends SubChangeNotifierProvider<Client, PoolsController> {
  PoolsProvider({String? search, super.child, super.builder})
      : super(
          create: (context, client) => PoolsController(
            client: client,
            search: search,
          ),
          selector: (context) => [search],
        );
}
