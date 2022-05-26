import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> initializeHttpCache() async {
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}

const Duration defaultMaxAge = Duration(minutes: 5);
const Duration defaultMaxStale = Duration(minutes: 10);
const String primaryCacheKeyExtras = 'primaryCacheKeyExtras';

String? getCacheKey(
  String path, {
  OptionsMixin? options,
  Map<String, dynamic>? keyExtras,
}) {
  Uri? primaryKey;
  if (keyExtras != null) {
    String host = RequestOptions(path: path).uri.host;
    if (host.isEmpty) {
      host = options?.baseUrl ?? '';
    }
    primaryKey = Uri.parse(host);
    primaryKey.replace(
      queryParameters: keyExtras.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }

  return primaryKey?.toString();
}

Future<void> clearCacheKey(
  String path,
  DioCacheManager cacheManager, {
  OptionsMixin? options,
  String requestMethod = 'get',
  Map<String, dynamic>? keyExtras,
}) async {
  String? cacheKey = getCacheKey(
    path,
    options: options,
    keyExtras: keyExtras,
  );

  if (cacheKey != null) {
    await cacheManager.delete(
      cacheKey,
      requestMethod: requestMethod,
    );
  } else {
    await cacheManager.deleteByPrimaryKey(
      path,
      requestMethod: requestMethod,
    );
  }
}

Options? buildKeyCacheOptions({
  Options? options,
  Duration? maxAge,
  Duration? maxStale,
  Map<String, dynamic>? keys,
  bool? forceRefresh,
}) {
  return buildConfigurableCacheOptions(
    options: options?.copyWith(
      extra: Map.of(options.extra ?? {})..addAll({primaryCacheKeyExtras: keys}),
    ),
    maxAge: maxAge ?? defaultMaxAge,
    maxStale: maxStale ?? defaultMaxStale,
    forceRefresh: forceRefresh,
  );
}

class CacheKeyInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    RequestOptions nextOptions = options.copyWith();
    Map<String, dynamic>? keys = options.extra[primaryCacheKeyExtras];
    if (keys == null) {
      return handler.next(nextOptions);
    }
    String? cacheKey =
        getCacheKey(options.path, options: options, keyExtras: keys);
    if (cacheKey == null) {
      return handler.next(nextOptions);
    }
    options.extra[DIO_CACHE_KEY_PRIMARY_KEY] = cacheKey;
    return handler.next(nextOptions);
  }
}
