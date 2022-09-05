import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

class CacheConfig extends CacheOptions {
  CacheConfig({
    super.policy,
    super.hitCacheOnErrorExcept,
    super.keyBuilder,
    this.pattern,
    this.params,
    this.maxAge,
    super.maxStale,
    super.priority,
    super.store,
    super.cipher,
    super.allowPostMethod,
  });

  /// Overrides the maxAge http directive.
  final Duration? maxAge;

  /// Deletes matching cache entries when [policy] is [CachePolicy.refresh] or [CachePolicy.refreshForceCache].
  final RegExp? pattern;

  /// Deletes matching cache entries when [policy] is [CachePolicy.refresh] or [CachePolicy.refreshForceCache].
  ///
  /// If [pattern] is null but [params] is not, the path of the request will be used as pattern.
  final Map<String, String?>? params;

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
    Nullable<RegExp>? pattern,
    Nullable<Map<String, String?>>? params,
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
        pattern: pattern != null ? pattern.value : this.pattern,
        params: params != null ? params.value : this.params,
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

    bool hasPatterns = config.pattern != null || config.params != null;

    if (isForceRefreshing && hasPatterns) {
      await _getCacheStore(config).deleteFromPath(
        config.pattern ?? RegExp(RegExp.escape(options.uri.path.toString())),
        queryParams: config.params,
      );
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    // Fixes bug in autocomplete endpoint cache-control header
    if (RegExp(r'/autocomplete\.json.*')
        .hasMatch(response.requestOptions.uri.path)) {
      List<String>? header = response.headers[HttpHeaders.cacheControlHeader];
      if (header != null) {
        header = header.map((e) => e.replaceAll(';', ',')).toList();
        response.headers.set(HttpHeaders.cacheControlHeader, header);
      }
    }

    final CacheConfig config = _getCacheConfig(response.requestOptions);

    final CacheControl cacheControl = CacheControl.fromHeader(
      response.headers[HttpHeaders.cacheControlHeader],
    );

    final int updatedMaxAge = config.maxAge?.inSeconds ?? cacheControl.maxAge;

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
