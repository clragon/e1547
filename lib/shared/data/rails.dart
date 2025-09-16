import 'package:dio/dio.dart';

/// Unwraps ruby on rails API responses by removing the root wrapper.
/// If the response is a map with exactly one key, that key's value is extracted.
/// If the response is an empty object, it is replaced with an empty list.
/// If the response is not an object or has multiple keys, this method is no-op.
Response unwrapRailsArray(Response response) {
  if (response.data is Map<String, dynamic>) {
    final data = response.data as Map<String, dynamic>;
    if (data.isEmpty) {
      response.data = [];
    } else if (data.length == 1) {
      response.data = data.values.first;
    }
  }
  return response;
}
