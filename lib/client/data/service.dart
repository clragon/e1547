import 'dart:io';
import 'dart:math';

import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:e1547/client/client.dart';
import 'package:flutter/foundation.dart';

class ClientService extends ChangeNotifier {
  ClientService({
    required this.userAgent,
    required this.allowedHosts,
    String? host,
    String? customHost,
    this.cache,
    this.memoryCache,
    Credentials? credentials,
    List<Cookie> cookies = const [],
  })  : _host = host ?? allowedHosts.first,
        _customHost = customHost,
        _credentials = credentials,
        _cookies = List.unmodifiable(cookies);

  final String userAgent;
  final List<String> allowedHosts;

  final CacheStore? cache;
  final CacheStore? memoryCache;

  String _host;

  String get host => _host;

  String get defaultHost => allowedHosts.first;

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

  List<Cookie> get cookies => _cookies;

  set cookies(List<Cookie> value) {
    _cookies = List.unmodifiable(value);
    notifyListeners();
  }

  Future<void> setCustomHost(String? value) async {
    if (value == null || value.isEmpty) {
      if (host == customHost) {
        host = defaultHost;
      }
      customHost = null;
    } else {
      await Future.delayed(
        Duration(seconds: 1, milliseconds: Random().nextInt(300)),
      );
      if (!allowedHosts.contains(value)) {
        throw CustomHostIncompatibleException(host: value);
      }
      if (value == defaultHost) {
        throw CustomHostDefaultException(host: value);
      }
      customHost = value;
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
    Client client = Client(
      host: host,
      credentials: value,
      userAgent: userAgent,
      cache: cache,
      memoryCache: memoryCache,
      cookies: cookies,
    );
    try {
      await client.currentUser();
      return true;
    } on ClientException {
      return false;
    }
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

  @override
  String toString() => '$runtimeType: $message';
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
