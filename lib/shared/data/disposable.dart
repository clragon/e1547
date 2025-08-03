import 'package:meta/meta.dart';

// ignore: one_member_abstracts
abstract mixin class Disposable {
  @mustCallSuper
  void dispose() {}
}

/// Tries to use the `dispose` method on an object if it exists.
/// Otherwise, no-op.
void tryDispose(Object? disposable) {
  try {
    (disposable as dynamic)?.dispose();
    // ignore: avoid_catching_errors
  } on NoSuchMethodError {
    // skip
  }
}
