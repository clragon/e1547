import 'package:async/async.dart';

/// A [Future] that wraps a [Stream].
///
/// This is useful for situations where you usually only need the first item of a
/// stream, but sometimes need to access the stream itself.
class StreamFuture<T> extends DelegatingFuture<T> {
  factory StreamFuture(Stream<T> stream) {
    if (stream.isBroadcast) {
      return StreamFuture._(stream);
    } else {
      return StreamFuture._(stream.asBroadcastStream());
    }
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
}

/// An extension on [Stream] to easily create a [StreamFuture].
extension StreamFutureExtension<T> on Stream<T> {
  StreamFuture<T> get future => StreamFuture(this);
}
