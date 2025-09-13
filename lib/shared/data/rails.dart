import 'package:dio/dio.dart';

/// Unwraps ruby on rails API responses and removes the root [key].
/// If the response is not an object or does not contain the [key], this method is no-op.
Response Function(Response) unwrapResponse(String key) => (Response response) {
  if (response.data is Map<String, dynamic>) {
    final inner = response.data[key];
    if (inner != null) {
      response.data = inner;
    }
  }
  return response;
};
