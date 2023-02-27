import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/foundation.dart';

class ClientService extends ChangeNotifier {
  ClientService({
    required this.appInfo,
    required this.allowedHosts,
    String? host,
    String? customHost,
    this.cache,
    Credentials? credentials,
    List<Cookie> cookies = const [],
  })  : _host = host ?? allowedHosts.first,
        _customHost = customHost,
        _credentials = credentials,
        _cookies = cookies;

  final AppInfo appInfo;
  final List<String> allowedHosts;

  final CacheStore? cache;

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

  String get userAgent =>
      '${appInfo.appName}/${appInfo.version} (${appInfo.developer})';

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
          HttpHeaders.userAgentHeader: userAgent,
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
        '',
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
