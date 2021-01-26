import 'package:e1547/client.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/pool.dart';

class PoolProvider extends DataProvider<Pool> {
  List<Pool> get pools => super.items;

  PoolProvider({
    String search,
  }) : super(search: search, provider: client.pools);
}
