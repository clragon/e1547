import 'dart:io';

import 'package:flutter/services.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';

Future<CookiesService> initializeCookiesService(List<String> hosts) async {
  final service = CookiesService();
  hosts = hosts.map((e) => Uri.https(e).toString()).toList();
  for (final url in hosts) {
    await service.load(url);
  }
  return service;
}

/// Stores web browser cookies in memory.
/// On supported platforms, cookies are also loaded from and saved to disk.
///
/// Before using this class, you must call [load] at least once.
class CookiesService {
  CookiesService({
    WebviewCookieManager? cookieManager,
  }) : cookieManager = cookieManager ?? WebviewCookieManager();

  final WebviewCookieManager cookieManager;

  List<Cookie>? _value;

  /// The cookies currently stored in memory.
  ///
  /// [load] must be called at least once before accessing this.
  List<Cookie> get value {
    if (_value == null) {
      throw StateError(
        '$runtimeType: load must be called at least once before accessing cookies!',
      );
    }
    return List.unmodifiable(_value!);
  }

  /// Loads cookies for [url] from disk.
  ///
  /// This must be called at least once before [value] is accessed.
  /// On unsupported platforms, no disk loading will occur.
  Future<void> load(String url) async {
    _value ??= [];
    _value!.removeWhere((e) => e.domain == url);
    try {
      _value!.addAll(await cookieManager.getCookies(url));
    } on MissingPluginException {
      // platform is not supported
    }
  }

  /// Sets [cookies] and saves them to disk.
  /// On unsupported platforms, no disk saving will occur.
  Future<void> save(List<Cookie> cookies) async {
    _value = cookies;
    try {
      await cookieManager.setCookies(cookies);
    } on MissingPluginException {
      // platform is not supported
    }
  }
}
