import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e1547/client/client.dart';

Future<bool> validateCall(Future<void> Function() call) async {
  try {
    await call();
    return true;
  } on DioError {
    return false;
  }
}

class AuthFailureInterceptor extends Interceptor {
  AuthFailureInterceptor({required this.onAuthFailure});

  final void Function(Credentials? credentials) onAuthFailure;

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      String? auth =
          err.requestOptions.headers[HttpHeaders.authorizationHeader];
      Credentials? credentials;
      if (auth != null) {
        credentials = Credentials.parse(auth);
      }
      onAuthFailure(credentials);
    }

    super.onError(err, handler);
  }
}
