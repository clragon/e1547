import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

typedef SelectiveProviderBuilder0<R> = R Function(BuildContext context);

typedef SelectiveProviderBuilder<T, R> = R Function(
  BuildContext context,
  T value,
);

typedef SelectiveProviderBuilder2<T, T2, R> = R Function(
  BuildContext context,
  T value,
  T2 value2,
);

typedef SelectiveProviderBuilder3<T, T2, T3, R> = R Function(
  BuildContext context,
  T value,
  T2 value2,
  T3 value3,
);

typedef SelectiveProviderBuilder4<T, T2, T3, T4, R> = R Function(
  BuildContext context,
  T value,
  T2 value2,
  T3 value3,
  T4 value4,
);

typedef SelectiveProviderBuilder5<T, T2, T3, T4, T5, R> = R Function(
  BuildContext context,
  T value,
  T2 value2,
  T3 value3,
  T4 value4,
  T5 value5,
);

typedef SelectiveProviderBuilder6<T, T2, T3, T4, T5, T6, R> = R Function(
  BuildContext context,
  T value,
  T2 value2,
  T3 value3,
  T4 value4,
  T5 value5,
  T6 value6,
);

typedef SelectiveBuilder = List<dynamic>? Function(BuildContext context);

class SelectiveProvider0<R> extends SingleChildStatefulWidget {
  final Widget? child;
  final TransitionBuilder? builder;
  final SelectiveProviderBuilder0<R> create;
  final Dispose<R>? dispose;
  final SelectiveProviderBuilder0<List<dynamic>>? selector;
  final bool? notifier;

  const SelectiveProvider0({
    super.key,
    this.child,
    this.builder,
    required this.create,
    this.dispose,
    this.selector,
    this.notifier,
  }) : super(child: child);

  @override
  State<SelectiveProvider0<R>> createState() => _SelectiveProvider0State<R>();
}

class _SelectiveProvider0State<R>
    extends SingleChildState<SelectiveProvider0<R>> {
  List<dynamic>? dependencies;
  R? value;

  void recreate() {
    final List<dynamic>? conditions = widget.selector?.call(context);
    final List<dynamic> values = [if (conditions != null) conditions];
    if (!const DeepCollectionEquality().equals(dependencies, values)) {
      if (value != null) {
        widget.dispose?.call(context, value as R);
      }
      value = widget.create(context);
      dependencies = values;
    }
  }

  @override
  void dispose() {
    widget.dispose?.call(context, value as R);
    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    assert(
      widget.builder != null || child != null,
      '$runtimeType used outside of MultiProvider must specify a child',
    );
    recreate();
    return InheritedProvider.value(
      value: value as R,
      child: widget.builder != null
          ? Builder(
              builder: (context) => widget.builder!(context, child),
            )
          : child!,
    );
  }
}

class SelectiveProvider<T, R> extends SelectiveProvider0<R> {
  SelectiveProvider({
    super.key,
    super.child,
    super.builder,
    required SelectiveProviderBuilder<T, R> create,
    super.dispose,
    SelectiveProviderBuilder<T, List<dynamic>>? selector,
  }) : super(
          create: (context) => create(
            context,
            Provider.of<T>(context),
          ),
          selector: (context) =>
              (selector?.call(context, Provider.of<T>(context)) ?? [])
                ..add(Provider.of<T>(context)),
        );
}

class SelectiveProvider2<T, T2, R> extends SelectiveProvider<T, R> {
  SelectiveProvider2({
    super.key,
    super.child,
    super.builder,
    required SelectiveProviderBuilder2<T, T2, R> create,
    super.dispose,
    SelectiveProviderBuilder2<T, T2, List<dynamic>>? selector,
  }) : super(
          create: (context, value) => create(
            context,
            value,
            Provider.of<T2>(context),
          ),
          selector: (context, value) =>
              (selector?.call(context, value, Provider.of<T2>(context)) ?? [])
                ..add(Provider.of<T2>(context)),
        );
}

class SelectiveProvider3<T, T2, T3, R> extends SelectiveProvider2<T, T2, R> {
  SelectiveProvider3({
    super.key,
    super.child,
    super.builder,
    required SelectiveProviderBuilder3<T, T2, T3, R> create,
    super.dispose,
    SelectiveProviderBuilder3<T, T2, T3, List<dynamic>>? selector,
  }) : super(
          create: (context, value, value2) => create(
            context,
            value,
            value2,
            Provider.of<T3>(context),
          ),
          selector: (context, value, value2) => (selector?.call(
                  context, value, value2, Provider.of<T3>(context)) ??
              [])
            ..add(Provider.of<T3>(context)),
        );
}

class SelectiveProvider4<T, T2, T3, T4, R>
    extends SelectiveProvider3<T, T2, T3, R> {
  SelectiveProvider4({
    super.key,
    super.child,
    super.builder,
    required SelectiveProviderBuilder4<T, T2, T3, T4, R> create,
    super.dispose,
    SelectiveProviderBuilder4<T, T2, T3, T4, List<dynamic>>? selector,
  }) : super(
          create: (context, value, value2, value3) => create(
            context,
            value,
            value2,
            value3,
            Provider.of<T4>(context),
          ),
          selector: (context, value, value2, value3) => (selector?.call(
                  context, value, value2, value3, Provider.of<T4>(context)) ??
              [])
            ..add(Provider.of<T4>(context)),
        );
}

class SelectiveProvider5<T, T2, T3, T4, T5, R>
    extends SelectiveProvider4<T, T2, T3, T4, R> {
  SelectiveProvider5({
    super.key,
    super.child,
    super.builder,
    required SelectiveProviderBuilder5<T, T2, T3, T4, T5, R> create,
    super.dispose,
    SelectiveProviderBuilder5<T, T2, T3, T4, T5, List<dynamic>>? selector,
  }) : super(
          create: (context, value, value2, value3, value4) => create(
            context,
            value,
            value2,
            value3,
            value4,
            Provider.of<T5>(context),
          ),
          selector: (context, value, value2, value3, value4) => (selector?.call(
                  context,
                  value,
                  value2,
                  value3,
                  value4,
                  Provider.of<T5>(context)) ??
              [])
            ..add(Provider.of<T5>(context)),
        );
}

class SelectiveProvider6<T, T2, T3, T4, T5, T6, R>
    extends SelectiveProvider5<T, T2, T3, T4, T5, R> {
  SelectiveProvider6({
    super.key,
    super.child,
    super.builder,
    required SelectiveProviderBuilder6<T, T2, T3, T4, T5, T6, R> create,
    super.dispose,
    SelectiveProviderBuilder6<T, T2, T3, T4, T5, T6, List<dynamic>>? selector,
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
          selector: (context, value, value2, value3, value4, value5) =>
              (selector?.call(context, value, value2, value3, value4, value5,
                      Provider.of<T6>(context)) ??
                  [])
                ..add(Provider.of<T6>(context)),
        );
}

class SelectiveChangeNotifierProvider0<R extends ChangeNotifier?>
    extends SelectiveProvider0<R> {
  SelectiveChangeNotifierProvider0({
    super.key,
    super.child,
    super.builder,
    required super.create,
    super.selector,
  }) : super(
          dispose: (context, value) => value?.dispose(),
        );

  @override
  State<SelectiveProvider0<R>> createState() =>
      _SelectiveChangeNotifierProvider0<R>();
}

class _SelectiveChangeNotifierProvider0<R extends ChangeNotifier?>
    extends _SelectiveProvider0State<R> {
  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    assert(
      widget.builder != null || child != null,
      '$runtimeType used outside of MultiProvider must specify a child',
    );
    recreate();
    return ChangeNotifierProvider.value(
      value: value as R,
      child: widget.builder != null
          ? Builder(
              builder: (context) => widget.builder!(context, child),
            )
          : child!,
    );
  }
}

class SelectiveChangeNotifierProvider<T, R extends ChangeNotifier?>
    extends SelectiveChangeNotifierProvider0<R> {
  SelectiveChangeNotifierProvider({
    super.key,
    super.child,
    super.builder,
    required SelectiveProviderBuilder<T, R> create,
    SelectiveProviderBuilder<T, List<dynamic>>? selector,
  }) : super(
          create: (context) => create(
            context,
            Provider.of<T>(context),
          ),
          selector: (context) =>
              (selector?.call(context, Provider.of<T>(context)) ?? [])
                ..add(Provider.of<T>(context)),
        );
}

class SelectiveChangeNotifierProvider2<T, T2, R extends ChangeNotifier?>
    extends SelectiveChangeNotifierProvider<T, R> {
  SelectiveChangeNotifierProvider2({
    super.key,
    super.child,
    super.builder,
    required SelectiveProviderBuilder2<T, T2, R> create,
    SelectiveProviderBuilder2<T, T2, List<dynamic>>? selector,
  }) : super(
          create: (context, value) => create(
            context,
            value,
            Provider.of<T2>(context),
          ),
          selector: (context, value) =>
              (selector?.call(context, value, Provider.of<T2>(context)) ?? [])
                ..add(Provider.of<T2>(context)),
        );
}

class SelectiveChangeNotifierProvider3<T, T2, T3, R extends ChangeNotifier?>
    extends SelectiveChangeNotifierProvider2<T, T2, R> {
  SelectiveChangeNotifierProvider3({
    super.key,
    super.child,
    super.builder,
    required SelectiveProviderBuilder3<T, T2, T3, R> create,
    SelectiveProviderBuilder3<T, T2, T3, List<dynamic>>? selector,
  }) : super(
          create: (context, value, value2) => create(
            context,
            value,
            value2,
            Provider.of<T3>(context),
          ),
          selector: (context, value, value2) => (selector?.call(
                  context, value, value2, Provider.of<T3>(context)) ??
              [])
            ..add(Provider.of<T3>(context)),
        );
}

class SelectiveChangeNotifierProvider4<T, T2, T3, T4, R extends ChangeNotifier?>
    extends SelectiveChangeNotifierProvider3<T, T2, T3, R> {
  SelectiveChangeNotifierProvider4({
    super.key,
    super.child,
    super.builder,
    required SelectiveProviderBuilder4<T, T2, T3, T4, R> create,
    SelectiveProviderBuilder4<T, T2, T3, T4, List<dynamic>>? selector,
  }) : super(
          create: (context, value, value2, value3) => create(
            context,
            value,
            value2,
            value3,
            Provider.of<T4>(context),
          ),
          selector: (context, value, value2, value3) => (selector?.call(
                  context, value, value2, value3, Provider.of<T4>(context)) ??
              [])
            ..add(Provider.of<T4>(context)),
        );
}

class SelectiveChangeNotifierProvider5<T, T2, T3, T4, T5,
        R extends ChangeNotifier?>
    extends SelectiveChangeNotifierProvider4<T, T2, T3, T4, R> {
  SelectiveChangeNotifierProvider5({
    super.key,
    super.child,
    super.builder,
    required SelectiveProviderBuilder5<T, T2, T3, T4, T5, R> create,
    SelectiveProviderBuilder5<T, T2, T3, T4, T5, List<dynamic>>? selector,
  }) : super(
          create: (context, value, value2, value3, value4) => create(
            context,
            value,
            value2,
            value3,
            value4,
            Provider.of<T5>(context),
          ),
          selector: (context, value, value2, value3, value4) => (selector?.call(
                  context,
                  value,
                  value2,
                  value3,
                  value4,
                  Provider.of<T5>(context)) ??
              [])
            ..add(Provider.of<T5>(context)),
        );
}

class SelectiveChangeNotifierProvider6<T, T2, T3, T4, T5, T6,
        R extends ChangeNotifier?>
    extends SelectiveChangeNotifierProvider5<T, T2, T3, T4, T5, R> {
  SelectiveChangeNotifierProvider6({
    super.key,
    super.child,
    super.builder,
    required SelectiveProviderBuilder6<T, T2, T3, T4, T5, T6, R> create,
    SelectiveProviderBuilder6<T, T2, T3, T4, T5, T6, List<dynamic>>? selector,
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
          selector: (context, value, value2, value3, value4, value5) =>
              (selector?.call(context, value, value2, value3, value4, value5,
                      Provider.of<T6>(context)) ??
                  [])
                ..add(Provider.of<T6>(context)),
        );
}
