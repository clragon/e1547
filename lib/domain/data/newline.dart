import 'package:dio/dio.dart';

/// [NewlineReplaceInterceptor] replaces all `\r\n` with `\n` in the request.
/// This is needed because some servers send `\r\n` in the response, which
/// breaks general assumptions in the code.
class NewlineReplaceInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.data is String) {
      response.data = response.data.toString().replaceAll('\r\n', '\n');
    }
    super.onResponse(response, handler);
  }
}
