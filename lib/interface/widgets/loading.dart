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
      child: Flex(
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
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: title,
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

/// Similar to [TransitionBuilder] except that child is guaranteed to be non-null.
typedef WidgetChildBuilder = Widget Function(
    BuildContext context, Widget child);

enum LoadingPageState {
  loading,
  empty,
  error,
  done,
}

class LoadingPage extends StatelessWidget {
  const LoadingPage({
    super.key,
    required this.child,
    this.isError = false,
    this.isLoading = false,
    this.isEmpty = false,
    this.isBuilt,
    this.pageBuilder,
    this.loadingBuilder,
    this.onEmpty,
    this.onEmptyIcon,
    this.onError,
    this.onErrorIcon,
  });

  final WidgetBuilder child;
  final Widget Function(BuildContext context, WidgetBuilder child)? pageBuilder;
  final Widget Function(BuildContext context, WidgetBuilder child)?
      loadingBuilder;
  final Widget? onEmpty;
  final Widget? onEmptyIcon;
  final Widget? onError;
  final Widget? onErrorIcon;
  final bool isLoading;
  final bool isEmpty;
  final bool isError;
  final bool? isBuilt;

  @override
  Widget build(BuildContext context) {
    LoadingPageState state =
        isBuilt ?? true ? LoadingPageState.done : LoadingPageState.loading;
    if (isEmpty) {
      if (isLoading) {
        state = LoadingPageState.loading;
      } else if (isError) {
        state = LoadingPageState.error;
      } else {
        state = LoadingPageState.empty;
      }
    }

    Widget content(BuildContext context) {
      switch (state) {
        case LoadingPageState.loading:
          return const Center(child: CircularProgressIndicator());
        case LoadingPageState.error:
          return IconMessage(
            icon: onErrorIcon ?? const Icon(Icons.warning_amber_outlined),
            title: onError ?? const Text('Failed to load'),
          );
        case LoadingPageState.empty:
          return IconMessage(
            icon: onEmptyIcon ?? const Icon(Icons.clear),
            title: onEmpty ?? const Text('Nothing to see here'),
          );
        case LoadingPageState.done:
          return child(context);
      }
    }

    Widget body() {
      Widget? body;
      if (pageBuilder != null) {
        body = pageBuilder!(context, content);
      }
      if (loadingBuilder != null && state != LoadingPageState.done) {
        body = loadingBuilder!(context, content);
      }
      return body ?? content(context);
    }

    return Material(
      child: body(),
    );
  }
}

class AsyncLoadingPage<T> extends StatelessWidget {
  const AsyncLoadingPage({
    super.key,
    required this.snapshot,
    required this.builder,
    this.title,
    this.isEmpty,
    this.isBuilt,
    this.onEmpty,
    this.onError,
  });

  final Widget Function(BuildContext context, T value) builder;
  final Widget? title;
  final Widget? onEmpty;
  final Widget? onError;
  final bool? isEmpty;
  final bool? isBuilt;
  final AsyncSnapshot<T> snapshot;

  @override
  Widget build(BuildContext context) {
    return LoadingPage(
      child: (context) => builder(context, snapshot.data as T),
      loadingBuilder: (context, child) => Scaffold(
        appBar: title != null
            ? AppBar(
                leading: const CloseButton(),
                title: title,
              )
            : null,
        body: child(context),
      ),
      isLoading: snapshot.connectionState != ConnectionState.done,
      isError: snapshot.hasError,
      isEmpty: isEmpty ?? snapshot.connectionState != ConnectionState.done,
      isBuilt: isBuilt,
      onEmpty: onEmpty,
      onError: onError,
    );
  }
}

class FutureLoadingPage<T> extends StatelessWidget {
  const FutureLoadingPage({
    super.key,
    required this.future,
    required this.builder,
    this.title,
    this.isEmpty,
    this.isBuilt,
    this.onEmpty,
    this.onError,
  });

  final Widget Function(BuildContext context, T value) builder;
  final Widget? title;
  final Widget? onEmpty;
  final Widget? onError;
  final bool? isEmpty;
  final bool? isBuilt;
  final Future<T> future;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) => AsyncLoadingPage(
        snapshot: snapshot,
        title: title,
        isEmpty: isEmpty,
        isBuilt: isBuilt,
        onEmpty: onEmpty,
        onError: onError,
        builder: builder,
      ),
    );
  }
}
