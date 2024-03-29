import 'dart:io';
import 'package:dio/dio.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/logs/logs.dart';
import 'package:e1547/settings/settings.dart';

/// Create a default [Dio] instance for the given [Identity].
/// Includes user agent, logging and caching.
Dio createDefaultDio(Identity identity, {CacheStore? cache}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: normalizeHostUrl(identity.host),
      headers: {
        HttpHeaders.userAgentHeader: AppInfo.instance.userAgent,
        ...?identity.headers,
      },
      sendTimeout: const Duration(seconds: 30),
      connectTimeout: const Duration(seconds: 30),
    ),
  );
  dio.interceptors.add(NewlineReplaceInterceptor());
  dio.interceptors.add(LoggingDioInterceptor());
  if (cache != null) {
    dio.interceptors.add(
      ClientCacheInterceptor(
        options: ClientCacheConfig(
          store: cache,
          maxAge: const Duration(minutes: 5),
          pageParam: 'page',
        ),
      ),
    );
  }
  return dio;
}
