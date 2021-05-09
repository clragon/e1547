import 'package:e1547/client.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/thread.dart';

class ThreadProvider extends DataProvider<Thread> {
  @override
  Future<List<Thread>> provide(int page) => client.threads(page);
}
