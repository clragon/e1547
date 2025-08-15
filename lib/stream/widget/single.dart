import 'package:e1547/stream/stream.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_sub/developer.dart';
import 'package:flutter_sub/flutter_sub.dart';
import 'package:rxdart/rxdart.dart';

class SubStreamFuture<T> extends SubValue<StreamFuture<T>> {
  // ignore: use_key_in_widget_constructors
  SubStreamFuture({
    required SubValueCreate<Future<T>> create,
    super.keys,
    super.update,
    bool preserveState = true,
    ValueChanged<T>? listener,
    required SubValueBuild<AsyncSnapshot<T>> builder,
  }) : super(
          create: () => create().stream,
          builder: (context, future) => SubStream<T>(
            create: () => future.stream,
            initialData: future.stream is ValueStream<T>
                ? (future.stream as ValueStream<T>).valueOrNull
                : null,
            keys: [future.stream], // this is stable.
            listener: listener,
            preserveState: preserveState,
            builder: builder,
          ),
        );
}
