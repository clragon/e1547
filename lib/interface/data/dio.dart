import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e1547/interface/interface.dart';

export 'package:dio/dio.dart' show CancelToken;
export 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

// TODO: Controllers now also throw Database exceptions, so this needs to be a real class.
typedef ClientException = DioException;

Future<bool> validateCall(Future<void> Function() call) async {
  try {
    await call();
    return true;
  } on ClientException {
    return false;
  }
}

/// Ensures that a call takes at least [duration] time to complete.
/// This allows making API calls in loops while being mindful of the server.
///
/// - [duration] defaults to 500 ms
Future<T> rateLimit<T>(Future<T> call, [Duration? duration]) => Future.wait([
  call,
  Future.delayed(duration ?? const Duration(milliseconds: 500)),
]).then((value) => value[0]);

Options forceOptions(bool? force) {
  return ClientCacheConfig(
    policy: switch (force) {
      true => CachePolicy.refresh,
      false || null => CachePolicy.request,
    },
  ).toOptions();
}

class ClientCacheConfig extends CacheOptions {
  ClientCacheConfig({
    super.policy,
    super.hitCacheOnErrorCodes,
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

  static ClientCacheConfig? fromExtra(RequestOptions request) {
    final CacheOptions? config = request.getCacheOptions();
    if (config != null && config is ClientCacheConfig) {
      return config;
    }

    return null;
  }

  @override
  ClientCacheConfig copyWith({
    CachePolicy? policy,
    List<int>? hitCacheOnErrorCodes,
    bool? hitCacheOnNetworkFailure,
    CacheKeyBuilder? keyBuilder,
    String? pageParam,
    Duration? maxAge,
    Duration? maxStale,
    CachePriority? priority,
    CacheStore? store,
    CacheCipher? cipher,
    bool? allowPostMethod,
  }) => ClientCacheConfig(
    policy: policy ?? this.policy,
    hitCacheOnErrorCodes: hitCacheOnErrorCodes ?? this.hitCacheOnErrorCodes,
    keyBuilder: keyBuilder ?? this.keyBuilder,
    pageParam: pageParam ?? this.pageParam,
    maxAge: maxAge ?? this.maxAge,
    maxStale: maxStale ?? this.maxStale,
    priority: priority ?? this.priority,
    store: store ?? this.store,
    cipher: cipher ?? this.cipher,
    allowPostMethod: allowPostMethod ?? this.allowPostMethod,
  );
}

class ClientCacheInterceptor extends DioCacheInterceptor {
  ClientCacheInterceptor({required ClientCacheConfig options})
    : _options = options,
      super(options: options);

  final ClientCacheConfig _options;

  CacheStore _getCacheStore(CacheOptions options) =>
      options.store ?? _options.store!;

  ClientCacheConfig _getCacheConfig(RequestOptions options) =>
      ClientCacheConfig.fromExtra(options) ?? _options;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final ClientCacheConfig config = _getCacheConfig(options);

    bool isForceRefreshing = [
      CachePolicy.refresh,
      CachePolicy.refreshForceCache,
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
    final ClientCacheConfig config = _getCacheConfig(response.requestOptions);

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

    response.headers.set(
      HttpHeaders.cacheControlHeader,
      updatedCacheControl.toHeader(),
    );

    super.onResponse(response, handler);
  }
}

extension CacheStoreDioExtension on Dio {
  CacheStore? get cache =>
      (options.extra['@cache_options@'] as CacheOptions?)?.store;
}
