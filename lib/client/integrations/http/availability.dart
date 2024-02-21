import 'package:dio/dio.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/foundation.dart';

class HttpAvailabilityClient extends AvailabilityClient {
  HttpAvailabilityClient({
    required Dio dio,
    required this.identity,
    required this.traits,
  }) : _dio = dio;

  final Dio _dio;
  final Identity identity;
  final ValueNotifier<Traits> traits;

  @override
  Future<void> check() async {
    String body = await _dio.get('').then((response) => response.data);
    String? favicon = findFavicon(body);
    traits.value = traits.value.copyWith(
      favicon: favicon != null ? identity.withHost(favicon) : null,
    );
  }
}
