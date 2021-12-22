import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void initializeDesktopCache() {
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}

extension Caching on Dio {
  static Duration defaultMaxAge = const Duration(minutes: 5);
  static Duration defaultMaxStale = const Duration(minutes: 10);

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
    Map<String, dynamic>? primaryKeyExtras,
    bool? forceRefresh,
  }) async {
    String? primaryKey;
    if (primaryKeyExtras != null) {
      primaryKey = '${Uri.parse(this.options.baseUrl).host}/$path';
      List<String> extras = [];
      for (MapEntry<String, dynamic> entry in primaryKeyExtras.entries) {
        if (entry.value != null) {
          extras.add('${entry.key}=${entry.value}');
        }
      }
      if (extras.isNotEmpty) {
        primaryKey += '?';
        primaryKey += extras.join('&');
      }

      if (forceRefresh ?? false) {
        await cacheManager.delete(primaryKey, requestMethod: 'get');
      }
    }

    return get(
      path,
      options: buildCacheOptions(
        maxAge ?? defaultMaxAge,
        maxStale: maxStale ?? defaultMaxStale,
        primaryKey: primaryKey,
        forceRefresh: forceRefresh,
        options: options,
      ),
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }
}
