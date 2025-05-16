import 'package:e1547/interface/interface.dart';
import 'package:e1547/traits/traits.dart';

abstract class BridgeService {
  Future<void> available();

  Future<void> push({required Traits traits, CancelToken? cancelToken});

  Future<void> pull({bool? force, CancelToken? cancelToken});
}
