import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';

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
    primaryKey = primaryKey.replace(
      queryParameters: keyExtras.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }

  return primaryKey?.toString();
}

extension Extras on DioCacheManager {
  Future<void> deleteByExtras(
    String path, {
    OptionsMixin? options,
    String? requestMethod,
    Map<String, dynamic>? keyExtras,
  }) async {
    if (options is RequestOptions) {
      requestMethod ??= options.method;
    }

    String? cacheKey = getCacheKey(
      path,
      options: options,
      keyExtras: keyExtras,
    );

    if (cacheKey != null) {
      await delete(
        cacheKey,
        requestMethod: requestMethod,
      );
    } else {
      await deleteByPrimaryKeyAndSubKey(
        path,
        requestMethod: requestMethod,
      );
    }
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
    options: (options ?? Options()).copyWith(
      extra: Map.of(options?.extra ?? {})
        ..addAll({primaryCacheKeyExtras: keys}),
    ),
    maxAge: maxAge ?? defaultMaxAge,
    maxStale: maxStale ?? defaultMaxStale,
    forceRefresh: forceRefresh,
  );
}

class CacheKeyInterceptor extends Interceptor {
  final DioCacheManager cacheManager;

  CacheKeyInterceptor(this.cacheManager);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    RequestOptions nextOptions = options.copyWith();
    Map<String, dynamic>? keys = nextOptions.extra[primaryCacheKeyExtras];
    if (keys == null) {
      return handler.next(nextOptions);
    }
    String? cacheKey =
        getCacheKey(nextOptions.path, options: nextOptions, keyExtras: keys);
    if (cacheKey == null) {
      return handler.next(nextOptions);
    }
    if (nextOptions.extra[DIO_CACHE_KEY_FORCE_REFRESH] == true) {
      cacheManager.deleteByExtras(
        options.path,
        keyExtras: keys,
        options: options,
      );
    }
    nextOptions.extra[DIO_CACHE_KEY_PRIMARY_KEY] = cacheKey;
    return handler.next(nextOptions);
  }
}
