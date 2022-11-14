import 'package:flutter/widgets.dart';

void registerFlutterErrorHandler(
    void Function(Object error, StackTrace? trace) handler) {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
    handler(error, stack);
    return false;
  };
  FlutterError.onError = (details) => handler(details.exception, details.stack);
}
