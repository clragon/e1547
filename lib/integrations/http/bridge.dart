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
  Future<void> available() async {
    String body = await dio.get('').then((response) => response.data);
    String? favicon = findFavicon(body);
    traits.value = traits.value.copyWith(
      favicon: favicon != null ? identity.withHost(favicon) : null,
    );
  }

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
