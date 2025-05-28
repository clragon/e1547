import 'package:dio/dio.dart';
import 'package:e1547/logs/logs.dart';

class LoggingDioInterceptor extends Interceptor {
  LoggingDioInterceptor({
    this.requestHeader = false,
    this.requestBody = false,
    this.responseHeader = false,
    this.responseBody = true,
  });

  final Logger logger = Logger('Dio');

  final bool requestHeader;
  final bool requestBody;
  final bool responseHeader;
  final bool responseBody;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    StringBuffer buffer = StringBuffer();

    final Uri uri = options.uri;
    final String method = options.method;
    buffer.writeln('>>> Request │ $method │ $uri');

    if (requestHeader) {
      buffer.write(
        prettyLogObject(options.queryParameters, header: 'Query Parameters'),
      );
      final Map<String, dynamic> requestHeaders = <String, dynamic>{};
      requestHeaders.addAll(options.headers);
      requestHeaders['contentType'] = options.contentType?.toString();
      requestHeaders['responseType'] = options.responseType.toString();
      requestHeaders['followRedirects'] = options.followRedirects;
      requestHeaders['connectTimeout'] = options.connectTimeout;
      requestHeaders['receiveTimeout'] = options.receiveTimeout;

      buffer.write(prettyLogObject(requestHeaders, header: 'Headers'));
      buffer.write(prettyLogObject(options.extra, header: 'Extras'));
    }

    final Object? data = options.data;
    if (data != null) {
      if (data is FormData) {
        final Map<String, Object> formDataMap = <String, Object>{}
          ..addEntries(data.fields)
          ..addEntries(data.files);
        buffer.write(
          prettyLogObject(formDataMap, header: 'Form data | ${data.boundary}'),
        );
      } else {
        buffer.write(prettyLogObject(data, header: 'Body'));
      }
    }

    logger.fine(buffer.toString());
    super.onRequest(options, handler);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    StringBuffer buffer = StringBuffer();

    final Uri uri = response.requestOptions.uri;
    final String method = response.requestOptions.method;
    buffer.writeln(
      '<<< Response │ $method │ ${response.statusCode} ${response.statusMessage} │ $uri',
    );

    if (responseHeader) {
      buffer.write(prettyLogObject(response.headers, header: 'Headers'));
    }

    final Object? data = response.data;

    if (responseBody && data != null) {
      buffer.write(prettyLogObject(data, header: 'Body', chars: 1000));
    }

    logger.fine(buffer.toString());
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    StringBuffer buffer = StringBuffer();

    bool isOkay = CancelToken.isCancel(err);

    if (err.type == DioExceptionType.badResponse) {
      if (err.response!.statusCode! < 400) {
        isOkay = true;
      }

      buffer.writeln(
        '<<< DioError │ ${err.requestOptions.method} │ ${err.response?.statusCode} ${err.response?.statusMessage} │ ${err.response?.requestOptions.uri}',
      );
      if (err.response != null && err.response?.data != null) {
        prettyLogObject(err.response?.data, header: 'DioError │ ${err.type}');
      }
    } else if (err.message != null) {
      buffer.writeln(
        '<<< DioError (No response) │ ${err.requestOptions.method} │ ${err.requestOptions.uri}',
      );
      buffer.write(prettyLogObject(err.message!, header: 'ERROR'));
    }

    if (isOkay) {
      logger.fine(buffer.toString());
    } else {
      logger.severe(buffer.toString());
    }
    super.onError(err, handler);
  }
}
