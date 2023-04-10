import 'package:dio/dio.dart';
import 'package:e1547/interface/interface.dart';

typedef ClientException = DioError;

Future<bool> validateCall(Future<void> Function() call) async {
  try {
    await call();
    return true;
  } on ClientException {
    return false;
  }
}

/// Ensures that a call takes at least [duration] time to complete.
/// This allows making API calls in loops while being mindful of the server.
///
/// - [duration] defaults to 500 ms
Future<T> rateLimit<T>(Future<T> call, [Duration? duration]) => Future.wait(
        [call, Future.delayed(duration ?? const Duration(milliseconds: 500))])
    .then((value) => value[0]);

Options forceOptions(bool? force) {
  return CacheConfig(
    policy: (force ?? false) ? CachePolicy.refresh : CachePolicy.request,
  ).toOptions();
}
