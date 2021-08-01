import 'package:e1547/client.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/pool.dart';
import 'package:flutter/material.dart';

class PoolController extends DataController<Pool>
    with SearchableDataMixin, HostableDataMixin, RefreshableDataMixin {
  late ValueNotifier<String> search;

  PoolController({String? search})
      : this.search = ValueNotifier<String>(search ?? '');

  @override
  Future<List<Pool>> provide(int page) => client.pools(search.value, page);
}
