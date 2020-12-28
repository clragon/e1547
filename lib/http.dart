import 'dart:async' show Future;
import 'dart:convert';

import 'package:e1547/appInfo.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http_auth/http_auth.dart';

String userAgent = '$appName/$appVersion ($developer)';

class HttpHelper {
  final Credentials credentials;
  final Client client;

  HttpHelper({this.credentials})
      : client = credentials != null
            ? BasicAuthClient(credentials.username, credentials.apikey)
            : Client();

  Map<String, String> headers = {'User-Agent': userAgent};

  Future<Response> post(String host, String path,
      {Map<String, dynamic> query, Map<String, String> body}) {
    return client.post(_getUri(host, path, query),
        headers: headers, body: body);
  }

  Future<Response> get(String host, String path, {Map<String, dynamic> query}) {
    return client.get(_getUri(host, path, query), headers: headers);
  }

  Future<Response> patch(String host, String path,
      {Map<String, dynamic> query, Map<String, String> body}) {
    return client.patch(_getUri(host, path, query),
        headers: headers, body: body);
  }

  Future<Response> delete(String host, String path,
      {Map<String, dynamic> query}) {
    return client.delete(_getUri(host, path, query), headers: headers);
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

class Credentials {
  Credentials({
    @required this.username,
    @required this.apikey,
  });

  final String username;
  final String apikey;

  factory Credentials.fromJson(String str) =>
      Credentials.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Credentials.fromMap(Map<String, dynamic> json) => Credentials(
        username: json["username"],
        apikey: json["apikey"],
      );

  Map<String, dynamic> toMap() => {
        "username": username,
        "apikey": apikey,
      };
}
