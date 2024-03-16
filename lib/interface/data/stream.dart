import 'package:async/async.dart';

/// A [Future] that wraps a [Stream].
///
/// This is useful for situations where an interface returns a [Future], but
/// might provide updates through a [Stream].
///
/// With [StreamFuture], we can therefore serve both
/// single and continuous consumption of data,
/// while defaulting to single consumption, as opposed to a [Stream].
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

  /// Creates a [StreamFuture] that completes with [value].
  factory StreamFuture.value(T value) => StreamFuture(Stream<T>.value(value));

  StreamFuture._(Stream<T> stream)
      : assert(
          stream.isBroadcast,
          'StreamFuture can only be created from a broadcast stream.',
        ),
        _stream = stream,
        super(stream.first);

  final Stream<T> _stream;

  Stream<T> get stream => _stream;
}

/// An extension on [Stream] to easily create a [StreamFuture].
extension StreamFutureExtension<T> on Stream<T> {
  /// Creates a [StreamFuture] from this [Stream].
  StreamFuture<T> get future => StreamFuture<T>(this);
}

/// An extension on [Future] to either cast it to a [StreamFuture] or create a
/// new one from it. Note that the resulting [StreamFuture]
/// might only return a single value, if the original [Future] is not a [StreamFuture].
extension FutureStreamExtension<T> on Future<T> {
  /// Creates a [StreamFuture] from this [Future].
  /// Either casts it to a [StreamFuture] if it already is one, or creates a new
  /// [StreamFuture] from it.
  StreamFuture<T> get stream => this is StreamFuture<T>
      ? this as StreamFuture<T>
      : StreamFuture<T>(asStream());

  /// Turns this [Future] into a [Stream].
  /// If the [Future] is already a [StreamFuture], it will return the [Stream]
  /// from it. Otherwise, it will create a new [Stream] from the [Future].
  Stream<T> get streamed => stream.stream;
}
