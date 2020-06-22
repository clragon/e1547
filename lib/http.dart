import 'dart:async' show Future;
import 'package:e1547/appinfo.dart' as appInfo;
import 'package:http/http.dart' as http;

const String userAgent = '${appInfo.appName}/${appInfo.appVersion} (${appInfo.developer})';

class HttpHelper {

  Future<http.Response> post(String host, String path, { Map<String, Object> query}) {
    return postUrl(_getUri(host, path, query));
  }

  Future<http.Response> get(String host, String path, { Map<String, Object> query}) {
    return getUrl(_getUri(host, path, query));
  }

  Future<http.Response> delete(String host, String path, { Map<String, Object> query}) {
    return deleteUrl(_getUri(host, path, query));
  }

  Future<http.Response> getUrl(Uri url) {
    return http.get(url, headers: {'User-Agent': userAgent});
  }

  Future<http.Response> postUrl(Uri url) {
    return http.post(url, headers: {'User-Agent': userAgent});
  }

  Future<http.Response> deleteUrl(Uri url) {
    return http.delete(url, headers: {'User-Agent': userAgent});
  }

  Uri _getUri(host, path, query) {
    return new Uri(
      scheme: 'https',
      host: host,
      path: path,
      queryParameters: _stringify(query),
    );
  }

  Map<String, String> _stringify(Map<String, Object> map) {
    Map<String, String> stringMap = {};
    map.forEach((k, v) {
      if (v != null) {
        stringMap[k] = v.toString();
      }
    });
    return stringMap;
  }

}


