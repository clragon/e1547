import 'package:async/async.dart';

class StreamFuture<T> extends DelegatingFuture<T> {
  StreamFuture(Stream<T> stream)
      : _stream = stream,
        super(stream.isBroadcast
            ? stream.first
            : stream.asBroadcastStream().first);

  final Stream<T> _stream;

  Stream<T> get stream => _stream;
}

extension StreamFutureExtension<T> on Stream<T> {
  StreamFuture<T> get future => StreamFuture(this);
}
