import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';

class ClientService extends ChangeNotifier {
  ClientService({
    required this.appInfo,
    required this.defaultHost,
    required List<String> allowedHosts,
    String? host,
    String? customHost,
    this.cache,
    Credentials? credentials,
    List<Cookie> cookies = const [],
  })  : allowedHosts = {defaultHost, ...allowedHosts}.toList(),
        _host = host ?? defaultHost,
        _customHost = customHost,
        _credentials = credentials,
        _cookies = cookies;

  @override
  void dispose() {
    cache?.close();
    super.dispose();
  }

  final AppInfo appInfo;
  final String defaultHost;
  final List<String> allowedHosts;

  CacheStore? cache;

  String _host;

  String get host => _host;

  set host(String value) {
    if (_host == value) return;
    _host = value;
    notifyListeners();
  }

  String? _customHost;

  String? get customHost => _customHost;

  set customHost(String? value) {
    if (_customHost == value) return;
    _customHost = value;
    notifyListeners();
  }

  Credentials? _credentials;

  Credentials? get credentials => _credentials;

  set credentials(Credentials? value) {
    if (_credentials == value) return;
    _credentials = value;
    notifyListeners();
  }

  bool get hasCustomHost => customHost != null;

  bool get isCustomHost => host == customHost;

  List<Cookie> _cookies;

  List<Cookie> get cookies => List.unmodifiable(_cookies);

  set cookies(List<Cookie> value) {
    if (_cookies == value) return;
    _cookies = value;
    notifyListeners();
  }

  Dio _getClient() {
    return Dio(
      BaseOptions(
        baseUrl: 'https://$host/',
        headers: {
          HttpHeaders.userAgentHeader:
              '${appInfo.appName}/${appInfo.version} (${appInfo.developer})',
        },
        sendTimeout: const Duration(seconds: 30),
        connectTimeout: const Duration(seconds: 30),
      ),
    );
  }

  Future<void> setCustomHost(String value) async {
    if (value.isEmpty) {
      if (host == customHost) {
        host = defaultHost;
      }
      customHost = null;
    } else {
      try {
        await _getClient().get('https://$value');
        await Future.delayed(const Duration(seconds: 1));
        if (value == defaultHost) {
          throw CustomHostDefaultException(host: value);
        } else if (allowedHosts.contains(value)) {
          customHost = value;
        } else {
          throw CustomHostIncompatibleException(host: value);
        }
      } on ClientException {
        throw CustomHostUnreachableException(host: value);
      }
    }
  }

  void useCustomHost(bool value) {
    if (value) {
      if (!hasCustomHost) return;
      host = customHost!;
    } else {
      host = defaultHost;
    }
  }

  Future<bool> tryLogin(Credentials value) async {
    return validateCall(
      () async => _getClient().get(
        'favorites.json',
        options: Options(
          headers: {
            HttpHeaders.authorizationHeader: value.basicAuth,
          },
        ),
      ),
    );
  }

  Future<bool> login(Credentials value) async {
    if (await tryLogin(value)) {
      credentials = value;
      return true;
    } else {
      return false;
    }
  }

  void logout() => credentials = null;
}

abstract class CustomHostException implements Exception {
  CustomHostException({required this.message, required this.host});

  final String message;
  final String host;
}

class CustomHostDefaultException extends CustomHostException {
  CustomHostDefaultException({required super.host})
      : super(message: 'Custom host cannot be default host');
}

class CustomHostIncompatibleException extends CustomHostException {
  CustomHostIncompatibleException({required super.host})
      : super(message: 'Host API incompatible');
}

class CustomHostUnreachableException extends CustomHostException {
  CustomHostUnreachableException({required super.host})
      : super(message: 'Host cannot be reached');
}

class CookiesService {
  CookiesService({
    WebviewCookieManager? cookieManager,
  }) : cookieManager = cookieManager ?? WebviewCookieManager();

  final WebviewCookieManager cookieManager;

  List<Cookie>? _cookies;

  List<Cookie> get cookies {
    if (_cookies == null) {
      throw StateError(
        '$runtimeType: load must be called at least once before accessing cookies!',
      );
    }
    return List.unmodifiable(_cookies!);
  }

  /// Loads cookies from disk.
  /// All already loaded cookies from [url] will be replaced.
  /// This must be called at least once before [cookies] is accessed.
  Future<void> load(String url) async {
    _cookies?.removeWhere((e) => e.domain == url);
    try {
      _cookies = await cookieManager.getCookies(url);
    } on MissingPluginException {
      _cookies = [];
    }
  }

  /// Loads cookies from disk.
  /// All already loaded cookies from [urls] will be replaced.
  Future<void> loadAll(List<String> urls) async {
    for (final url in urls) {
      await load(url);
    }
  }

  /// Writes cookies to disk.
  Future<void> save(List<Cookie> cookies) async {
    try {
      await cookieManager.setCookies(cookies);
    } on MissingPluginException {
      return;
    }
  }
}
