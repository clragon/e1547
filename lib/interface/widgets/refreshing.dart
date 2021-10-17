import 'package:e1547/interface/interface.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

export 'package:e1547/client/client.dart' show validateCall;

class RefreshableControllerPage<T extends RefreshableController>
    extends StatelessWidget {
  final WidgetBuilder? builder;
  final Widget? refreshHeader;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? appBar;
  final T controller;
  final ScrollController? scrollController;

  const RefreshableControllerPage({
    required this.builder,
    required this.appBar,
    required this.controller,
    this.scrollController,
    this.refreshHeader,
    this.drawer,
    this.endDrawer,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshablePage(
      builder: builder,
      refreshHeader: refreshHeader,
      drawer: drawer,
      endDrawer: endDrawer,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      scrollController: scrollController,
      refreshController: controller.refreshController,
      refresh: () => controller.refresh(background: true),
    );
  }
}

class RefreshablePageLoader extends StatelessWidget {
  final WidgetBuilder? builder;
  final bool isLoading;
  final bool isEmpty;
  final bool isError;
  final bool? isBuilt;
  final bool? initial;
  final Widget? refreshHeader;
  final Widget? onEmpty;
  final Widget? onEmptyIcon;
  final Widget? onError;
  final Widget? onErrorIcon;
  final Widget? onLoading;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? appBar;
  final RefreshController? refreshController;
  final ScrollController? scrollController;
  final VoidCallback refresh;
  final Scaffold Function(BuildContext context, Widget child,
      ScrollController? scrollController)? pageBuilder;

  const RefreshablePageLoader({
    required this.refresh,
    required this.builder,
    required this.appBar,
    required this.isLoading,
    required this.isEmpty,
    required this.isError,
    this.isBuilt,
    this.refreshController,
    this.scrollController,
    this.refreshHeader,
    this.initial,
    this.onLoading,
    this.onEmpty,
    this.onEmptyIcon,
    this.onError,
    this.onErrorIcon,
    this.drawer,
    this.endDrawer,
    this.floatingActionButton,
  }) : pageBuilder = null;

  const RefreshablePageLoader.pageBuilder({
    required this.pageBuilder,
    required this.refresh,
    required this.isLoading,
    required this.isEmpty,
    required this.isError,
    this.isBuilt,
    this.builder,
    this.refreshController,
    this.scrollController,
    this.refreshHeader,
    this.initial,
    this.onLoading,
    this.onEmpty,
    this.onEmptyIcon,
    this.onError,
    this.onErrorIcon,
  })  : appBar = null,
        drawer = null,
        endDrawer = null,
        floatingActionButton = null;

  @override
  Widget build(BuildContext context) {
    return PageLoader(
      onLoading: onLoading,
      onEmpty: onEmpty,
      onEmptyIcon: onEmptyIcon,
      onError: onError,
      onErrorIcon: onErrorIcon,
      isLoading: isLoading,
      isEmpty: isEmpty,
      isError: isError,
      isBuilt: isBuilt,
      pageBuilder: (child) {
        if (pageBuilder != null) {
          return RefreshablePage.pageBuilder(
            builder: (context) => child,
            refreshController: refreshController,
            scrollController: scrollController,
            refreshHeader: refreshHeader,
            refresh: refresh,
            pageBuilder: pageBuilder,
          );
        } else {
          return RefreshablePage(
            builder: (context) => child,
            refreshController: refreshController,
            scrollController: scrollController,
            refreshHeader: refreshHeader,
            refresh: refresh,
            appBar: appBar,
            drawer: drawer,
            endDrawer: endDrawer,
            floatingActionButton: floatingActionButton,
          );
        }
      },
      builder: builder,
    );
  }
}

class RefreshablePage extends StatefulWidget {
  final WidgetBuilder? builder;
  final Widget? refreshHeader;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? appBar;
  final RefreshController? refreshController;
  final ScrollController? scrollController;
  final VoidCallback refresh;
  final Scaffold Function(BuildContext context, Widget child,
      ScrollController? scrollController)? pageBuilder;

  const RefreshablePage({
    required this.refresh,
    required this.builder,
    required this.appBar,
    this.refreshController,
    this.scrollController,
    this.refreshHeader,
    this.drawer,
    this.endDrawer,
    this.floatingActionButton,
  }) : pageBuilder = null;

  const RefreshablePage.pageBuilder({
    required this.pageBuilder,
    required this.refresh,
    this.builder,
    this.refreshController,
    this.scrollController,
    this.refreshHeader,
  })  : appBar = null,
        drawer = null,
        endDrawer = null,
        floatingActionButton = null;

  @override
  _RefreshablePageState createState() => _RefreshablePageState();
}

class _RefreshablePageState extends State<RefreshablePage> {
  late RefreshController refreshController =
      widget.refreshController ?? RefreshController();
  late ScrollController scrollController =
      widget.scrollController ?? ScrollController();

  @override
  Widget build(BuildContext context) {
    Widget body() {
      return SmartRefresher(
        primary: false,
        scrollController: scrollController,
        controller: refreshController,
        onRefresh: widget.refresh,
        physics: BouncingScrollPhysics(),
        child: widget.builder?.call(context),
        header: widget.refreshHeader ?? RefreshablePageDefaultHeader(),
      );
    }

    if (widget.pageBuilder != null) {
      return widget.pageBuilder!(context, body(), scrollController);
    } else {
      return LayoutBuilder(builder: (context, constraints) {
        return Scaffold(
          appBar: ScrollToTop(
            child: widget.appBar!,
            controller: scrollController,
          ),
          body: body(),
          drawer: widget.drawer,
          endDrawer: widget.endDrawer,
          drawerEdgeDragWidth: defaultDrawerEdge(constraints.maxWidth),
          floatingActionButton: widget.floatingActionButton,
        );
      });
    }
  }
}

class FuturePageLoader<T> extends StatelessWidget {
  final Widget Function(BuildContext context, T value) builder;
  final Widget? title;
  final Widget? onLoading;
  final Widget? onEmpty;
  final Widget? onError;
  final bool? isBuilt;
  final Future<T> future;

  const FuturePageLoader({
    required this.future,
    required this.builder,
    this.title,
    this.isBuilt,
    this.onLoading,
    this.onEmpty,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) => PageLoader(
        builder: (context) => builder(context, snapshot.data!),
        loadingBuilder: (child) => Scaffold(
          appBar: title != null
              ? AppBar(
                  leading: CloseButton(),
                  title: title,
                )
              : null,
          body: child,
        ),
        isLoading: snapshot.connectionState != ConnectionState.done,
        isError: snapshot.hasError,
        isEmpty: !snapshot.hasData,
        isBuilt: isBuilt,
        onLoading: onLoading,
        onEmpty: onEmpty,
        onError: onError,
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
  final Widget Function(Widget child)? pageBuilder;
  final Widget Function(Widget child)? loadingBuilder;
  final Widget? onLoading;
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
    this.onLoading,
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
          return IconMessage(
            icon: SizedCircularProgressIndicator(size: 28),
            title: onLoading ?? Text('Loading...'),
          );
        case PageLoaderState.error:
          return IconMessage(
            icon: onErrorIcon ?? Icon(Icons.warning_amber_outlined),
            title: onError ?? Text('Failed to load'),
          );
        case PageLoaderState.empty:
          return IconMessage(
            icon: onEmptyIcon ?? Icon(Icons.clear),
            title: onEmpty ?? Text('Nothing to see here'),
          );
        case PageLoaderState.child:
          return builder!(context);
      }
    }

    Widget body() {
      Widget body = child();
      if (pageBuilder != null) {
        body = pageBuilder!(body);
      }
      if (loadingBuilder != null && state != PageLoaderState.child) {
        body = loadingBuilder!(body);
      }
      return body;
    }

    return Scaffold(
      body: body(),
    );
  }
}

class RefreshablePageDefaultHeader extends StatelessWidget {
  final String? refreshingText;
  final String? completeText;
  const RefreshablePageDefaultHeader({this.completeText, this.refreshingText});

  @override
  Widget build(BuildContext context) {
    return ClassicHeader(
      refreshingText: refreshingText,
      completeText: completeText,
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
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
