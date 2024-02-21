import 'package:e1547/interface/interface.dart';
import 'package:e1547/traits/traits.dart';

abstract class TraitsClient {
  Future<void> pushTraits({
    required Traits traits,
    CancelToken? cancelToken,
  });

  Future<void> pullTraits({bool? force, CancelToken? cancelToken});
}
