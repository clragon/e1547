import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:flutter/material.dart';

class PoolController extends DataController<Pool>
    with SearchableController, HostableController, RefreshableController {
  @override
  late ValueNotifier<String> search;

  PoolController({String? search})
      : search = ValueNotifier<String>(search ?? '');

  @override
  Future<List<Pool>> provide(int page) =>
      client.pools(page, search: search.value);
}
