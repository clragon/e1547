import 'package:e1547/client.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/thread.dart';

class ThreadProvider extends DataProvider<Thread> {
  List<Thread> get threads => super.items;

  ThreadProvider({
    String search,
  }) : super(provider: (String search, int page) => client.threads(page));
}
