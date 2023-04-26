import 'dart:io';

import 'package:flutter/services.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';

Future<CookiesService> initializeCookiesService(List<String> hosts) async {
  final service = CookiesService();
  await service.loadAll(
    hosts.map((e) => Uri.https(e).toString()).toList(),
  );
  return service;
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
