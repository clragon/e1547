import 'package:dio/dio.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/foundation.dart';

class HttpBridgeService extends BridgeService {
  HttpBridgeService({
    required this.dio,
    required this.identity,
    required this.traits,
  });

  final Dio dio;
  final Identity identity;
  final ValueNotifier<Traits> traits;

  @override
  Future<void> available() => dio.get('');

  @override
  Future<void> push({
    required Traits traits,
    CancelToken? cancelToken,
  }) async =>
      this.traits.value = traits;

  @override
  Future<void> pull({
    bool? force,
    CancelToken? cancelToken,
  }) async {
    // no-op
  }
}
