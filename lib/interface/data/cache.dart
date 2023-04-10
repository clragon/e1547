import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

export 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

class CacheConfig extends CacheOptions {
  CacheConfig({
    super.policy,
    super.hitCacheOnErrorExcept,
    super.keyBuilder,
    this.pageParam,
    this.maxAge,
    super.maxStale,
    super.priority,
    super.store,
    super.cipher,
    super.allowPostMethod,
  });

  /// Overrides the maxAge http directive.
  final Duration? maxAge;

  /// If the request URL contains this param, it will be ignored during cache deletion.
  /// This allows clearing all pages of an endpoint at once.
  final String? pageParam;

  static CacheConfig? fromExtra(RequestOptions request) {
    final CacheOptions? config = CacheOptions.fromExtra(request);
    if (config != null && config is CacheConfig) {
      return config;
    }

    return null;
  }

  @override
  CacheConfig copyWith({
    CachePolicy? policy,
    Nullable<List<int>>? hitCacheOnErrorExcept,
    CacheKeyBuilder? keyBuilder,
    Nullable<String>? pageParam,
    Nullable<Duration>? maxAge,
    Nullable<Duration>? maxStale,
    CachePriority? priority,
    CacheStore? store,
    Nullable<CacheCipher>? cipher,
    bool? allowPostMethod,
  }) =>
      CacheConfig(
        policy: policy ?? this.policy,
        hitCacheOnErrorExcept: hitCacheOnErrorExcept != null
            ? hitCacheOnErrorExcept.value
            : this.hitCacheOnErrorExcept,
        keyBuilder: keyBuilder ?? this.keyBuilder,
        pageParam: pageParam != null ? pageParam.value : this.pageParam,
        maxAge: maxAge != null ? maxAge.value : this.maxAge,
        maxStale: maxStale != null ? maxStale.value : this.maxStale,
        priority: priority ?? this.priority,
        store: store ?? this.store,
        cipher: cipher != null ? cipher.value : this.cipher,
        allowPostMethod: allowPostMethod ?? this.allowPostMethod,
      );
}

class CacheInterceptor extends DioCacheInterceptor {
  CacheInterceptor({required CacheConfig options})
      : _options = options,
        super(options: options);

  final CacheConfig _options;

  CacheStore _getCacheStore(CacheOptions options) =>
      options.store ?? _options.store!;

  CacheConfig _getCacheConfig(RequestOptions options) =>
      CacheConfig.fromExtra(options) ?? _options;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final CacheConfig config = _getCacheConfig(options);

    bool isForceRefreshing = [
      CachePolicy.refresh,
      CachePolicy.refreshForceCache
    ].contains(config.policy);

    String? pageParam = config.pageParam ?? _options.pageParam;
    if (isForceRefreshing && pageParam != null) {
      Map<String, String?> params = Map.of(options.uri.queryParameters);
      params.remove(pageParam);
      await _getCacheStore(config).deleteFromPath(
        RegExp(RegExp.escape(options.uri.path)),
        queryParams: params,
      );
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    final CacheConfig config = _getCacheConfig(response.requestOptions);

    final CacheControl cacheControl = CacheControl.fromHeader(
      response.headers[HttpHeaders.cacheControlHeader],
    );

    int updatedMaxAge = config.maxAge?.inSeconds ?? cacheControl.maxAge;
    if (updatedMaxAge == 0 && _options.maxAge?.inSeconds != null) {
      updatedMaxAge = _options.maxAge!.inSeconds;
    }

    final CacheControl updatedCacheControl = CacheControl(
      maxAge: updatedMaxAge,
      privacy: cacheControl.privacy,
      maxStale: cacheControl.maxStale,
      minFresh: cacheControl.minFresh,
      mustRevalidate: cacheControl.mustRevalidate,
      noCache: cacheControl.noCache,
      noStore: cacheControl.noStore,
      other: cacheControl.other,
    );

    response.headers
        .set(HttpHeaders.cacheControlHeader, updatedCacheControl.toHeader());

    super.onResponse(response, handler);
  }
}
