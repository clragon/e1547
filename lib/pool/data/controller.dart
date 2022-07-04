import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:flutter/material.dart';

class PoolsController extends DataController<Pool>
    with SearchableController, HostableController, RefreshableController {
  @override
  late ValueNotifier<String> search;

  PoolsController({String? search})
      : search = ValueNotifier<String>(search ?? '');

  @override
  @protected
  Future<List<Pool>> provide(int page, bool force) =>
      client.pools(page, search: search.value, force: force);
}
