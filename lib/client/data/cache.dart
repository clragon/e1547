import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void initializeHttpCache() {
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}

extension Caching on Dio {
  static Duration defaultMaxAge = const Duration(minutes: 5);
  static Duration defaultMaxStale = const Duration(minutes: 10);

  Future<String?> _prepareCacheKey(
    String path,
    DioCacheManager cacheManager, {
    String requestMethod = 'get',
    Map<String, dynamic>? keyExtras,
    bool? forceRefresh,
  }) async {
    Uri? primaryKey;
    if (keyExtras != null) {
      String host = RequestOptions(path: path).uri.host;
      if (host.isEmpty) {
        host = options.baseUrl;
      }
      primaryKey = Uri.parse(host);
      primaryKey.replace(
        queryParameters: keyExtras.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );
      if (forceRefresh ?? false) {
        await cacheManager.delete(primaryKey.toString(),
            requestMethod: requestMethod);
      }
    } else {
      if (forceRefresh ?? false) {
        await cacheManager.deleteByPrimaryKey(path, requestMethod: 'get');
      }
    }

    return primaryKey?.toString();
  }

  Future<void> clearCacheKey(
    String path,
    DioCacheManager cacheManager, {
    String requestMethod = 'get',
    Map<String, dynamic>? keyExtras,
  }) async {
    await _prepareCacheKey(
      path,
      cacheManager,
      requestMethod: 'get',
      keyExtras: keyExtras,
      forceRefresh: true,
    );
  }

  // primaryKeyExtras allows evicting an entire range of caches
  // this is useful for paged results which are related to e.g. a search or tag.
  Future<Response<T>> getWithCache<T>(
    String path,
    DioCacheManager cacheManager, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    Duration? maxAge,
    Duration? maxStale,
    Map<String, dynamic>? keyExtras,
    bool? forceRefresh,
  }) async {
    return get(
      path,
      options: buildCacheOptions(
        maxAge ?? defaultMaxAge,
        maxStale: maxStale ?? defaultMaxStale,
        primaryKey: await _prepareCacheKey(
          path,
          cacheManager,
          keyExtras: keyExtras,
          forceRefresh: forceRefresh,
        ),
        forceRefresh: forceRefresh,
        options: options,
      ),
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> postWithCacheClear<T>(
    String path,
    DioCacheManager cacheManager, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    Duration? maxAge,
    Duration? maxStale,
    Map<String, dynamic>? keyExtras,
    bool? forceRefresh,
  }) async {
    return post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: buildCacheOptions(
        maxAge ?? defaultMaxAge,
        maxStale: maxStale ?? defaultMaxStale,
        primaryKey: await _prepareCacheKey(
          path,
          cacheManager,
          keyExtras: keyExtras,
          forceRefresh: forceRefresh,
        ),
        forceRefresh: forceRefresh,
        options: options,
      ),
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }
}