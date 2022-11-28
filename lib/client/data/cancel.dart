import 'package:dio/dio.dart';

class ReadOnlyCancelToken implements CancelToken {
  ReadOnlyCancelToken(this.other);

  final CancelToken other;

  @override
  RequestOptions? get requestOptions => other.requestOptions;

  @override
  DioError? get cancelError => other.cancelError;

  @override
  bool get isCancelled => other.isCancelled;

  @override
  Future<DioError> get whenCancel => other.whenCancel;

  @override
  void cancel([reason]) =>
      throw UnsupportedError('Cannot cancel a read only cancel token');

  @override
  set requestOptions(RequestOptions? requestOptions) =>
      other.requestOptions = requestOptions;
}
