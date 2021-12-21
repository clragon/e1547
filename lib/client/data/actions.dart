import 'package:dio/dio.dart';

Future<bool> validateCall(Future<void> Function() call,
    {bool allowRedirect = false}) async {
  try {
    await call();
    return true;
  } on DioError catch (error) {
    return allowRedirect && error.response?.statusCode == 302;
  }
}
