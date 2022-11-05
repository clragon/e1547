import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

export 'package:provider/provider.dart';

class SubValueBuilder<T> extends StatefulWidget {
  /// Creates a value that is dependent on other values.
  const SubValueBuilder({
    super.key,
    required this.create,
    this.update,
    this.selector,
    required this.builder,
    this.dispose,
  });

  /// Creates the value. Called at least once and everytime [selector] changes.
  final T Function(BuildContext context) create;

  /// Updates the value. Called every build. If null, does nothing.
  final T Function(BuildContext context, T previous)? update;

  /// Used to decide when to recreate the value. If null, the value is never recreated.
  final SubValueSelector? selector;

  /// Creates the child of this Widget with the value.
  final Widget Function(BuildContext context, T value) builder;

  /// Disposes the value. Called before recreation and when disposing. Useful for Listeners, etc.
  final void Function(BuildContext context, T value)? dispose;

  @override
  State<SubValueBuilder<T>> createState() => _SubValueBuilderState<T>();
}

class _SubValueBuilderState<T> extends State<SubValueBuilder<T>> {
  List<Object?>? _dependencies;
  T? _value;

  T recreate(T? current) {
    final List<Object?> conditions = widget.selector?.call(context) ?? [];
    if (!const DeepCollectionEquality().equals(_dependencies, conditions)) {
      if (current != null) {
        widget.dispose?.call(context, current);
      }
      current = widget.create(context);
      _dependencies = conditions;
    }
    return current!;
  }

  T update(T current) {
    if (widget.update != null) {
      current = widget.update!(context, current);
    }
    return current;
  }

  @override
  void dispose() {
    widget.dispose?.call(context, _value as T);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(
        context,
        _value = update(recreate(_value)),
      );
}

typedef SubValueSelector = List<Object?> Function(BuildContext context);

typedef SubProviderCreate0<R> = R Function(BuildContext context);

typedef SubProviderCreate<T, R> = R Function(
  BuildContext context,
  T value,
);

typedef SubProviderUpdate<T, R> = R Function(
  BuildContext context,
  T value,
  R previous,
);

typedef SubProviderCreate2<T, T2, R> = R Function(
  BuildContext context,
  T value,
  T2 value2,
);

typedef SubProviderUpdate2<T, T2, R> = R Function(
  BuildContext context,
  T value,
  T2 value2,
  R previous,
);

typedef SubProviderCreate3<T, T2, T3, R> = R Function(
  BuildContext context,
  T value,
  T2 value2,
  T3 value3,
);

typedef SubProviderUpdate3<T, T2, T3, R> = R Function(
  BuildContext context,
  T value,
  T2 value2,
  T3 value3,
  R previous,
);

typedef SubProviderCreate4<T, T2, T3, T4, R> = R Function(
  BuildContext context,
  T value,
  T2 value2,
  T3 value3,
  T4 value4,
);

typedef SubProviderUpdate4<T, T2, T3, T4, R> = R Function(
  BuildContext context,
  T value,
  T2 value2,
  T3 value3,
  T4 value4,
  R previous,
);

typedef SubProviderCreate5<T, T2, T3, T4, T5, R> = R Function(
  BuildContext context,
  T value,
  T2 value2,
  T3 value3,
  T4 value4,
  T5 value5,
);

typedef SubProviderUpdate5<T, T2, T3, T4, T5, R> = R Function(
  BuildContext context,
  T value,
  T2 value2,
  T3 value3,
  T4 value4,
  T5 value5,
  R previous,
);

typedef SubProviderCreate6<T, T2, T3, T4, T5, T6, R> = R Function(
  BuildContext context,
  T value,
  T2 value2,
  T3 value3,
  T4 value4,
  T5 value5,
  T6 value6,
);

typedef SubProviderUpdate6<T, T2, T3, T4, T5, T6, R> = R Function(
  BuildContext context,
  T value,
  T2 value2,
  T3 value3,
  T4 value4,
  T5 value5,
  T6 value6,
  R previous,
);

typedef SelectiveBuilder = List<dynamic>? Function(BuildContext context);

class SubProvider0<R> extends SingleChildStatelessWidget {
  const SubProvider0({
    super.key,
    super.child,
    this.builder,
    required this.create,
    this.update,
    this.selector,
    this.dispose,
  });

  final Widget Function(BuildContext context, Widget? child)? builder;
  final SubProviderCreate0<R> create;
  final R Function(BuildContext context, R previous)? update;
  final List<Object?> Function(BuildContext context)? selector;
  final Dispose<R>? dispose;

  @override
  Widget buildWithChild(BuildContext context, Widget? child) =>
      SubValueBuilder<R>(
        create: create,
        selector: selector,
        update: update,
        dispose: dispose,
        builder: (context, value) => Provider.value(
          value: value,
          builder: builder,
          child: child,
        ),
      );
}

class SubProvider<T, R> extends SubProvider0<R> {
  SubProvider({
    super.key,
    super.child,
    super.builder,
    required SubProviderCreate<T, R> create,
    SubProviderUpdate<T, R>? update,
    SubValueSelector? selector,
    super.dispose,
  }) : super(
          create: (context) => create(
            context,
            Provider.of<T>(context),
          ),
          update: update != null
              ? (context, previous) => update(
                    context,
                    Provider.of<T>(context),
                    previous,
                  )
              : null,
          selector: (context) =>
              [Provider.of<T>(context), selector?.call(context)],
        );
}

class SubProvider2<T, T2, R> extends SubProvider<T, R> {
  SubProvider2({
    super.key,
    super.child,
    super.builder,
    required SubProviderCreate2<T, T2, R> create,
    SubProviderUpdate2<T, T2, R>? update,
    SubValueSelector? selector,
    super.dispose,
  }) : super(
          create: (context, value) => create(
            context,
            value,
            Provider.of<T2>(context),
          ),
          update: update != null
              ? (context, value, previous) =>
                  update(context, value, Provider.of<T2>(context), previous)
              : null,
          selector: (context) =>
              [Provider.of<T2>(context), selector?.call(context)],
        );
}

class SubProvider3<T, T2, T3, R> extends SubProvider2<T, T2, R> {
  SubProvider3({
    super.key,
    super.child,
    super.builder,
    required SubProviderCreate3<T, T2, T3, R> create,
    SubProviderUpdate3<T, T2, T3, R>? update,
    SubValueSelector? selector,
    super.dispose,
  }) : super(
    create: (context, value, value2) => create(
            context,
            value,
            value2,
            Provider.of<T3>(context),
          ),
          update: update != null
              ? (context, value, value2, previous) => update(
                  context, value, value2, Provider.of<T3>(context), previous)
              : null,
          selector: (context) =>
              [Provider.of<T3>(context), selector?.call(context)],
        );
}

class SubProvider4<T, T2, T3, T4, R> extends SubProvider3<T, T2, T3, R> {
  SubProvider4({
    super.key,
    super.child,
    super.builder,
    required SubProviderCreate4<T, T2, T3, T4, R> create,
    SubProviderUpdate4<T, T2, T3, T4, R>? update,
    SubValueSelector? selector,
    super.dispose,
  }) : super(
          create: (context, value, value2, value3) => create(
            context,
            value,
            value2,
            value3,
            Provider.of<T4>(context),
          ),
          update: update != null
              ? (context, value, value2, value3, previous) => update(context,
                  value, value2, value3, Provider.of<T4>(context), previous)
              : null,
          selector: (context) =>
              [Provider.of<T4>(context), selector?.call(context)],
        );
}

class SubProvider5<T, T2, T3, T4, T5, R>
    extends SubProvider4<T, T2, T3, T4, R> {
  SubProvider5({
    super.key,
    super.child,
    super.builder,
    required SubProviderCreate5<T, T2, T3, T4, T5, R> create,
    SubProviderUpdate5<T, T2, T3, T4, T5, R>? update,
    SubValueSelector? selector,
    super.dispose,
  }) : super(
          create: (context, value, value2, value3, value4) => create(
            context,
            value,
            value2,
            value3,
            value4,
            Provider.of<T5>(context),
          ),
          update: update != null
              ? (context, value, value2, value3, value4, previous) => update(
                  context,
                  value,
                  value2,
                  value3,
                  value4,
                  Provider.of<T5>(context),
                  previous)
              : null,
          selector: (context) =>
              [Provider.of<T5>(context), selector?.call(context)],
        );
}

class SubProvider6<T, T2, T3, T4, T5, T6, R>
    extends SubProvider5<T, T2, T3, T4, T5, R> {
  SubProvider6({
    super.key,
    super.child,
    super.builder,
    required SubProviderCreate6<T, T2, T3, T4, T5, T6, R> create,
    SubProviderUpdate6<T, T2, T3, T4, T5, T6, R>? update,
    SubValueSelector? selector,
    super.dispose,
  }) : super(
          create: (context, value, value2, value3, value4, value5) => create(
            context,
            value,
            value2,
            value3,
            value4,
            value5,
            Provider.of<T6>(context),
          ),
          update: update != null
              ? (context, value, value2, value3, value4, value5, previous) =>
                  update(context, value, value2, value3, value4, value5,
                      Provider.of<T6>(context), previous)
              : null,
          selector: (context) =>
              [Provider.of<T6>(context), selector?.call(context)],
        );
}

class SubChangeNotifierProvider0<R extends ChangeNotifier>
    extends SubProvider0<R> {
  SubChangeNotifierProvider0({
    super.key,
    super.child,
    super.builder,
    required super.create,
    super.update,
    super.selector,
  }) : super(
          dispose: (context, value) => value.dispose(),
        );

  @override
  Widget buildWithChild(BuildContext context, Widget? child) =>
      SubValueBuilder<R>(
        create: create,
        selector: selector,
        update: update,
        dispose: dispose,
        builder: (context, value) => ChangeNotifierProvider.value(
          value: value,
          builder: builder,
          child: child,
        ),
      );
}

class SubChangeNotifierProvider<T, R extends ChangeNotifier>
    extends SubChangeNotifierProvider0<R> {
  SubChangeNotifierProvider({
    super.key,
    super.child,
    super.builder,
    required SubProviderCreate<T, R> create,
    SubProviderUpdate<T, R>? update,
    SubValueSelector? selector,
  }) : super(
          create: (context) => create(
            context,
            Provider.of<T>(context),
          ),
          update: update != null
              ? (context, previous) => update(
                    context,
                    Provider.of<T>(context),
                    previous,
                  )
              : null,
          selector: (context) =>
              [Provider.of<T>(context), selector?.call(context)],
        );
}

class SubChangeNotifierProvider2<T, T2, R extends ChangeNotifier>
    extends SubChangeNotifierProvider<T, R> {
  SubChangeNotifierProvider2({
    super.key,
    super.child,
    super.builder,
    required SubProviderCreate2<T, T2, R> create,
    SubProviderUpdate2<T, T2, R>? update,
    SubValueSelector? selector,
  }) : super(
    create: (context, value) => create(
            context,
            value,
            Provider.of<T2>(context),
          ),
          update: update != null
              ? (context, value, previous) =>
                  update(context, value, Provider.of<T2>(context), previous)
              : null,
          selector: (context) =>
              [Provider.of<T2>(context), selector?.call(context)],
        );
}

class SubChangeNotifierProvider3<T, T2, T3, R extends ChangeNotifier>
    extends SubChangeNotifierProvider2<T, T2, R> {
  SubChangeNotifierProvider3({
    super.key,
    super.child,
    super.builder,
    required SubProviderCreate3<T, T2, T3, R> create,
    SubProviderUpdate3<T, T2, T3, R>? update,
    SubValueSelector? selector,
  }) : super(
    create: (context, value, value2) => create(
            context,
            value,
            value2,
            Provider.of<T3>(context),
          ),
          update: update != null
              ? (context, value, value2, previous) => update(
                  context, value, value2, Provider.of<T3>(context), previous)
              : null,
          selector: (context) =>
              [Provider.of<T3>(context), selector?.call(context)],
        );
}

class SubChangeNotifierProvider4<T, T2, T3, T4, R extends ChangeNotifier>
    extends SubChangeNotifierProvider3<T, T2, T3, R> {
  SubChangeNotifierProvider4({
    super.key,
    super.child,
    super.builder,
    required SubProviderCreate4<T, T2, T3, T4, R> create,
    SubProviderUpdate4<T, T2, T3, T4, R>? update,
    SubValueSelector? selector,
  }) : super(
          create: (context, value, value2, value3) => create(
            context,
            value,
            value2,
            value3,
            Provider.of<T4>(context),
          ),
          update: update != null
              ? (context, value, value2, value3, previous) => update(context,
                  value, value2, value3, Provider.of<T4>(context), previous)
              : null,
          selector: (context) =>
              [Provider.of<T4>(context), selector?.call(context)],
        );
}

class SubChangeNotifierProvider5<T, T2, T3, T4, T5, R extends ChangeNotifier>
    extends SubChangeNotifierProvider4<T, T2, T3, T4, R> {
  SubChangeNotifierProvider5({
    super.key,
    super.child,
    super.builder,
    required SubProviderCreate5<T, T2, T3, T4, T5, R> create,
    SubProviderUpdate5<T, T2, T3, T4, T5, R>? update,
    SubValueSelector? selector,
  }) : super(
          create: (context, value, value2, value3, value4) => create(
            context,
            value,
            value2,
            value3,
            value4,
            Provider.of<T5>(context),
          ),
          update: update != null
              ? (context, value, value2, value3, value4, previous) => update(
                  context,
                  value,
                  value2,
                  value3,
                  value4,
                  Provider.of<T5>(context),
                  previous)
              : null,
          selector: (context) =>
              [Provider.of<T5>(context), selector?.call(context)],
        );
}

class SubChangeNotifierProvider6<T, T2, T3, T4, T5, T6,
        R extends ChangeNotifier>
    extends SubChangeNotifierProvider5<T, T2, T3, T4, T5, R> {
  SubChangeNotifierProvider6({
    super.key,
    super.child,
    super.builder,
    required SubProviderCreate6<T, T2, T3, T4, T5, T6, R> create,
    SubProviderUpdate6<T, T2, T3, T4, T5, T6, R>? update,
    SubValueSelector? selector,
  }) : super(
          create: (context, value, value2, value3, value4, value5) => create(
            context,
            value,
            value2,
            value3,
            value4,
            value5,
            Provider.of<T6>(context),
          ),
          update: update != null
              ? (context, value, value2, value3, value4, value5, previous) =>
                  update(context, value, value2, value3, value4, value5,
                      Provider.of<T6>(context), previous)
              : null,
          selector: (context) =>
              [Provider.of<T6>(context), selector?.call(context)],
        );
}
