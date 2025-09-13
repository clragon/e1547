import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class SizedCircularProgressIndicator extends StatelessWidget {
  const SizedCircularProgressIndicator({
    super.key,
    required this.size,
    this.value,
    this.strokeWidth = 4,
  });

  final double size;
  final double? value;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: Padding(
        padding: EdgeInsets.all(strokeWidth / 2),
        child: CircularProgressIndicator(
          value: value,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class IconMessage extends StatelessWidget {
  const IconMessage({
    super.key,
    this.direction = Axis.vertical,
    required this.title,
    required this.icon,
    this.action,
  });

  final Axis direction;
  final Widget title;
  final Widget icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flex(
            direction: direction,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    iconTheme: Theme.of(context).iconTheme.copyWith(size: 32),
                  ),
                  child: icon,
                ),
              ),
              Padding(padding: const EdgeInsets.only(bottom: 8), child: title),
            ],
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

enum LoadingDisplayState {
  loading,
  empty,
  error,
  done;

  static LoadingDisplayState compute({
    bool isLoading = false,
    bool isEmpty = false,
    bool isError = false,
  }) {
    if (isLoading) return LoadingDisplayState.loading;
    if (isError) return LoadingDisplayState.error;
    if (isEmpty) return LoadingDisplayState.empty;
    return LoadingDisplayState.done;
  }
}

class LoadingDisplay extends StatelessWidget {
  const LoadingDisplay({
    super.key,
    required this.builder,
    required this.state,
    this.onEmpty,
    this.onError,
  });

  final WidgetBuilder builder;
  final LoadingDisplayState state;
  final Widget? onEmpty;
  final Widget? onError;

  @override
  Widget build(BuildContext context) => Material(
    child: switch (state) {
      LoadingDisplayState.loading => const Center(
        child: CircularProgressIndicator(),
      ),
      LoadingDisplayState.error =>
        onError ??
            const IconMessage(
              icon: Icon(Icons.warning_amber_outlined),
              title: Text('Failed to load'),
            ),
      LoadingDisplayState.empty =>
        onEmpty ??
            const IconMessage(
              icon: Icon(Icons.clear),
              title: Text('Nothing to see here'),
            ),
      LoadingDisplayState.done => builder(context),
    },
  );
}

class LoadingPage extends StatelessWidget {
  const LoadingPage({
    super.key,
    this.isLoading = false,
    this.isError = false,
    this.isEmpty = false,
    this.onEmpty,
    this.onError,
    this.title,
    required this.builder,
  });

  final bool isLoading;
  final bool isError;
  final bool isEmpty;
  final Widget? onEmpty;
  final Widget? onError;
  final Widget? title;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final content = LoadingDisplay(
      state: LoadingDisplayState.compute(
        isLoading: isLoading,
        isError: isError,
        isEmpty: isEmpty,
      ),
      onEmpty: onEmpty,
      onError: onError,
      builder: builder,
    );

    if (isLoading || isError) {
      return Scaffold(
        appBar: TransparentAppBar(
          child: DefaultAppBar(leading: const CloseButton(), title: title),
        ),
        body: content,
      );
    }

    return content;
  }
}

class AsyncLoadingPage<T> extends StatelessWidget {
  const AsyncLoadingPage({
    super.key,
    required this.snapshot,
    required this.builder,
    this.title,
    this.isEmpty,
    this.onEmpty,
    this.onError,
  });

  final Widget? title;
  final Widget? onEmpty;
  final Widget? onError;
  final bool? isEmpty;
  final AsyncSnapshot<T> snapshot;
  final Widget Function(BuildContext context, T value) builder;

  @override
  Widget build(BuildContext context) => LoadingPage(
    isLoading: ![
      ConnectionState.active,
      ConnectionState.done,
    ].contains(snapshot.connectionState),
    isError: snapshot.hasError,
    isEmpty: isEmpty ?? false,
    onEmpty: onEmpty,
    onError: onError,
    title: title,
    builder: (context) => builder(context, snapshot.data as T),
  );
}

class FutureLoadingPage<T> extends StatelessWidget {
  const FutureLoadingPage({
    super.key,
    required this.future,
    required this.builder,
    this.title,
    this.isEmpty,
    this.onEmpty,
    this.onError,
  });

  final Widget? title;
  final Widget? onEmpty;
  final Widget? onError;
  final bool? isEmpty;
  final Future<T> future;
  final Widget Function(BuildContext context, T value) builder;

  @override
  Widget build(BuildContext context) => FutureBuilder<T>(
    future: future,
    builder: (context, snapshot) => AsyncLoadingPage<T>(
      snapshot: snapshot,
      title: title,
      isEmpty: isEmpty,
      onEmpty: onEmpty,
      onError: onError,
      builder: builder,
    ),
  );
}
