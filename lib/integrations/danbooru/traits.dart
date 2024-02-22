import 'package:e1547/interface/interface.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/foundation.dart';

// TODO: dummy implementation
class DanbooruTraitsClient extends TraitsClient {
  DanbooruTraitsClient({
    required this.traits,
  });

  final ValueNotifier<Traits> traits;

  @override
  Future<void> push({required Traits traits, CancelToken? cancelToken}) async =>
      this.traits.value = traits;

  @override
  Future<void> pull({bool? force, CancelToken? cancelToken}) async {}
}
