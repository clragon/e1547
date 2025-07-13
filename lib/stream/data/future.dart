import 'dart:async';

import 'package:async/async.dart';

/// A [Future] that wraps a [Stream].
///
/// This is useful for situations where you usually only need the first item of a
/// stream, but sometimes need to access the stream itself.
class StreamFuture<T> extends DelegatingFuture<T> {
  /// Creates a [StreamFuture] from a [stream].
  ///
  /// If the [stream] is not a broadcast stream, it will be converted to one.
  factory StreamFuture(Stream<T> stream) {
    if (stream.isBroadcast) {
      return StreamFuture._(stream);
    } else {
      return StreamFuture._(stream.asBroadcastStream());
    }
  }

  /// Creates a [StreamFuture] from a [future].
  ///
  /// If the [future] is already a [StreamFuture], it will be returned directly.
  factory StreamFuture.from(FutureOr<T> future) {
    if (future is StreamFuture<T>) {
      return future;
    } else if (future is Future<T>) {
      return StreamFuture(future.asStream());
    } else {
      return StreamFuture.value(future);
    }
  }

  /// Creates a [StreamFuture] that completes with [value].
  ///
  /// Mirrors both `Stream.value` and `Future.value`.
  factory StreamFuture.value(T value) => StreamFuture(Stream<T>.value(value));

  /// Creates a [StreamFuture] from a [future] that completes with a [Stream].
  ///
  /// This is useful for situations where a Stream
  /// depends on a one-time Future for its creation.
  factory StreamFuture.resolve(Future<Stream<T>> Function() future) {
    final controller = StreamController<T>.broadcast();
    future().then((stream) {
      stream.listen(
        controller.add,
        onError: controller.addError,
        onDone: controller.close,
      );
    });
    return controller.stream.future;
  }

  StreamFuture._(Stream<T> stream)
      : assert(
          stream.isBroadcast,
          'StreamFuture can only be created from a broadcast stream.',
        ),
        _stream = stream,
        super(stream.first);

  final Stream<T> _stream;

  Stream<T> get stream => _stream;

  StreamFuture<T2> map<T2>(T2 Function(T value) mapper) =>
      StreamFuture(stream.map(mapper));

  @override
  String toString() => 'StreamFuture<$T> from $_stream';
}

/// An extension on [Stream] to easily create a [StreamFuture].
extension StreamFutureExtension<T> on Stream<T> {
  StreamFuture<T> get future => StreamFuture(this);
}

/// An extension on [Future] to easily create a [StreamFuture].
extension FutureStreamExtension<T> on Future<T> {
  StreamFuture<T> get stream => StreamFuture.from(this);
}
