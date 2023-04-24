import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:loggy/loggy.dart';

class DioLogMessage {
  DioLogMessage._({
    required this.type,
    required this.uri,
    required this.method,
    this.statusCode,
    this.statusMessage,
    this.queryParameters,
    this.headers,
    this.extra,
    this.errorMessage,
    this.errorType,
    this.data,
    DioLogPrintOptions? printOptions,
  }) : printOptions = printOptions ?? const DioLogPrintOptions();

  factory DioLogMessage.request(
    RequestOptions options, {
    DioLogPrintOptions? printOptions,
  }) =>
      DioLogMessage._(
        type: DioLogMessageType.request,
        uri: options.uri,
        method: options.method,
        queryParameters: options.queryParameters,
        headers: {
          ...options.headers,
          'contentType': options.contentType?.toString(),
          'responseType': options.responseType.toString(),
          'followRedirects': options.followRedirects,
          'connectTimeout': options.connectTimeout,
          'receiveTimeout': options.receiveTimeout,
        },
        extra: options.extra,
        data: options.data,
        printOptions: printOptions,
      );

  factory DioLogMessage.response(
    Response<dynamic> response, {
    DioLogPrintOptions? printOptions,
  }) =>
      DioLogMessage._(
        type: DioLogMessageType.response,
        uri: response.requestOptions.uri,
        method: response.requestOptions.method,
        headers: response.headers.map,
        statusCode: response.statusCode,
        statusMessage: response.statusMessage,
        data: response.data,
        printOptions: printOptions,
      );

  factory DioLogMessage.error(
    DioError err, {
    DioLogPrintOptions? printOptions,
  }) =>
      DioLogMessage._(
        type: DioLogMessageType.error,
        uri: err.requestOptions.uri,
        method: err.requestOptions.method,
        statusCode: err.response?.statusCode,
        statusMessage: err.response?.statusMessage,
        errorType: err.type,
        errorMessage: err.message,
        printOptions: printOptions,
      );

  final DioLogMessageType type;
  final Uri uri;
  final String method;
  final int? statusCode;
  final Map<String, dynamic>? queryParameters;
  final Map<String, dynamic>? headers;
  final Map<String, dynamic>? extra;
  final String? statusMessage;
  final String? errorMessage;
  final DioErrorType? errorType;
  final Object? data;

  final DioLogPrintOptions printOptions;

  @override
  String toString() {
    StringBuffer buffer = StringBuffer();
    switch (type) {
      case DioLogMessageType.request:
        buffer.writeln('>>> Request │ $method │ $uri');
        if (printOptions.requestHeader) {
          _prettyPrintObject(buffer, headers!, header: 'Headers');
          _prettyPrintObject(buffer, extra!, header: 'Extras');
        }
        if (printOptions.requestBody && method != 'GET') {
          Object? data = this.data;
          if (data == null) {
            break;
          }

          if (data is FormData) {
            final Map<String, Object> formDataMap = <String, Object>{}
              ..addEntries(data.fields)
              ..addEntries(data.files);
            _prettyPrintObject(buffer, formDataMap,
                header: 'Form data | ${data.boundary}');
          } else {
            _prettyPrintObject(buffer, data, header: 'Body');
          }
        }
        break;
      case DioLogMessageType.response:
        buffer.writeln(
            '<<< Response │ $method │ $statusCode $statusMessage │ $uri');
        if (printOptions.responseHeader) {
          _prettyPrintObject(buffer, headers!, header: 'Headers');
        }

        if (printOptions.responseBody && data != null) {
          _prettyPrintObject(buffer, data!, header: 'Body');
        }
        break;
      case DioLogMessageType.error:
        buffer.write('<<< DioError');
        if (statusCode != null || statusMessage != null) {
          buffer.write(' | $method');
          buffer.write(' | $statusCode ');
          if (statusMessage != null) {
            buffer.write('$statusMessage');
          }
        } else {
          buffer.write(' (No  response)');
          buffer.write(' | $method');
        }
        buffer.write(' | $uri');
        buffer.writeln();
        if (data != null) {
          _prettyPrintObject(buffer, data!, header: 'DioError │ $errorType');
        }
        if (errorMessage != null) {
          _prettyPrintObject(buffer, errorMessage!, header: 'ERROR');
        }
        break;
    }
    return buffer.toString().trim();
  }

  void _prettyPrintObject(StringBuffer buffer, Object data, {String? header}) {
    String value;

    try {
      final Object object = const JsonDecoder().convert(data.toString());
      const JsonEncoder json = JsonEncoder.withIndent('  ');
      value = '║  ${json.convert(object).replaceAll('\n', '\n║  ')}';
    } on Exception {
      value = '║  ${data.toString().replaceAll('\n', '\n║  ')}';
    }

    buffer.writeln('╔  $header');
    buffer.writeln('║');
    if (value.isNotEmpty) {
      buffer.writeln(value);
    }
    buffer.writeln('║');
    buffer.writeln('╚${'═' * printOptions.maxWidth}╝');
  }
}

enum DioLogMessageType {
  request,
  response,
  error,
}

mixin DioLoggy implements LoggyType {
  @override
  Loggy<DioLoggy> get loggy => Loggy<DioLoggy>('DioLoggy');
}

class LoggyDioInterceptor extends Interceptor with DioLoggy {
  LoggyDioInterceptor({
    this.requestHeader = false,
    this.requestBody = false,
    this.responseHeader = false,
    this.responseBody = true,
    this.error = true,
    this.maxWidth = 90,
    this.requestLevel,
    this.responseLevel,
    this.errorLevel,
  });

  final LogLevel? requestLevel;
  final LogLevel? responseLevel;
  final LogLevel? errorLevel;

  /// Print request header [Options.headers]
  final bool requestHeader;

  /// Print request data [Options.data]
  final bool requestBody;

  /// Print [Response.data]
  final bool responseBody;

  /// Print [Response.headers]
  final bool responseHeader;

  /// Print error message
  final bool error;

  /// Width size per logPrint
  final int maxWidth;

  DioLogPrintOptions get _printOptions => DioLogPrintOptions(
        requestHeader: requestHeader,
        requestBody: requestBody,
        responseHeader: responseHeader,
        responseBody: responseBody,
        maxWidth: maxWidth,
      );

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    loggy.log(requestLevel ?? LogLevel.info,
        DioLogMessage.request(options, printOptions: _printOptions));
    super.onRequest(options, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if (!error) {
      return;
    }

    loggy.log(errorLevel ?? LogLevel.error,
        DioLogMessage.error(err, printOptions: _printOptions));
    super.onError(err, handler);
  }

  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) async {
    loggy.log(responseLevel ?? LogLevel.info,
        DioLogMessage.response(response, printOptions: _printOptions));
    super.onResponse(response, handler);
  }
}

class DioLogPrintOptions {
  const DioLogPrintOptions({
    this.requestHeader = false,
    this.requestBody = false,
    this.responseHeader = false,
    this.responseBody = true,
    this.maxWidth = 90,
  });

  final bool requestHeader;
  final bool requestBody;
  final bool responseHeader;
  final bool responseBody;
  final int maxWidth;
}
