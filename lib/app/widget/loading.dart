import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';

@immutable
class LoadingShellState {
  const LoadingShellState({this.loading = true, this.message, this.error});

  const LoadingShellState.loading({this.loading = true, this.message})
    : error = null;

  const LoadingShellState.error({this.loading = true, required this.error})
    : message = null;

  final bool loading;
  final String? message;
  final Object? error;

  LoadingShellState copyWith({bool? loading, String? message, Object? error}) {
    return LoadingShellState(
      loading: loading ?? this.loading,
      message: message ?? this.message,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LoadingShellState &&
          other.loading == loading &&
          other.message == message &&
          other.error == error);

  @override
  int get hashCode => Object.hash(loading, message, error);

  @override
  String toString() =>
      'LoadingShellState(loading: $loading, message: $message, error: $error)';
}

class LoadingShellController extends ValueNotifier<LoadingShellState> {
  LoadingShellController([LoadingShellState? state])
    : super(state ?? const LoadingShellState());
}

class _LoadingShellScope extends InheritedNotifier<LoadingShellController> {
  const _LoadingShellScope({
    required LoadingShellController super.notifier,
    required super.child,
  });
}

class LoadingShell extends StatefulWidget {
  const LoadingShell({super.key, required this.child});

  final Widget child;

  static LoadingShellController of(BuildContext context) => maybeOf(context)!;

  static LoadingShellController? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_LoadingShellScope>()
      ?.notifier;

  @override
  State<LoadingShell> createState() => _LoadingShellState();
}

class _LoadingShellState extends State<LoadingShell> {
  final LoadingShellController _controller = LoadingShellController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _LoadingShellScope(
      notifier: _controller,
      child: ValueListenableBuilder(
        valueListenable: _controller,
        builder: (context, state, _) => Stack(
          fit: StackFit.passthrough,
          children: [
            widget.child,
            if (state.loading)
              Positioned.fill(
                child: Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          height: 300,
                          child: Center(child: AppIcon(radius: 64)),
                        ),
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        AnimatedAlign(
                          duration: const Duration(milliseconds: 200),
                          alignment: Alignment.topCenter,
                          heightFactor: state.message == null ? 0 : 1,
                          child: Text(state.message ?? ''),
                        ),
                        AnimatedAlign(
                          duration: const Duration(milliseconds: 200),
                          alignment: Alignment.topCenter,
                          heightFactor: state.error == null ? 0 : 1,
                          child: Text(
                            state.error?.toString() ?? '',
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class LoadingLayer<T> extends StatefulWidget {
  const LoadingLayer({
    super.key,
    required this.future,
    required this.builder,
    this.errorToString,
  });

  final Future<T> future;
  final Widget Function(BuildContext context, T value) builder;
  final String Function(Object error)? errorToString;

  @override
  State<LoadingLayer<T>> createState() => _LoadingLayerState<T>();
}

class _LoadingLayerState<T> extends State<LoadingLayer<T>> {
  late LoadingShellController state;
  late Future<T>? future = widget.future;
  AsyncSnapshot<T>? lastSnapshot;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    state = LoadingShell.of(context);
  }

  void onSnapshotChanged(AsyncSnapshot<T> snapshot) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LoadingShellController state = LoadingShell.of(context);

      if (snapshot != lastSnapshot) {
        lastSnapshot = snapshot;
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            state.value = LoadingShellState.error(
              error:
                  widget.errorToString?.call(snapshot.error!) ??
                  snapshot.error.toString(),
            );
            if (snapshot.stackTrace != null) {
              Error.throwWithStackTrace(snapshot.error!, snapshot.stackTrace!);
            } else {
              // ignore: only_throw_errors
              throw snapshot.error!;
            }
          } else {
            state.value = LoadingShellState(message: state.value.message);
          }
        } else {
          state.value = const LoadingShellState();
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant LoadingLayer<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    state = LoadingShell.of(context);
    if (oldWidget.future != widget.future) {
      future = widget.future;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      state.value = const LoadingShellState();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.future,
      builder: (context, snapshot) {
        onSnapshotChanged(snapshot);
        if (snapshot.connectionState != ConnectionState.done) {
          return Container(color: Theme.of(context).colorScheme.surface);
        } else if (snapshot.hasError) {
          return Container(color: Theme.of(context).colorScheme.surface);
        } else {
          return widget.builder(context, snapshot.data as T);
        }
      },
    );
  }
}

class LoadingCore extends StatefulWidget {
  const LoadingCore({super.key, required this.child});

  final Widget child;

  @override
  State<LoadingCore> createState() => _LoadingCoreState();
}

class _LoadingCoreState extends State<LoadingCore> {
  late LoadingShellController state;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      state = LoadingShell.of(context);
      state.value = state.value.copyWith(loading: false);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    LoadingShellController newState = LoadingShell.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (newState.value != state.value) {
        state = newState;
        state.value = state.value.copyWith(loading: false);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      state.value = state.value.copyWith(loading: true);
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
