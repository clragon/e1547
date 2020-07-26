import 'dart:async' show Future;

import 'package:e1547/appInfo.dart';
import 'package:http/http.dart' as http;

String userAgent = '$appName/$appVersion ($developer)';

class HttpHelper {
  Map<String, String> headers = {'User-Agent': userAgent};

  Future<http.Response> post(String host, String path,
      {Map<String, dynamic> query, Map<String, String> body}) {
    return http.post(_getUri(host, path, query), headers: headers, body: body);
  }

  Future<http.Response> get(String host, String path,
      {Map<String, dynamic> query}) {
    return http.get(_getUri(host, path, query), headers: headers);
  }

  Future<http.Response> patch(String host, String path,
      {Map<String, dynamic> query, Map<String, String> body}) {
    return http.patch(_getUri(host, path, query), headers: headers, body: body);
  }

  Future<http.Response> delete(String host, String path,
      {Map<String, dynamic> query}) {
    return http.delete(_getUri(host, path, query), headers: headers);
  }

  Uri _getUri(host, path, query) {
    return Uri(
      scheme: 'https',
      host: host,
      path: path,
      queryParameters: _stringify(query ?? {}),
    );
  }

  Map<String, String> _stringify(Map<String, dynamic> map) {
    Map<String, String> stringMap = {};
    map.forEach((k, v) {
      if (v != null) {
        stringMap[k] = v.toString();
      }
    });
    return stringMap;
  }
}
