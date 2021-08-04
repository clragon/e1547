import 'package:e1547/interface.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

export 'package:e1547/client.dart' show validateCall;

class RefreshableControllerPage<T extends RefreshableDataMixin>
    extends StatelessWidget {
  final WidgetBuilder? builder;
  final Widget? refreshHeader;
  final Widget? drawer;
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
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshablePage(
      builder: builder,
      refreshHeader: refreshHeader,
      drawer: drawer,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      scrollController: scrollController,
      refreshController: controller.refreshController,
      refresh: () => controller.refresh(background: true),
    );
  }
}

class RefreshablePageLoader extends StatefulWidget {
  final WidgetBuilder? builder;
  final bool isLoading;
  final bool isEmpty;
  final bool isError;
  final bool? isBuilt;
  final bool? initial;
  final Widget? refreshHeader;
  final Widget? onEmpty;
  final Widget? onLoading;
  final Widget? onError;
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
    this.onError,
    this.drawer,
    this.endDrawer,
    this.floatingActionButton,
  }) : this.pageBuilder = null;

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
    this.onError,
  })  : this.appBar = null,
        this.drawer = null,
        this.endDrawer = null,
        this.floatingActionButton = null;

  @override
  _RefreshablePageLoaderState createState() => _RefreshablePageLoaderState();
}

class _RefreshablePageLoaderState extends State<RefreshablePageLoader> {
  late RefreshController refreshController;
  ScrollController? scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = widget.scrollController ?? ScrollController();
    refreshController = widget.refreshController ?? RefreshController();
    if (widget.initial ?? false) {
      widget.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageLoader(
      onLoading: widget.onLoading,
      onEmpty: widget.onEmpty,
      onError: widget.onError,
      isLoading: widget.isLoading,
      isEmpty: widget.isEmpty,
      isError: widget.isError,
      isBuilt: widget.isBuilt,
      pageBuilder: (child) {
        if (widget.pageBuilder != null) {
          return RefreshablePage.pageBuilder(
            builder: (context) => child,
            refreshController: refreshController,
            scrollController: scrollController,
            refreshHeader: widget.refreshHeader,
            refresh: widget.refresh,
            pageBuilder: widget.pageBuilder,
          );
        } else {
          return RefreshablePage(
            builder: (context) => child,
            refreshController: refreshController,
            scrollController: scrollController,
            refreshHeader: widget.refreshHeader,
            refresh: widget.refresh,
            appBar: widget.appBar,
            drawer: widget.drawer,
            endDrawer: widget.endDrawer,
            floatingActionButton: widget.floatingActionButton,
          );
        }
      },
      builder: widget.builder,
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
  }) : this.pageBuilder = null;

  const RefreshablePage.pageBuilder({
    required this.pageBuilder,
    required this.refresh,
    this.builder,
    this.refreshController,
    this.scrollController,
    this.refreshHeader,
  })  : this.appBar = null,
        this.drawer = null,
        this.endDrawer = null,
        this.floatingActionButton = null;

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

enum PageLoaderState {
  loading,
  empty,
  error,
  child,
}

class PageLoader extends StatelessWidget {
  final WidgetBuilder? builder;
  final Widget Function(Widget child)? pageBuilder;
  final Widget? onLoading;
  final Widget? onEmpty;
  final Widget? onError;
  final bool isLoading;
  final bool isEmpty;
  final bool isError;
  final bool? isBuilt;

  PageLoader({
    required this.builder,
    this.isError = false,
    this.isLoading = false,
    this.isEmpty = false,
    this.isBuilt,
    this.pageBuilder,
    this.onLoading,
    this.onEmpty,
    this.onError,
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

    Widget body() {
      switch (state) {
        case PageLoaderState.loading:
          return IconMessage(
            icon: SizedCircularProgressIndicator(size: 28),
            title: onLoading ?? Text('Loading...'),
          );
        case PageLoaderState.error:
          return IconMessage(
            icon: Icon(Icons.warning_amber_outlined),
            title: onError ?? Text('Failed to load'),
          );
        case PageLoaderState.empty:
          return IconMessage(
            icon: Icon(Icons.clear),
            title: onEmpty ?? Text('Nothing to see here'),
          );
        case PageLoaderState.child:
          return builder!(context);
      }
    }

    return Scaffold(
      body: pageBuilder?.call(body()) ?? body(),
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

  const IconMessage(
      {this.direction = Axis.vertical,
      required this.title,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Flex(
        direction: direction,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Theme(
            data: Theme.of(context).copyWith(
              iconTheme: Theme.of(context).iconTheme.copyWith(size: 32),
            ),
            child: icon,
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: title,
          ),
        ],
      ),
    );
  }
}
