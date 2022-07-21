import 'dart:async';

import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

class SizedCircularProgressIndicator extends StatelessWidget {
  final double size;
  final double? value;
  final double strokeWidth;

  const SizedCircularProgressIndicator({
    required this.size,
    this.value,
    this.strokeWidth = 4,
  });

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
  final Axis direction;
  final Widget title;
  final Widget icon;
  final Widget? action;

  const IconMessage({
    this.direction = Axis.vertical,
    required this.title,
    required this.icon,
    this.action,
  });

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
          title,
          if (action != null) action!,
        ],
      ),
    );
  }
}

enum PageLoaderState {
  loading,
  empty,
  error,
  child,
}

class PageLoader extends StatelessWidget {
  final WidgetBuilder? builder;
  final Widget Function(BuildContext context, Widget child)? pageBuilder;
  final Widget Function(BuildContext context, Widget child)? loadingBuilder;
  final Widget? onEmpty;
  final Widget? onEmptyIcon;
  final Widget? onError;
  final Widget? onErrorIcon;
  final bool isLoading;
  final bool isEmpty;
  final bool isError;
  final bool? isBuilt;

  const PageLoader({
    required this.builder,
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

  @override
  Widget build(BuildContext context) {
    PageLoaderState state =
        isBuilt ?? true ? PageLoaderState.child : PageLoaderState.loading;
    if (isEmpty) {
      if (isLoading) {
        state = PageLoaderState.loading;
      } else if (isError) {
        state = PageLoaderState.error;
      } else {
        state = PageLoaderState.empty;
      }
    }

    Widget child() {
      switch (state) {
        case PageLoaderState.loading:
          return const Center(child: CircularProgressIndicator());
        case PageLoaderState.error:
          return IconMessage(
            icon: onErrorIcon ?? const Icon(Icons.warning_amber_outlined),
            title: onError ?? const Text('Failed to load'),
          );
        case PageLoaderState.empty:
          return IconMessage(
            icon: onEmptyIcon ?? const Icon(Icons.clear),
            title: onEmpty ?? const Text('Nothing to see here'),
          );
        case PageLoaderState.child:
          return builder!(context);
      }
    }

    Widget body() {
      Widget body = child();
      if (pageBuilder != null) {
        body = pageBuilder!(context, body);
      }
      if (loadingBuilder != null && state != PageLoaderState.child) {
        body = loadingBuilder!(context, body);
      }
      return body;
    }

    return Material(
      child: body(),
    );
  }
}

class FuturePageLoader<T> extends StatelessWidget {
  final Widget Function(BuildContext context, T value) builder;
  final Widget? title;
  final Widget? onEmpty;
  final Widget? onError;
  final bool? isBuilt;
  final Future<T> future;

  const FuturePageLoader({
    required this.future,
    required this.builder,
    this.title,
    this.isBuilt,
    this.onEmpty,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) => PageLoader(
        builder: (context) => builder(context, snapshot.data as T),
        loadingBuilder: (context, child) => Scaffold(
          appBar: title != null
              ? DefaultAppBar(
                  leading: const CloseButton(),
                  title: title,
                )
              : null,
          body: child,
        ),
        isLoading: snapshot.connectionState != ConnectionState.done,
        isError: snapshot.hasError,
        isEmpty: !snapshot.hasData,
        isBuilt: isBuilt,
        onEmpty: onEmpty,
        onError: onError,
      ),
    );
  }
}
