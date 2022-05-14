import 'package:e1547/interface/interface.dart';
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
    required this.controller,
    this.appBar,
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
      refreshController: controller.refreshController,
      refresh: () => controller.refresh(background: true, force: true),
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
  final Scaffold Function(BuildContext context, Widget child)? pageBuilder;

  const RefreshablePageLoader({
    required this.refresh,
    required this.builder,
    required this.isLoading,
    required this.isEmpty,
    required this.isError,
    this.appBar,
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
      onEmpty: onEmpty,
      onEmptyIcon: onEmptyIcon,
      onError: onError,
      onErrorIcon: onErrorIcon,
      isLoading: isLoading,
      isEmpty: isEmpty,
      isError: isError,
      isBuilt: isBuilt,
      pageBuilder: (context, child) {
        if (pageBuilder != null) {
          return RefreshablePage.pageBuilder(
            builder: (context) => child,
            refreshController: refreshController,
            refreshHeader: refreshHeader,
            refresh: refresh,
            pageBuilder: pageBuilder,
          );
        } else {
          return RefreshablePage(
            builder: (context) => child,
            refreshController: refreshController,
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
  final bool extendBodyBehindAppBar;
  final PreferredSizeWidget? appBar;
  final RefreshController? refreshController;
  final VoidCallback refresh;
  final Scaffold Function(BuildContext context, Widget child)? pageBuilder;

  const RefreshablePage({
    required this.refresh,
    required this.builder,
    this.appBar,
    this.refreshController,
    this.refreshHeader,
    this.drawer,
    this.endDrawer,
    this.floatingActionButton,
    this.extendBodyBehindAppBar = false,
  }) : pageBuilder = null;

  const RefreshablePage.pageBuilder({
    required this.pageBuilder,
    required this.refresh,
    this.builder,
    this.refreshController,
    this.refreshHeader,
  })  : appBar = null,
        extendBodyBehindAppBar = false,
        drawer = null,
        endDrawer = null,
        floatingActionButton = null;

  @override
  State<RefreshablePage> createState() => _RefreshablePageState();
}

class _RefreshablePageState extends State<RefreshablePage> {
  late RefreshController refreshController =
      widget.refreshController ?? RefreshController();

  @override
  void didUpdateWidget(covariant RefreshablePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshController != widget.refreshController) {
      refreshController = widget.refreshController ?? RefreshController();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body() {
      return SmartRefresher(
        controller: refreshController,
        onRefresh: widget.refresh,
        header: widget.refreshHeader ?? const RefreshablePageDefaultHeader(),
        child: widget.builder?.call(context),
      );
    }

    if (widget.pageBuilder != null) {
      return widget.pageBuilder!(context, body());
    } else {
      return LayoutBuilder(builder: (context, constraints) {
        return Scaffold(
          extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
          appBar: widget.appBar,
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
