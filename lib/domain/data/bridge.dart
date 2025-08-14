import 'package:e1547/shared/shared.dart';
import 'package:e1547/traits/traits.dart';

abstract class BridgeClient {
  Future<void> available();

  Future<void> push({required Traits traits, CancelToken? cancelToken});

  Future<void> pull({bool? force, CancelToken? cancelToken});
}
